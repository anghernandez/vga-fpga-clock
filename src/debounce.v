`timescale 1ns / 1ps

module debounce (
    input  wire clk,
    input  wire reset,
    input  wire btn_in,
    output reg  btn_out
);

    localparam DEBOUNCE_MAX = 500_000 - 1;

    reg [1:0]  sync_ff;
    reg [19:0] cnt;

    always @(posedge clk) begin
        if (reset)
            sync_ff <= 2'b00;
        else
            sync_ff <= {sync_ff[0], btn_in};
    end

    always @(posedge clk) begin
        if (reset) begin
            cnt     <= 20'd0;
            btn_out <= 1'b0;
        end else if (sync_ff[1] != btn_out) begin
            if (cnt == DEBOUNCE_MAX) begin
                cnt     <= 20'd0;
                btn_out <= sync_ff[1];
            end else
                cnt <= cnt + 1'b1;
        end else
            cnt <= 20'd0;
    end

endmodule
