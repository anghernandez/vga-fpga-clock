`timescale 1ns / 1ps
//============================================================
// TOP: Sistema VGA con VRAM externa
//============================================================

module top_clock_vga(
    input  wire CLK100MHZ,
    input  wire reset,

    output wire VGA_HS,
    output wire VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    //========================================================
    // 1. División de reloj: 100 MHz -> 25 MHz
    //========================================================
    reg [1:0] clk_div = 2'b00;

    always @(posedge CLK100MHZ) begin
        if (reset)
            clk_div <= 2'b00;
        else
            clk_div <= clk_div + 1'b1;
    end

    wire clk_25mhz = clk_div[1];

    //========================================================
    // 2. Señales internas VGA / VRAM
    //========================================================
    wire [18:0] vram_addr_read;
    wire [7:0]  vram_data_out;
    wire [7:0]  vga_rgb;

    // Escritura a VRAM
    wire        vram_we;
    wire [18:0] vram_addr_write;
    wire [7:0]  vram_data_in;

    //========================================================
    // 3. Controlador VGA
    //========================================================
    vga_controller vga_controller_inst (
        .clk(clk_25mhz),
        .reset(reset),
        .vram_data(vram_data_out),

        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .rgb(vga_rgb),

        .vram_addr(vram_addr_read),
        .x(),
        .y(),
        .video_on()
    );

    //========================================================
    // 4. VRAM externa al controlador VGA
    //========================================================
    vram_dual_port #(
        .WIDTH(8),
        .DEPTH(640*480),
        .ADDR_WIDTH(19)
    ) vram_inst (
        .clk(clk_25mhz),

        // Puerto A: lectura VGA
        .addr_read(vram_addr_read),
        .data_out(vram_data_out),

        // Puerto B: escritura
        .we(vram_we),
        .addr_write(vram_addr_write),
        .data_in(vram_data_in)
    );

    //========================================================
    // 5. Generador temporal de imagen / fondo
    //    Luego aquí conectas tu módulo del reloj digital
    //========================================================
    vram_background_writer background_writer_inst (
        .clk(clk_25mhz),
        .reset(reset),

        .we(vram_we),
        .addr_write(vram_addr_write),
        .data_in(vram_data_in)
    );

    //========================================================
    // 6. Conversión RGB 8 bits -> VGA 12 bits
    // Formato asumido: rgb[7:5] = R, rgb[4:2] = G, rgb[1:0] = B
    //========================================================
    assign VGA_R = {vga_rgb[7:5], vga_rgb[7]};
    assign VGA_G = {vga_rgb[4:2], vga_rgb[4]};
    assign VGA_B = {vga_rgb[1:0], vga_rgb[1:0]};

endmodule