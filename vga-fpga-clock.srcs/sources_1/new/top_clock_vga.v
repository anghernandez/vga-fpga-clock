`timescale 1ns / 1ps
module top_clock_vga (
    input  wire       CLK100MHZ,
    input  wire       reset,
    input  wire [1:0] SW,
    input  wire       BTNU,
    input  wire       BTND,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    // ─────────────────────────────────────────────
    // Divisor de reloj: 100 MHz → 25 MHz
    // ─────────────────────────────────────────────
    reg [1:0] clk_div = 2'b00;
    always @(posedge CLK100MHZ) begin
        if (reset)
            clk_div <= 2'b00;
        else
            clk_div <= clk_div + 1'b1;
    end
    wire clk_25mhz = clk_div[1];

    // ─────────────────────────────────────────────
    // Wires VRAM
    // ─────────────────────────────────────────────
    wire [18:0] vram_addr_read;
    wire [7:0]  vram_data_out;
    wire [7:0]  vga_rgb;
    wire        vram_we;
    wire [18:0] vram_addr_write;
    wire [7:0]  vram_data_in;

    // ─────────────────────────────────────────────
    // VGA controller
    // ─────────────────────────────────────────────
    vga_controller vga_controller_inst (
        .clk       (clk_25mhz),
        .reset     (reset),
        .vram_data (vram_data_out),
        .hsync     (VGA_HS),
        .vsync     (VGA_VS),
        .rgb       (vga_rgb),
        .vram_addr (vram_addr_read),
        .x         (),
        .y         (),
        .video_on  ()
    );

    // ─────────────────────────────────────────────
    // VRAM dual-port
    // ─────────────────────────────────────────────
    vram_dual_port #(
        .WIDTH     (8),
        .DEPTH     (640*480),
        .ADDR_WIDTH(19)
    ) vram_inst (
        .clk       (clk_25mhz),
        .addr_read (vram_addr_read),
        .data_out  (vram_data_out),
        .we        (vram_we),
        .addr_write(vram_addr_write),
        .data_in   (vram_data_in)
    );

    // ─────────────────────────────────────────────
    // Debounce
    // ─────────────────────────────────────────────
    wire btn_inc_db, btn_dec_db;

    debounce debounce_inc (
        .clk    (clk_25mhz),
        .reset  (reset),
        .btn_in (BTNU),
        .btn_out(btn_inc_db)
    );
    debounce debounce_dec (
        .clk    (clk_25mhz),
        .reset  (reset),
        .btn_in (BTND),
        .btn_out(btn_dec_db)
    );

    // ─────────────────────────────────────────────
    // Clock controller
    // ─────────────────────────────────────────────
    wire [4:0] hour_disp;
    wire [5:0] minute;
    wire [5:0] second;
    wire       am_pm;
    wire       fmt_sel_out;
    wire       tick_1hz;

    clock_controller clock_ctrl_inst (
        .clk         (clk_25mhz),
        .reset       (reset),
        .fmt_sel     (SW[0]),
        .adj_sel     (SW[1]),
        .btn_inc     (btn_inc_db),
        .btn_dec     (btn_dec_db),
        .hour_disp   (hour_disp),
        .minute      (minute),
        .second      (second),
        .am_pm       (am_pm),
        .fmt_sel_out (fmt_sel_out),
        .tick_1hz    (tick_1hz)
    );

    // ─────────────────────────────────────────────
    // Reconstruir hora en formato 24h
    // fmt_sel_out=0 → 24h directo
    // fmt_sel_out=1 → 12h, reconstruir con am_pm
    //   AM: 12→0, resto igual
    //   PM: 12→12, resto +12
    // ─────────────────────────────────────────────
    wire [4:0] hour24 =
        (!fmt_sel_out) ? hour_disp :
        (am_pm == 1'b0) ?
            (hour_disp == 5'd12 ? 5'd0  : hour_disp) :
            (hour_disp == 5'd12 ? 5'd12 : hour_disp + 5'd12);

    // ─────────────────────────────────────────────
    // Phase
    //   DAWN  00 → 00:00-05:59
    //   DAY   01 → 06:00-11:59
    //   DUSK  10 → 12:00-17:59
    //   NIGHT 11 → 18:00-23:59
    // ─────────────────────────────────────────────
    wire [1:0] phase =
        (hour24 < 5'd6)  ? 2'b00 :
        (hour24 < 5'd12) ? 2'b01 :
        (hour24 < 5'd18) ? 2'b10 :
                           2'b11;

    // ─────────────────────────────────────────────
    // Posición Y fija del astro por fase
    // ─────────────────────────────────────────────
    wire [9:0] astro_cy =
        (phase == 2'b00) ? 10'd240 :
        (phase == 2'b01) ? 10'd60  :
        (phase == 2'b10) ? 10'd240 :
                           10'd180;

    // ─────────────────────────────────────────────
    // Background writer - bg_color instanciado adentro
    // ─────────────────────────────────────────────
    vram_background_writer background_writer_inst (
        .clk       (clk_25mhz),
        .reset     (reset),
        .we        (vram_we),
        .addr_write(vram_addr_write),
        .data_in   (vram_data_in),
        .hour_disp (hour_disp),
        .minute    (minute),
        .second    (second),
        .am_pm     (am_pm),
        .fmt_sel   (fmt_sel_out),
        .tick_1hz  (tick_1hz),
        .phase     (phase),
        .astro_cy  (astro_cy)
    );

    // ─────────────────────────────────────────────
    // Expansión RGB332 → 4 bits por canal
    // ─────────────────────────────────────────────
    assign VGA_R = {vga_rgb[7:5], vga_rgb[7]};
    assign VGA_G = {vga_rgb[4:2], vga_rgb[4]};
    assign VGA_B = {vga_rgb[1:0], vga_rgb[1:0]};

endmodule