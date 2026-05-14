`timescale 1ns / 1ps
//============================================================
// Módulo: vram_dual_port
//
// VRAM doble puerto inferible como Block RAM.
// Puerto A: lectura síncrona para VGA.
// Puerto B: escritura síncrona para generador de imagen.
//
// 
//  Incluye lógica write-forwardin:.
// ayuda a Vivado a inferir BRAM.
//============================================================

module vram_dual_port #(
    parameter WIDTH      = 8,
    parameter DEPTH      = 640*480,
    parameter ADDR_WIDTH = 19
)(
    input  wire clk,

    // Puerto A: lectura VGA
    input  wire [ADDR_WIDTH-1:0] addr_read,
    output reg  [WIDTH-1:0]      data_out,

    // Puerto B: escritura generador de imagen
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] addr_write,
    input  wire [WIDTH-1:0]      data_in
);

    (* ram_style = "block" *)
    reg [WIDTH-1:0] memory [0:DEPTH-1];

    // Lectura síncrona
    always @(posedge clk) begin
        data_out <= memory[addr_read];
    end

    // Escritura síncrona
    always @(posedge clk) begin
        if (we)
            memory[addr_write] <= data_in;
    end

endmodule