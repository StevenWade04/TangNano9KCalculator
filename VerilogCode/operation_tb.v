`timescale 1ns / 1ps

module test;

    reg         clk;
    reg         calcWait;
    wire         done;
    wire [24:0] binOut;
    reg [24:0] numberA;
    reg [24:0] numberB;
    reg [1:0] operationFlag;

    operation dut (
        .clk(clk),
        .calcWait(calcWait),
        .done(done),
        .binOut(binOut),
        .numberA(numberA),
        .numberB(numberB),
        .operationFlag(operationFlag)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        numberA = 25'b1;
        numberB = 25'b1;
        operationFlag = 2'b00;
        calcWait = 1; 
        #20; 
        calcWait = 0;
        wait(done);
        #40;
        $display("0 → %d", binOut);

        $finish;
    end

endmodule