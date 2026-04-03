`timescale 1ns / 1ps

module test;

    // Testbench signals
    reg clk;
    reg [3:0] buttonOut;

    wire [24:0] din;
    wire [31:0] bin;
    wire startB;
    wire startD;

    // Instantiate DUT
    calcStateMachine dut (
        .clk(clk),
        .buttonOut(buttonOut),
        .din(din),
        .bin(bin),
        .startB(startB),
        .startD(startD)
    );

    // 50 MHz clock (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // ✅ FIXED: proper 1-cycle pulse (drive on negedge)
    task press;
        input [3:0] val;
        begin
            @(negedge clk);
            buttonOut = val;

            @(negedge clk);
            buttonOut = 4'd0;
        end
    endtask

    // Stimulus
    initial begin
        $dumpfile("calcStateMachine.vcd");
        $dumpvars(0, test);

        buttonOut = 0;

        #100;

        // =========================
        // Test 1: Enter "1"
        // =========================
        press(4'd1);
        #40;
        $display("Input: 1   → din = %d | startB = %b", din, startB);

        // =========================
        // Test 2: Enter "12"
        // =========================
        press(4'd2);
        #40;
        $display("Input: 12  → din = %d | startB = %b", din, startB);

        // =========================
        // Test 3: Enter "123"
        // =========================
        press(4'd3);
        #40;
        $display("Input: 123 → din = %d | startB = %b", din, startB);

        // =========================
        // Test 4: Add zero (button 11)
        // =========================
        press(4'd11);
        #40;
        $display("Input: 1230 → din = %d | startB = %b", din, startB);

        // =========================
        // Test 5: Multiple rapid presses
        // =========================
        press(4'd4);
        press(4'd5);
        press(4'd6);
        #60;
        $display("Input: 1230456 → din = %d | startB = %b", din, startB);

        #200;
        $display("Simulation finished.");
        $finish;
    end

    // Live monitor
    initial begin
        $monitor("T=%0t | btn=%d | din=%d | startB=%b",
                  $time, buttonOut, din, startB);
    end

endmodule