`timescale 1ns / 1ps
//============================================================
// Módulo: vga_memory_interface
// 
//   Calcula la dirección de lectura de VRAM.
//   Asume resolución visible de 640x480.
//============================================================

module vga_memory_interface(
    input  wire       clk,
    input  wire       reset,
    input  wire       video_on,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,

    output reg  [18:0] vram_addr
);

    always @(posedge clk) begin
        if (reset) begin
            vram_addr <= 19'd0;
        end else begin
            if (video_on)
                vram_addr <= (pixel_y << 9) + (pixel_y << 7) + pixel_x; // y*640 + x
            else
                vram_addr <= 19'd0;
        end
    end

endmodule