`timescale 1ns / 1ps
//============================================================
// Módulo : vram_background_writer
//
// Generador de imagen para el reloj digital VGA.
// Escribe directamente en la VRAM de doble puerto el fondo
// sólido, los dos puntos separadores y los dígitos/letras
// de la hora escalados por bitmap desde digit_rom.
//
// Estrategia de renderizado:
//   - En INIT  : barre toda la VRAM (640×480), pinta fondo sólido.
//   - En COLON : pinta los ':' en posiciones fijas.
//   - En IDLE  : espera tick_1hz.
//   - En RENDER: repinta los 8 slots de la hora por segundo.
//
// Layout:
//   X_START = 56   Y_START = 176
//   Dígitos (slots 0-5): 64×128 px, escala ×8
//   Formato (slots 6-7): 32×64  px, escala ×4, Y_orig=208
//
//   [H1][H2] : [M1][M2] : [S1][S2]   [C1][C2]
//    56  124    216  280    372  436    516  548
//
// Autoría  : Brayan Solís
// Proyecto : Taller de Diseño Digital EL3313 - I Sem 2026
//============================================================

module vram_background_writer (
    input  wire        clk,
    input  wire        reset,

    output reg         we,
    output reg  [18:0] addr_write,
    output reg  [7:0]  data_in,

    input  wire [4:0]  hour_disp,
    input  wire [5:0]  minute,
    input  wire [5:0]  second,
    input  wire        am_pm,
    input  wire        fmt_sel,
    input  wire        tick_1hz
);

    //----------------------------------------------------------
    // Parámetros de pantalla y layout
    //----------------------------------------------------------
    localparam SCR_W   = 640;
    localparam SCR_H   = 480;

    localparam X_START = 10'd56;
    localparam Y_START = 10'd176;

    localparam DIG_W   = 7'd64;
    localparam DIG_H   = 8'd128;

    localparam FMT_W   = 6'd32;
    localparam FMT_H   = 7'd64;
    localparam FMT_Y   = 10'd208;

    localparam X_S0    = 10'd56;
    localparam X_S1    = 10'd124;
    localparam X_S2    = 10'd216;
    localparam X_S3    = 10'd280;
    localparam X_S4    = 10'd372;
    localparam X_S5    = 10'd436;
    localparam X_S6    = 10'd516;
    localparam X_S7    = 10'd548;

    localparam X_COL0  = 10'd196;
    localparam X_COL1  = 10'd360;
    localparam COL_W   = 4;

    //----------------------------------------------------------
    // Colores RGB332
    //----------------------------------------------------------
    localparam COLOR_BG    = 8'h00;
    localparam COLOR_DIGIT = 8'hFF;
    localparam COLOR_OFF   = 8'h00;
    localparam COLOR_COLON = 8'hE0;

    //----------------------------------------------------------
    // Estados de la FSM
    //----------------------------------------------------------
    localparam ST_INIT       = 3'd0;
    localparam ST_COLON      = 3'd1;
    localparam ST_IDLE       = 3'd2;
    localparam ST_LOAD_SLOT  = 3'd3;
    localparam ST_RENDER_PIX = 3'd4;
    localparam ST_NEXT_SLOT  = 3'd5;

    //----------------------------------------------------------
    // Registros de estado y contadores
    //----------------------------------------------------------
    reg [2:0]  state;

    reg [9:0]  init_x;
    reg [9:0]  init_y;

    reg        colon_idx;
    reg [2:0]  col_x;
    reg [7:0]  col_y;

    reg [2:0]  slot_idx;

    // FIX: px y py declarados al nivel del módulo (no dentro de begin...end)
    reg [6:0]  px;
    reg [7:0]  py;

    reg [9:0]  slot_x0;
    reg [9:0]  slot_y0;
    reg [6:0]  slot_w;
    reg [7:0]  slot_h;
    reg [3:0]  slot_scale;
    reg [3:0]  slot_digit;

    //----------------------------------------------------------
    // Interfaz con digit_rom
    // FIX: rom_digit_sel y rom_row manejados en always @(*)
    //      para que la ROM responda combinacionalmente en el
    //      mismo ciclo sin latencia de un flanco.
    //----------------------------------------------------------
    reg  [3:0] rom_digit_sel;
    reg  [3:0] rom_row;
    wire [7:0] rom_row_data;

    digit_rom rom_inst (
        .digit_sel (rom_digit_sel),
        .row       (rom_row),
        .row_data  (rom_row_data)
    );

    // FIX: ROM conectada combinacionalmente desde registros de estado
    always @(*) begin
        rom_digit_sel = slot_digit;
        rom_row       = py >> (slot_scale == 4'd8 ? 3 : 2); // py/8 o py/4
    end

    //----------------------------------------------------------
    // FIX: col_bmp y pixel_on declarados al nivel del módulo
    //----------------------------------------------------------
    reg [2:0] col_bmp;
    reg       pixel_on;

    always @(*) begin
        col_bmp   = px >> (slot_scale == 4'd8 ? 3 : 2); // px/8 o px/4
        pixel_on  = rom_row_data[7 - col_bmp];
    end

    //----------------------------------------------------------
    // FIX: División por 10 reemplazada por lookup tables
    //      para evitar inferencia de divisores en hardware.
    //----------------------------------------------------------
    reg [3:0] h_tens, h_units;
    reg [3:0] m_tens, m_units;
    reg [3:0] s_tens, s_units;

    always @(*) begin
        // Horas (0-23)
        if      (hour_disp >= 5'd20) begin h_tens = 4'd2; h_units = hour_disp - 5'd20; end
        else if (hour_disp >= 5'd10) begin h_tens = 4'd1; h_units = hour_disp - 5'd10; end
        else                         begin h_tens = 4'd0; h_units = hour_disp;          end

        // Minutos (0-59)
        if      (minute >= 6'd50) begin m_tens = 4'd5; m_units = minute - 6'd50; end
        else if (minute >= 6'd40) begin m_tens = 4'd4; m_units = minute - 6'd40; end
        else if (minute >= 6'd30) begin m_tens = 4'd3; m_units = minute - 6'd30; end
        else if (minute >= 6'd20) begin m_tens = 4'd2; m_units = minute - 6'd20; end
        else if (minute >= 6'd10) begin m_tens = 4'd1; m_units = minute - 6'd10; end
        else                      begin m_tens = 4'd0; m_units = minute;          end

        // Segundos (0-59)
        if      (second >= 6'd50) begin s_tens = 4'd5; s_units = second - 6'd50; end
        else if (second >= 6'd40) begin s_tens = 4'd4; s_units = second - 6'd40; end
        else if (second >= 6'd30) begin s_tens = 4'd3; s_units = second - 6'd30; end
        else if (second >= 6'd20) begin s_tens = 4'd2; s_units = second - 6'd20; end
        else if (second >= 6'd10) begin s_tens = 4'd1; s_units = second - 6'd10; end
        else                      begin s_tens = 4'd0; s_units = second;          end
    end

    wire [3:0] fmt_c1 = (!fmt_sel) ? 4'd14 : (!am_pm) ? 4'd10 : 4'd12;
    wire [3:0] fmt_c2 = (!fmt_sel) ? 4'd15 : 4'd11;

    //----------------------------------------------------------
    // Decodificación del dígito activo según slot_idx
    //----------------------------------------------------------
    reg [3:0] digit_of_slot;
    always @(*) begin
        case (slot_idx)
            3'd0: digit_of_slot = h_tens;
            3'd1: digit_of_slot = h_units;
            3'd2: digit_of_slot = m_tens;
            3'd3: digit_of_slot = m_units;
            3'd4: digit_of_slot = s_tens;
            3'd5: digit_of_slot = s_units;
            3'd6: digit_of_slot = fmt_c1;
            3'd7: digit_of_slot = fmt_c2;
            default: digit_of_slot = 4'd0;
        endcase
    end

    //----------------------------------------------------------
    // FSM principal
    //----------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            state      <= ST_INIT;
            init_x     <= 10'd0;
            init_y     <= 10'd0;
            colon_idx  <= 1'b0;
            col_x      <= 3'd0;
            col_y      <= 8'd0;
            slot_idx   <= 3'd0;
            px         <= 7'd0;
            py         <= 8'd0;
            we         <= 1'b0;
            addr_write <= 19'd0;
            data_in    <= 8'h00;
            slot_digit <= 4'd0;
            slot_x0    <= 10'd0;
            slot_y0    <= 10'd0;
            slot_w     <= 7'd0;
            slot_h     <= 8'd0;
            slot_scale <= 4'd8;
        end else begin
            we <= 1'b0;

            case (state)

                //----------------------------------------------
                // ST_INIT: Barre toda la VRAM con fondo sólido
                //----------------------------------------------
                ST_INIT: begin
                    we         <= 1'b1;
                    addr_write <= init_y * SCR_W + init_x;
                    data_in    <= COLOR_BG;

                    if (init_x == SCR_W - 1) begin
                        init_x <= 10'd0;
                        if (init_y == SCR_H - 1) begin
                            init_y    <= 10'd0;
                            colon_idx <= 1'b0;
                            col_x     <= 3'd0;
                            col_y     <= 8'd0;
                            state     <= ST_COLON;
                        end else
                            init_y <= init_y + 1'b1;
                    end else
                        init_x <= init_x + 1'b1;
                end

                //----------------------------------------------
                // ST_COLON: Pinta los dos ':' fijos
                // Dos bloques de 4×8 px centrados verticalmente
                // en filas 40-47 y 72-79 del rango de 128px
                //----------------------------------------------
                ST_COLON: begin
                    we         <= 1'b1;
                    addr_write <= (Y_START + {2'b00, col_y}) * SCR_W +
                                  ((colon_idx ? X_COL1 : X_COL0) + {7'b0, col_x});

                    if ((col_y >= 8'd40 && col_y <= 8'd47) ||
                        (col_y >= 8'd72 && col_y <= 8'd79))
                        data_in <= COLOR_COLON;
                    else
                        data_in <= COLOR_BG;

                    if (col_x == COL_W - 1) begin
                        col_x <= 3'd0;
                        if (col_y == 8'd127) begin
                            col_y <= 8'd0;
                            if (colon_idx == 1'b1) begin
                                slot_idx <= 3'd0;
                                state    <= ST_IDLE;
                            end else
                                colon_idx <= 1'b1;
                        end else
                            col_y <= col_y + 1'b1;
                    end else
                        col_x <= col_x + 1'b1;
                end

                //----------------------------------------------
                // ST_IDLE: Espera tick_1hz
                //----------------------------------------------
                ST_IDLE: begin
                    if (tick_1hz) begin
                        slot_idx <= 3'd0;
                        state    <= ST_LOAD_SLOT;
                    end
                end

                //----------------------------------------------
                // ST_LOAD_SLOT: Carga parámetros del slot activo
                //----------------------------------------------
                ST_LOAD_SLOT: begin
                    case (slot_idx)
                        3'd0: begin slot_x0<=X_S0; slot_y0<=Y_START; slot_w<=DIG_W; slot_h<=DIG_H; slot_scale<=4'd8; end
                        3'd1: begin slot_x0<=X_S1; slot_y0<=Y_START; slot_w<=DIG_W; slot_h<=DIG_H; slot_scale<=4'd8; end
                        3'd2: begin slot_x0<=X_S2; slot_y0<=Y_START; slot_w<=DIG_W; slot_h<=DIG_H; slot_scale<=4'd8; end
                        3'd3: begin slot_x0<=X_S3; slot_y0<=Y_START; slot_w<=DIG_W; slot_h<=DIG_H; slot_scale<=4'd8; end
                        3'd4: begin slot_x0<=X_S4; slot_y0<=Y_START; slot_w<=DIG_W; slot_h<=DIG_H; slot_scale<=4'd8; end
                        3'd5: begin slot_x0<=X_S5; slot_y0<=Y_START; slot_w<=DIG_W; slot_h<=DIG_H; slot_scale<=4'd8; end
                        3'd6: begin slot_x0<=X_S6; slot_y0<=FMT_Y;   slot_w<=FMT_W; slot_h<=FMT_H; slot_scale<=4'd4; end
                        3'd7: begin slot_x0<=X_S7; slot_y0<=FMT_Y;   slot_w<=FMT_W; slot_h<=FMT_H; slot_scale<=4'd4; end
                        default: begin slot_x0<=10'd0; slot_y0<=10'd0; slot_w<=7'd0; slot_h<=8'd0; slot_scale<=4'd8; end
                    endcase

                    slot_digit <= digit_of_slot;
                    px         <= 7'd0;
                    py         <= 8'd0;
                    state      <= ST_RENDER_PIX;
                end

                //----------------------------------------------
                // ST_RENDER_PIX: Un píxel por ciclo
                // pixel_on y col_bmp se calculan combinacionalmente
                // desde px, py, slot_scale y rom_row_data
                //----------------------------------------------
                ST_RENDER_PIX: begin
                    we         <= 1'b1;
                    addr_write <= (slot_y0 + {2'b00, py}) * SCR_W +
                                  (slot_x0 + {3'b000, px});
                    data_in    <= pixel_on ? COLOR_DIGIT : COLOR_OFF;

                    if (px == slot_w - 1) begin
                        px <= 7'd0;
                        if (py == slot_h - 1) begin
                            py    <= 8'd0;
                            state <= ST_NEXT_SLOT;
                        end else
                            py <= py + 1'b1;
                    end else
                        px <= px + 1'b1;
                end

                //----------------------------------------------
                // ST_NEXT_SLOT: Avanza o vuelve a IDLE
                //----------------------------------------------
                ST_NEXT_SLOT: begin
                    if (slot_idx == 3'd7)
                        state <= ST_IDLE;
                    else begin
                        slot_idx <= slot_idx + 1'b1;
                        state    <= ST_LOAD_SLOT;
                    end
                end

                default: state <= ST_IDLE;

            endcase
        end
    end

endmodule