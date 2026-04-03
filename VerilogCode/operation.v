module operation(
    input wire clk,
    input wire calcWait,
    input wire [24:0] numberA,
    input wire [24:0] numberB,
    input wire [1:0] operationFlag,
    output reg done,
    output reg [24:0] binOut
);

localparam WAITING = 3'd0;
localparam ADDITION = 3'd1;
localparam SUBTRACTION = 3'd2;
localparam MULTIPLICATION = 3'd3;
localparam DIVISION = 3'd4;

localparam passedAdd = 2'd0;
localparam passedSub = 2'd1;
localparam passedMul = 2'd2;
localparam passedDiv = 2'd3;

reg [2:0] state = 0;

function [24:0] convert_bcd_to_bin;
    input [31:0] bcd;
    integer i;
    reg [24:0] temp;
    begin
        temp = 0;
        for (i = 7; i >= 0; i = i - 1) begin
            temp = temp * 10 + bcd[4*i +: 4];
        end
        convert_bcd_to_bin = temp;
    end
endfunction

always @(posedge clk) begin
    case (state)
        WAITING: begin
            done <= 0;
            if (calcWait) begin
                case (operationFlag)
                    passedAdd: state <= ADDITION;
                    passedSub: state <= SUBTRACTION;
                    passedMul: state <= MULTIPLICATION;
                    passedDiv: state <= DIVISION;
                endcase
            end
        end
        ADDITION: begin
            binOut <= convert_bcd_to_bin(numberA) + convert_bcd_to_bin(numberB);
            done <= 1;
            state <= WAITING;
        end
        SUBTRACTION: begin
            binOut <= 25'b00000_00000_00000_00000_00001;
            done <= 1;
            state <= WAITING;
        end
        MULTIPLICATION: begin
            binOut <= 25'b00000_00000_00000_00000_00010;
            done <= 1;
            state <= WAITING;
        end
        DIVISION: begin
            binOut <= 25'b00000_00000_00000_00000_00011;
            done <= 1;
            state <= WAITING;
        end
    endcase
end

endmodule