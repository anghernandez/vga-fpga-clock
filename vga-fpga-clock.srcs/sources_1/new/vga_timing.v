`timescale 1ns / 1ps
//============================================================
// Módulo: vga_timing
// 
//   Genera contadores horizontales/verticales para VGA
//   640x480 @60Hz con reloj de píxel de 25 MHz.
//============================================================

module vga_timing(
    input  wire clk,
    input  wire reset,

    output reg  [9:0] pixel_x,
    output reg  [9:0] pixel_y,
    output wire       video_on,
    output wire       hsync,
    output wire       vsync
);

    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    always @(posedge clk) begin
        if (reset) begin
            pixel_x <= 10'd0;
            pixel_y <= 10'd0;
        end else begin
            if (pixel_x == H_TOTAL - 1) begin
                pixel_x <= 10'd0;

                if (pixel_y == V_TOTAL - 1)
                    pixel_y <= 10'd0;
                else
                    pixel_y <= pixel_y + 1'b1;

            end else begin
                pixel_x <= pixel_x + 1'b1;
            end
        end
    end

    assign video_on = (pixel_x < H_VISIBLE) && (pixel_y < V_VISIBLE);

    assign hsync = ~((pixel_x >= H_VISIBLE + H_FRONT) &&
                     (pixel_x <  H_VISIBLE + H_FRONT + H_SYNC));

    assign vsync = ~((pixel_y >= V_VISIBLE + V_FRONT) &&
                     (pixel_y <  V_VISIBLE + V_FRONT + V_SYNC));

endmodule