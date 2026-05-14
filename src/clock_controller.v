`timescale 1ns / 1ps

module clock_controller #(
    parameter TICK_MAX = 25_000_000 - 1
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       fmt_sel,
    input  wire       adj_sel,
    input  wire       btn_inc,
    input  wire       btn_dec,

    output reg  [4:0] hour_disp,
    output wire [5:0] minute,
    output wire [5:0] second,
    output wire       am_pm,
    output wire       fmt_sel_out,
    output reg        tick_1hz
);

    reg [24:0] tick_cnt;
    reg [4:0]  hours_int;
    reg [5:0]  minutes_int;
    reg [5:0]  seconds_int;
    reg        btn_inc_d, btn_dec_d;

    wire inc_pulse = btn_inc & ~btn_inc_d;
    wire dec_pulse = btn_dec & ~btn_dec_d;

    always @(posedge clk) begin
        if (reset) begin
            tick_cnt    <= 25'd0;
            tick_1hz    <= 1'b0;
            hours_int   <= 5'd0;
            minutes_int <= 6'd0;
            seconds_int <= 6'd0;
            btn_inc_d   <= 1'b0;
            btn_dec_d   <= 1'b0;
            hour_disp   <= 5'd0;
        end else begin
            tick_1hz  <= 1'b0;
            btn_inc_d <= btn_inc;
            btn_dec_d <= btn_dec;

            if (tick_cnt == TICK_MAX)
                tick_cnt <= 25'd0;
            else
                tick_cnt <= tick_cnt + 1'b1;

            if (inc_pulse) begin
                if (!adj_sel)
                    hours_int <= (hours_int == 5'd23) ? 5'd0 : hours_int + 1'b1;
                else
                    minutes_int <= (minutes_int == 6'd59) ? 6'd0 : minutes_int + 1'b1;
            end else if (dec_pulse) begin
                if (!adj_sel)
                    hours_int <= (hours_int == 5'd0) ? 5'd23 : hours_int - 1'b1;
                else
                    minutes_int <= (minutes_int == 6'd0) ? 6'd59 : minutes_int - 1'b1;
            end else if (tick_cnt == TICK_MAX) begin
                tick_1hz <= 1'b1;
                if (seconds_int == 6'd59) begin
                    seconds_int <= 6'd0;
                    if (minutes_int == 6'd59) begin
                        minutes_int <= 6'd0;
                        hours_int   <= (hours_int == 5'd23) ? 5'd0 : hours_int + 1'b1;
                    end else
                        minutes_int <= minutes_int + 1'b1;
                end else
                    seconds_int <= seconds_int + 1'b1;
            end

            if (!fmt_sel)
                hour_disp <= hours_int;
            else if (hours_int == 5'd0)
                hour_disp <= 5'd12;
            else if (hours_int > 5'd12)
                hour_disp <= hours_int - 5'd12;
            else
                hour_disp <= hours_int;
        end
    end

    assign minute      = minutes_int;
    assign second      = seconds_int;
    assign am_pm       = (hours_int >= 5'd12);
    assign fmt_sel_out = fmt_sel;

endmodule
