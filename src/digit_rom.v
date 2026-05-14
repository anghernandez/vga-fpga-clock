`timescale 1ns / 1ps
//============================================================
// Módulo : digit_rom
//
// ROM combinacional de bitmaps para dígitos (0-9) y
// bloques de formato (AM, PM, 24H).
//
// Dígitos  : bitmap 8x16, escala x8 en el generador → 64x128 px
// Formato  : bitmap 8x16 por letra, escala x4        → 32x64 px/letra
//
// Interfaz:
//   digit_sel [3:0] - 0-9: dígito, 10:A, 11:M, 12:P, 13:H, 14:2, 15:4
//   row       [3:0] - fila del bitmap (0-15)
//   row_data  [7:0] - byte de la fila; bit[7]=col0, bit[0]=col7
//============================================================

module digit_rom (
    input  wire [3:0] digit_sel,
    input  wire [3:0] row,
    output reg  [7:0] row_data
);

    always @(*) begin
        case (digit_sel)
            //--------------------------------------------------
            // Dígitos 0-9
            //--------------------------------------------------
            4'd0: case (row)
                4'd0:  row_data = 8'h3C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h66;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h66;
                4'd6:  row_data = 8'h66;
                4'd7:  row_data = 8'h66;
                4'd8:  row_data = 8'h66;
                4'd9:  row_data = 8'h66;
                4'd10: row_data = 8'h66;
                4'd11: row_data = 8'h66;
                4'd12: row_data = 8'h66;
                4'd13: row_data = 8'h66;
                4'd14: row_data = 8'h66;
                4'd15: row_data = 8'h3C;
                default: row_data = 8'h00;
            endcase

            4'd1: case (row)
                4'd0:  row_data = 8'h18;
                4'd1:  row_data = 8'h38;
                4'd2:  row_data = 8'h78;
                4'd3:  row_data = 8'h18;
                4'd4:  row_data = 8'h18;
                4'd5:  row_data = 8'h18;
                4'd6:  row_data = 8'h18;
                4'd7:  row_data = 8'h18;
                4'd8:  row_data = 8'h18;
                4'd9:  row_data = 8'h18;
                4'd10: row_data = 8'h18;
                4'd11: row_data = 8'h18;
                4'd12: row_data = 8'h18;
                4'd13: row_data = 8'h18;
                4'd14: row_data = 8'h18;
                4'd15: row_data = 8'h7E;
                default: row_data = 8'h00;
            endcase

            4'd2: case (row)
                4'd0:  row_data = 8'h3C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h06;
                4'd4:  row_data = 8'h06;
                4'd5:  row_data = 8'h06;
                4'd6:  row_data = 8'h0C;
                4'd7:  row_data = 8'h18;
                4'd8:  row_data = 8'h30;
                4'd9:  row_data = 8'h30;
                4'd10: row_data = 8'h60;
                4'd11: row_data = 8'h60;
                4'd12: row_data = 8'h60;
                4'd13: row_data = 8'h60;
                4'd14: row_data = 8'h66;
                4'd15: row_data = 8'h7E;
                default: row_data = 8'h00;
            endcase

            4'd3: case (row)
                4'd0:  row_data = 8'h3C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h06;
                4'd4:  row_data = 8'h06;
                4'd5:  row_data = 8'h06;
                4'd6:  row_data = 8'h1C;
                4'd7:  row_data = 8'h06;
                4'd8:  row_data = 8'h06;
                4'd9:  row_data = 8'h06;
                4'd10: row_data = 8'h06;
                4'd11: row_data = 8'h06;
                4'd12: row_data = 8'h66;
                4'd13: row_data = 8'h66;
                4'd14: row_data = 8'h66;
                4'd15: row_data = 8'h3C;
                default: row_data = 8'h00;
            endcase

            4'd4: case (row)
                4'd0:  row_data = 8'h06;
                4'd1:  row_data = 8'h0E;
                4'd2:  row_data = 8'h1E;
                4'd3:  row_data = 8'h36;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h66;
                4'd6:  row_data = 8'h66;
                4'd7:  row_data = 8'h7E;
                4'd8:  row_data = 8'h06;
                4'd9:  row_data = 8'h06;
                4'd10: row_data = 8'h06;
                4'd11: row_data = 8'h06;
                4'd12: row_data = 8'h06;
                4'd13: row_data = 8'h06;
                4'd14: row_data = 8'h06;
                4'd15: row_data = 8'h06;
                default: row_data = 8'h00;
            endcase

            4'd5: case (row)
                4'd0:  row_data = 8'h7E;
                4'd1:  row_data = 8'h60;
                4'd2:  row_data = 8'h60;
                4'd3:  row_data = 8'h60;
                4'd4:  row_data = 8'h60;
                4'd5:  row_data = 8'h60;
                4'd6:  row_data = 8'h7C;
                4'd7:  row_data = 8'h66;
                4'd8:  row_data = 8'h06;
                4'd9:  row_data = 8'h06;
                4'd10: row_data = 8'h06;
                4'd11: row_data = 8'h06;
                4'd12: row_data = 8'h06;
                4'd13: row_data = 8'h06;
                4'd14: row_data = 8'h66;
                4'd15: row_data = 8'h3C;
                default: row_data = 8'h00;
            endcase

            4'd6: case (row)
                4'd0:  row_data = 8'h1C;
                4'd1:  row_data = 8'h30;
                4'd2:  row_data = 8'h60;
                4'd3:  row_data = 8'h60;
                4'd4:  row_data = 8'h60;
                4'd5:  row_data = 8'h60;
                4'd6:  row_data = 8'h7C;
                4'd7:  row_data = 8'h66;
                4'd8:  row_data = 8'h66;
                4'd9:  row_data = 8'h66;
                4'd10: row_data = 8'h66;
                4'd11: row_data = 8'h66;
                4'd12: row_data = 8'h66;
                4'd13: row_data = 8'h66;
                4'd14: row_data = 8'h66;
                4'd15: row_data = 8'h3C;
                default: row_data = 8'h00;
            endcase

            4'd7: case (row)
                4'd0:  row_data = 8'h7E;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h06;
                4'd3:  row_data = 8'h06;
                4'd4:  row_data = 8'h06;
                4'd5:  row_data = 8'h0C;
                4'd6:  row_data = 8'h0C;
                4'd7:  row_data = 8'h18;
                4'd8:  row_data = 8'h18;
                4'd9:  row_data = 8'h18;
                4'd10: row_data = 8'h30;
                4'd11: row_data = 8'h30;
                4'd12: row_data = 8'h30;
                4'd13: row_data = 8'h30;
                4'd14: row_data = 8'h30;
                4'd15: row_data = 8'h30;
                default: row_data = 8'h00;
            endcase

            4'd8: case (row)
                4'd0:  row_data = 8'h3C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h66;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h66;
                4'd6:  row_data = 8'h3C;
                4'd7:  row_data = 8'h66;
                4'd8:  row_data = 8'h66;
                4'd9:  row_data = 8'h66;
                4'd10: row_data = 8'h66;
                4'd11: row_data = 8'h66;
                4'd12: row_data = 8'h66;
                4'd13: row_data = 8'h66;
                4'd14: row_data = 8'h66;
                4'd15: row_data = 8'h3C;
                default: row_data = 8'h00;
            endcase

            4'd9: case (row)
                4'd0:  row_data = 8'h3C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h66;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h66;
                4'd6:  row_data = 8'h66;
                4'd7:  row_data = 8'h3E;
                4'd8:  row_data = 8'h06;
                4'd9:  row_data = 8'h06;
                4'd10: row_data = 8'h06;
                4'd11: row_data = 8'h06;
                4'd12: row_data = 8'h06;
                4'd13: row_data = 8'h06;
                4'd14: row_data = 8'h0C;
                4'd15: row_data = 8'h38;
                default: row_data = 8'h00;
            endcase

            //--------------------------------------------------
            // Letras para bloques de formato (escala x4)
            // 10=A  11=M  12=P  13=H  14=2  15=4
            //--------------------------------------------------
            4'd10: case (row)  // A
                4'd0:  row_data = 8'h18;
                4'd1:  row_data = 8'h3C;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h66;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h7E;
                4'd6:  row_data = 8'h66;
                4'd7:  row_data = 8'h66;
                4'd8:  row_data = 8'h66;
                4'd9:  row_data = 8'h66;
                4'd10: row_data = 8'h66;
                4'd11: row_data = 8'h66;
                4'd12: row_data = 8'h66;
                default: row_data = 8'h00;
            endcase

            4'd11: case (row)  // M
                4'd0:  row_data = 8'hC3;  // 11000011
                4'd1:  row_data = 8'hE7;  // 11100111
                4'd2:  row_data = 8'hFF;  // 11111111
                4'd3:  row_data = 8'hDB;  // 11011011
                4'd4:  row_data = 8'hC3;  // 11000011
                4'd5:  row_data = 8'hC3;  // 11000011
                4'd6:  row_data = 8'hC3;  // 11000011
                4'd7:  row_data = 8'hC3;  // 11000011
                4'd8:  row_data = 8'hC3;  // 11000011
                4'd9:  row_data = 8'hC3;  // 11000011
                4'd10: row_data = 8'hC3;  // 11000011
                4'd11: row_data = 8'hC3;  // 11000011
                4'd12: row_data = 8'hC3;  // 11000011
                default: row_data = 8'h00;
            endcase

            4'd12: case (row)  // P
                4'd0:  row_data = 8'h7C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h66;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h7C;
                4'd6:  row_data = 8'h60;
                4'd7:  row_data = 8'h60;
                4'd8:  row_data = 8'h60;
                4'd9:  row_data = 8'h60;
                4'd10: row_data = 8'h60;
                4'd11: row_data = 8'h60;
                4'd12: row_data = 8'h60;
                default: row_data = 8'h00;
            endcase

            4'd13: case (row)  // H
                4'd0:  row_data = 8'h66;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h66;
                4'd3:  row_data = 8'h66;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h7E;
                4'd6:  row_data = 8'h66;
                4'd7:  row_data = 8'h66;
                4'd8:  row_data = 8'h66;
                4'd9:  row_data = 8'h66;
                4'd10: row_data = 8'h66;
                4'd11: row_data = 8'h66;
                4'd12: row_data = 8'h66;
                default: row_data = 8'h00;
            endcase

            4'd14: case (row)  // 2
                4'd0:  row_data = 8'h3C;
                4'd1:  row_data = 8'h66;
                4'd2:  row_data = 8'h06;
                4'd3:  row_data = 8'h06;
                4'd4:  row_data = 8'h0C;
                4'd5:  row_data = 8'h18;
                4'd6:  row_data = 8'h30;
                4'd7:  row_data = 8'h60;
                4'd8:  row_data = 8'h60;
                4'd9:  row_data = 8'h66;
                4'd10: row_data = 8'h7E;
                default: row_data = 8'h00;
            endcase

            4'd15: case (row)  // 4
                4'd0:  row_data = 8'h06;
                4'd1:  row_data = 8'h0E;
                4'd2:  row_data = 8'h1E;
                4'd3:  row_data = 8'h36;
                4'd4:  row_data = 8'h66;
                4'd5:  row_data = 8'h66;
                4'd6:  row_data = 8'h7E;
                4'd7:  row_data = 8'h06;
                4'd8:  row_data = 8'h06;
                4'd9:  row_data = 8'h06;
                4'd10: row_data = 8'h06;
                default: row_data = 8'h00;
            endcase

            default: row_data = 8'h00;
        endcase
    end

endmodule