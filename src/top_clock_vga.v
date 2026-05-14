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

    reg [1:0] clk_div = 2'b00;

    always @(posedge CLK100MHZ) begin
        if (reset)
            clk_div <= 2'b00;
        else
            clk_div <= clk_div + 1'b1;
    end

    wire clk_25mhz = clk_div[1];

    wire [18:0] vram_addr_read;
    wire [7:0]  vram_data_out;
    wire [7:0]  vga_rgb;
    wire        vram_we;
    wire [18:0] vram_addr_write;
    wire [7:0]  vram_data_in;

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

    vram_background_writer background_writer_inst (
        .clk        (clk_25mhz),
        .reset      (reset),
        .we         (vram_we),
        .addr_write (vram_addr_write),
        .data_in    (vram_data_in),
        .hour_disp  (hour_disp),
        .minute     (minute),
        .second     (second),
        .am_pm      (am_pm),
        .fmt_sel    (fmt_sel_out),
        .tick_1hz   (tick_1hz)
    );

    assign VGA_R = {vga_rgb[7:5], vga_rgb[7]};
    assign VGA_G = {vga_rgb[4:2], vga_rgb[4]};
    assign VGA_B = {vga_rgb[1:0], vga_rgb[1:0]};

endmodule
