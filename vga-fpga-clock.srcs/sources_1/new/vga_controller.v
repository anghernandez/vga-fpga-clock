`timescale 1ns / 1ps
//============================================================
// Módulo: vga_controller
// 
//   Controlador VGA jerárquico.
//   Integra timing VGA, interfaz de memoria y salida RGB.
//============================================================

module vga_controller(
    input  wire       clk,        // 25 MHz
    input  wire       reset,
    input  wire [7:0] vram_data,

    output wire       hsync,
    output wire       vsync,
    output reg  [7:0] rgb,

    output wire [18:0] vram_addr,
    output reg  [9:0] x,
    output reg  [9:0] y,
    output reg        video_on
);

    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire       video_on_now;

    reg [9:0] pixel_x_d1;
    reg [9:0] pixel_y_d1;
    reg       video_on_d1;

    vga_timing timing_unit (
        .clk(clk),
        .reset(reset),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on_now),
        .hsync(hsync),
        .vsync(vsync)
    );

    vga_memory_interface memory_if (
        .clk(clk),
        .reset(reset),
        .video_on(video_on_now),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .vram_addr(vram_addr)
    );

    // Pipeline para alinear coordenadas/video_on con la lectura sincrónica de VRAM
    always @(posedge clk) begin
        if (reset) begin
            pixel_x_d1  <= 10'd0;
            pixel_y_d1  <= 10'd0;
            video_on_d1 <= 1'b0;
        end else begin
            pixel_x_d1  <= pixel_x;
            pixel_y_d1  <= pixel_y;
            video_on_d1 <= video_on_now;
        end
    end

    // Salidas registradas
    always @(posedge clk) begin
        if (reset) begin
            rgb      <= 8'd0;
            x        <= 10'd0;
            y        <= 10'd0;
            video_on <= 1'b0;
        end else begin
            x        <= pixel_x_d1;
            y        <= pixel_y_d1;
            video_on <= video_on_d1;

            if (video_on_d1)
                rgb <= vram_data;
            else
                rgb <= 8'd0;
        end
    end

endmodule