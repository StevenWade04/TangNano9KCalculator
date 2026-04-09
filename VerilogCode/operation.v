module operation(
    input wire clk,
    input wire calcWait,
    input wire [31:0] numberA,
    input wire [31:0] numberB,
    input wire [1:0] operationFlag,
    output reg done,
    output reg [24:0] binOut
);

localparam WAITING = 3'd0;
localparam ADDITION = 3'd1;
localparam SUBTRACTION = 3'd2;
localparam MULTIPLICATION = 3'd3;
localparam DIVISION = 3'd4;
localparam CONVERT = 3'd5;

localparam passedAdd = 2'd0;
localparam passedSub = 2'd1;
localparam passedMul = 2'd2;
localparam passedDiv = 2'd3;

reg [2:0] state = 0;
reg [1:0] opperand = 0;
reg [24:0] binA;
reg [24:0] binB;
reg [3:0] counter;
reg [3:0] digitA, digitB;

always @(posedge clk) begin
    case (state)
        WAITING: begin
            done <= 0;
            if (calcWait) begin
                state <= CONVERT;
                opperand <= operationFlag;
            end else begin 
                opperand <= 0;
                counter <= 0;
                counterPrev <= 0;
                binA <= 0;
                binB <= 0;
            end
        end
        CONVERT: begin
            if (counter == 8) state <= opperand + 1'b1;
            else begin
                digitA = numberA[31 - counter*4 -: 4];
                digitB = numberB[31 - counter*4 -: 4];

                binA <= (binA << 3) + (binA << 1) + digitA;
                binB <= (binB << 3) + (binB << 1) + digitB;

                counter <= counter + 1;
            end
        end
        ADDITION: begin
            binOut <= binA + binB;
            done <= 1;
            state <= WAITING;
        end
        SUBTRACTION: begin
            binOut <= binA - binB;
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