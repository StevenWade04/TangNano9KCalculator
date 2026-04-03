`timescale 1ns / 1ps

module test;

    // Testbench signals
    reg         clk;
    reg         startB;
    reg         startD;
    reg  [24:0] bin;
    reg [31:0] din;
    wire [3:0]  d1, d2, d3, d4, d5, d6, d7, d8;
    wire        done;

    // Instantiate DUT
    numberConverter dut (
        .clk   (clk),
        .startB (startB),
        .startD (startD),
        .bin   (bin),
        .din (din),
        .d1    (d1), .d2(d2), .d3(d3), .d4(d4),
        .d5    (d5), .d6(d6), .d7(d7), .d8(d8),
        .done  (done)
    );

    // 50 MHz clock (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $dumpfile("numberConverter.vcd");
        $dumpvars(0, test);

        startB = 0;
        bin   = 25'd0;

        #100;

        // Test 1: 0
        bin = 25'd0;
        startB = 1; #20; startB = 0;
        wait(done);
        #40;
        $display("0     → %d %d %d %d %d %d %d %d", d8,d7,d6,d5,d4,d3,d2,d1);

        // Test 2: 1
        bin = 25'd1;
        startB = 1; #20; startB = 0;
        wait(done);
        #40;
        $display("1     → %d %d %d %d %d %d %d %d", d8,d7,d6,d5,d4,d3,d2,d1);

        // Test 3: 42
        bin = 25'd67;
        startB = 1; #20; startB = 0;
        wait(done);
        #40;
        $display("67    → %d %d %d %d %d %d %d %d", d8,d7,d6,d5,d4,d3,d2,d1);

        // Test 4: 999999 (should be 0999999 → but we show 8 digits)
        bin = 25'd999999;
        startB = 1; #20; startB = 0;
        wait(done);
        #40;
        $display("999999→ %d %d %d %d %d %d %d %d", d8,d7,d6,d5,d4,d3,d2,d1);

        // Test 5: max ~33M
        din = 32'b0000_0000_0000_0000_0000_0000_1000_0000;     // 2^25 - 1
        startD = 1; #20; startD = 0;
        wait(done);
        #40;
        $display("80   → %d %d %d %d %d %d %d %d", d8,d7,d6,d5,d4,d3,d2,d1);

                // Test 5: max ~33M
        din = 32'b0000_0000_0000_0000_0000_1000_1000_1000;     // 2^25 - 1
        startD = 1; #20; startD = 0;
        wait(done);
        #40;
        $display("888   → %d %d %d %d %d %d %d %d", d8,d7,d6,d5,d4,d3,d2,d1);

        #200;
        $display("Simulation finished.");
        $finish;
    end

endmodule