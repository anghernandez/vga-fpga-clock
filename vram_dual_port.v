`timescale 1ns / 1ps
//============================================================
// Módulo: vram_dual_port
// 
//   Memoria de video dual-port.
//   Puerto A: lectura para VGA.
//   Puerto B: escritura para actualización de contenido.
//   Diseñada para inferencia de BRAM.
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

    // Puerto B: escritura
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] addr_write,
    input  wire [WIDTH-1:0]      data_in
);

    (* ram_style = "block" *)
    reg [WIDTH-1:0] memory [0:DEPTH-1];

    always @(posedge clk) begin
        if (we && (addr_write == addr_read))
            data_out <= data_in;
        else
            data_out <= memory[addr_read];
    end

    always @(posedge clk) begin
        if (we)
            memory[addr_write] <= data_in;
    end

endmodule
