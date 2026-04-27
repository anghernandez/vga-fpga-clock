`timescale 1ns / 1ps
//============================================================
// Módulo: vram_background_writer
//
// Genera fondo usando coordenadas (x,y)
//============================================================

module vram_background_writer(
    input  wire clk,
    input  wire reset,

    output reg        we,
    output reg [18:0] addr_write,
    output reg [7:0]  data_in
);

    localparam DEPTH = 640*480;

    // Coordenadas derivadas de la dirección
    wire [9:0] x = addr_write % 640;
    wire [9:0] y = addr_write / 640;

    always @(posedge clk) begin
        if (reset) begin
            addr_write <= 19'd0;
            data_in    <= 8'd0;
            we         <= 1'b1;
        end else begin
            if (addr_write < DEPTH - 1) begin
                addr_write <= addr_write + 1'b1;
                we <= 1'b1;

                // Fondo: mitad superior roja, mitad inferior verde
                if (y < 240)
                    data_in <= 8'b111_000_00; // rojo
                else
                    data_in <= 8'b000_111_00; // verde

            end else begin
                we <= 1'b0;
            end
        end
    end

endmodule