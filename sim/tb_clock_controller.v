`timescale 1ns / 1ps

module tb_clock_controller;

    reg  clk, reset, fmt_sel, adj_sel, btn_inc, btn_dec;

    wire [4:0] hour_disp;
    wire [5:0] minute, second;
    wire       am_pm, fmt_sel_out, tick_1hz;

    clock_controller #(.TICK_MAX(9)) dut (
        .clk         (clk),
        .reset       (reset),
        .fmt_sel     (fmt_sel),
        .adj_sel     (adj_sel),
        .btn_inc     (btn_inc),
        .btn_dec     (btn_dec),
        .hour_disp   (hour_disp),
        .minute      (minute),
        .second      (second),
        .am_pm       (am_pm),
        .fmt_sel_out (fmt_sel_out),
        .tick_1hz    (tick_1hz)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task press_btn;
        input reg btn_signal;
        begin
            @(posedge clk); #1;
            btn_signal = 1'b1;
            @(posedge clk); #1;
            btn_signal = 1'b0;
        end
    endtask

    task wait_seconds;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                repeat(10) @(posedge clk);
        end
    endtask

    task check;
        input [63:0] got;
        input [63:0] expected;
        input [255:0] label;
        begin
            if (got !== expected)
                $display("FAIL [%0t] %s: got=%0d expected=%0d", $time, label, got, expected);
            else
                $display("PASS [%0t] %s = %0d", $time, label, got);
        end
    endtask

    integer i;

    initial begin
        reset = 1; fmt_sel = 0; adj_sel = 0;
        btn_inc = 0; btn_dec = 0;
        repeat(3) @(posedge clk);

        $display("\n=== TEST 1: Reset ===");
        @(posedge clk); #1;
        check(hour_disp, 0, "hour_disp tras reset");
        check(minute,    0, "minute tras reset");
        check(second,    0, "second tras reset");
        check(am_pm,     0, "am_pm tras reset");

        reset = 0;

        $display("\n=== TEST 2: Conteo segundos ===");
        wait_seconds(1); @(posedge clk); #1;
        check(second, 1, "second despues de 1s");
        wait_seconds(1); @(posedge clk); #1;
        check(second, 2, "second despues de 2s");
        wait_seconds(1); @(posedge clk); #1;
        check(second, 3, "second despues de 3s");

        $display("\n=== TEST 3: Rollover segundos a minutos ===");
        wait_seconds(56); @(posedge clk); #1;
        check(second, 59, "second = 59 justo antes de rollover");
        check(minute,  0, "minute antes de rollover");

        wait_seconds(1); @(posedge clk); #1;
        check(second, 0, "second tras rollover");
        check(minute, 1, "minute tras rollover");

        $display("\n=== TEST 4: Rollover minutos a horas ===");
        reset = 1; @(posedge clk); #1; reset = 0;

        adj_sel = 1;
        for (i = 0; i < 58; i = i + 1) begin
            @(posedge clk); #1; btn_inc = 1;
            @(posedge clk); #1; btn_inc = 0;
        end
        adj_sel = 0;
        @(posedge clk); #1;
        check(minute, 58, "minute = 58 tras ajuste");

        wait_seconds(120); @(posedge clk); #1;
        check(minute,    0, "minute = 0 tras rollover");
        check(hour_disp, 1, "hour_disp = 1 tras rollover");

        $display("\n=== TEST 5: Rollover horas (23->0) ===");
        reset = 1; @(posedge clk); #1; reset = 0;

        adj_sel = 0;
        for (i = 0; i < 23; i = i + 1) begin
            @(posedge clk); #1; btn_inc = 1;
            @(posedge clk); #1; btn_inc = 0;
        end
        @(posedge clk); #1;
        check(hour_disp, 23, "hour_disp = 23 (modo 24h)");

        wait_seconds(3600); @(posedge clk); #1;
        check(hour_disp, 0, "hour_disp = 0 tras rollover 23->0");

        $display("\n=== TEST 6: Formato 12h ===");
        reset = 1; @(posedge clk); #1; reset = 0;
        fmt_sel = 1;

        @(posedge clk); #1;
        check(hour_disp, 12, "12h: hora 0 -> display 12");
        check(am_pm,      0, "12h: hora 0 -> AM");

        adj_sel = 0;
        for (i = 0; i < 12; i = i + 1) begin
            @(posedge clk); #1; btn_inc = 1;
            @(posedge clk); #1; btn_inc = 0;
        end
        @(posedge clk); #1;
        check(hour_disp, 12, "12h: hora 12 -> display 12");
        check(am_pm,      1, "12h: hora 12 -> PM");

        @(posedge clk); #1; btn_inc = 1;
        @(posedge clk); #1; btn_inc = 0;
        @(posedge clk); #1;
        check(hour_disp, 1, "12h: hora 13 -> display 1");
        check(am_pm,     1, "12h: hora 13 -> PM");

        $display("\n=== TEST 7: Decremento horas ===");
        @(posedge clk); #1; btn_dec = 1;
        @(posedge clk); #1; btn_dec = 0;
        @(posedge clk); #1;
        check(hour_disp, 12, "dec: hora 13->12 -> display 12");

        reset = 1; @(posedge clk); #1; reset = 0;
        fmt_sel = 0;
        @(posedge clk); #1; btn_dec = 1;
        @(posedge clk); #1; btn_dec = 0;
        @(posedge clk); #1;
        check(hour_disp, 23, "dec: hora 0->23 (wrap)");

        $display("\n=== TEST 8: fmt_sel_out ===");
        fmt_sel = 1; @(posedge clk); #1;
        check(fmt_sel_out, 1, "fmt_sel_out con fmt_sel=1");
        fmt_sel = 0; @(posedge clk); #1;
        check(fmt_sel_out, 0, "fmt_sel_out con fmt_sel=0");

        $display("\n=== Simulacion completa ===");
        $finish;
    end

    initial begin
        $dumpfile("tb_clock_controller.vcd");
        $dumpvars(0, tb_clock_controller);
    end

endmodule
