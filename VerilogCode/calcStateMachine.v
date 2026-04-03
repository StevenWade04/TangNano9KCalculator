// Module runs state machine 

module calcStateMachine (
    input wire clk,
    input wire [3:0] buttonOut, // 1-cycle pulse input
    output reg [24:0] bin,
    output reg [31:0] din, // unused
    output reg startB, startD
);

localparam ENTER_A = 3'd0;
localparam ENTER_B = 3'd1;
localparam SHOW_RESULT = 3'd2;
localparam ERROR = 3'd3; // Unused

reg [31:0] numberA = 0;
reg [31:0] numberB = 0;
reg [2:0] state = ENTER_A;
reg startB_next = 0;

// Function to convert the bcd input to binary, to be handled by the numberConverter. 
// This is a poor implementation and must be revised due to causing blowout in synthesis time.

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

reg [2:0] startDelay;  // delayed pulse
reg finalDisp;
reg subFlag;

always @(posedge clk) begin

    startDelay <= {startDelay[1:0], 1'b0};  // shift
    startB <= startDelay[2];  // pulse after delay


    case (state)
        ENTER_A: begin
            
            if (buttonOut >= 4'd1 && buttonOut <= 4'd9) begin
                numberA <= (numberA << 4) | buttonOut;
                bin <= convert_bcd_to_bin((numberA << 4) | buttonOut);  // compute bin now
                startDelay[0] <= 1'b1;  // this sets output HIGH **next clock**
            end
            else if (buttonOut == 4'd11) begin
                numberA <= (numberA << 4);
                bin <= convert_bcd_to_bin(numberA << 4);
                startDelay[0] <= 1'b1;
            end
            else if (buttonOut == 4'd10) begin
                state <= ENTER_B;
                subFlag <= 0;
            end
            else if (buttonOut == 4'd13) begin
                state <= ENTER_B;
                subFlag <= 1;
            end 
            else if (|(numberA[31:28])) state <= ERROR;
        end

        ENTER_B: begin

            if (buttonOut >= 4'd1 && buttonOut <= 4'd9) begin
                numberB <= (numberB << 4) | buttonOut;
                bin <= convert_bcd_to_bin((numberB << 4) | buttonOut);
                startDelay[0] <= 1'b1;
            end
            else if (buttonOut == 4'd11) begin
                numberB <= (numberB << 4);
                bin <= convert_bcd_to_bin(numberB << 4);
                startDelay[0] <= 1'b1;
            end
            else if (buttonOut == 4'd12) begin
                state <= SHOW_RESULT;
                finalDisp <= 1'b1;
            end
            else if (|(numberB[31:28])) state <= ERROR;
            /*
            else if (buttonOut == 4'd10) begin
                numberA <= numberA + numberB;
                numberB <= 0;
                finalDisp <= 1'b1;
            end
            else if (finalDisp) begin
                bin <= numberA;
                finalDisp <= 0;
                startDelay[0] = 1'b1;
            end */

        end

        SHOW_RESULT: begin
            
            if ((numberA) < (numberB)) state = ERROR;
            else if (finalDisp && ~(subFlag)) begin
                bin <= convert_bcd_to_bin(numberA) + convert_bcd_to_bin(numberB);
                startDelay[0] <= 1'b1;
                finalDisp <= 1'b0;
            end 
            else if (finalDisp && subFlag) begin
                bin <= convert_bcd_to_bin(numberA) - convert_bcd_to_bin(numberB);
                startDelay[0] <= 1'b1;
                finalDisp <= 1'b0;
            end 
            else if (buttonOut == 4'd12) begin
                state <= ENTER_A;
                bin <= 0;
                startDelay[0] <= 1'b1;
                numberA <= 0;
                numberB <= 0;
            end
            else if (buttonOut == 4'd10) begin
                state <= ENTER_B;
                //bin <= 0;
                //startDelay[0] <= 1'b1;
                numberA <= numberA + numberB;
                numberB <= 0;
            end

        end

        ERROR: begin
            if (|numberA || |numberB) begin
                numberA <= 0;
                numberB <= 0;
                bin <= 25'b1111_1111_1111_1111_1111_1111_1;
                startDelay[0] <= 1;
            end 
            else if (buttonOut == 4'd12) begin
                state <= ENTER_A;
                bin <= 0;
                startDelay[0] <= 1'b1;
            end
        end

        default: ;
    endcase
end

endmodule