// Module runs state machine 

module calcStateMachine (
    input wire clk,
    input wire [3:0] buttonOut, // 1-cycle pulse input
    output reg [24:0] bin,
    output reg [31:0] din, // unused
    output reg startB, startD
);

localparam ENTER_A = 4'd0;
localparam ENTER_B = 4'd1;
localparam CALCULATE = 4'd2;
localparam SHOW_RESULT = 4'd3;
localparam ERROR = 4'd4; // Unused

reg [31:0] numberA = 0;
reg [31:0] numberB = 0;
reg [3:0] state = ENTER_A;
reg startB_next = 0;
reg [24:0] binOut;
//reg done;

// Function to convert the bcd input to binary, to be handled by the numberConverter. 
// This is a poor implementation and must be revised due to causing blowout in synthesis time.

reg [2:0] startDelayB;  // delayed pulse
reg [2:0] startDelayD;  // delayed pulse
reg finalDisp, calcWait;
reg [1:0] operationFlag;

operation operation (
    .clk(clk),
    .calcWait(calcWait),
    .numberA(numberA),
    .numberB(numberB),
    .done(done),
    .binOut(binOut),
    .operationFlag(operationFlag)
);

always @(posedge clk) begin

    startDelayB <= {startDelayB[1:0], 1'b0};  // shift
    startB <= startDelayB[2];  // pulse after delay

    startDelayD <= {startDelayD[1:0], 1'b0};  // shift
    startD <= startDelayD[2];  // pulse after delay


    case (state)
        ENTER_A: begin
            
            if (buttonOut >= 4'd1 && buttonOut <= 4'd9) begin // Inputs 1 through 9
                numberA <= (numberA << 4) | buttonOut;
                din <= (numberA << 4) | buttonOut;  // set din
                startDelayD[0] <= 1'b1;  
            end
            else if (buttonOut == 4'd11) begin // input Zero
                numberA <= (numberA << 4);
                din <= (numberA << 4);
                startDelayD[0] <= 1'b1;
            end
            else if (buttonOut == 4'd10) begin // Addition
                state <= ENTER_B;
                operationFlag <= 2'd0;
            end
            else if (buttonOut == 4'd13) begin // Subtraction
                state <= ENTER_B;
                operationFlag <= 2'd1;
            end 
            else if (|(numberA[31:28])) state <= ERROR;
        end

        ENTER_B: begin

            if (buttonOut >= 4'd1 && buttonOut <= 4'd9) begin
                numberB <= (numberB << 4) | buttonOut;
                din <= (numberB << 4) | buttonOut;
                startDelayD[0] <= 1'b1;
            end
            else if (buttonOut == 4'd11) begin
                numberB <= (numberB << 4);
                din <= (numberB << 4);
                startDelayD[0] <= 1'b1;
            end
            else if (buttonOut == 4'd12) begin
                state <= CALCULATE;
                calcWait <= 1'b1;
            end
            else if (|(numberB[31:28])) state <= ERROR;

        end

        CALCULATE: begin

            if (calcWait) begin
                calcWait <= 0;
            end else if (done) begin 
                state <= SHOW_RESULT;
                bin <= binOut;
                finalDisp <= 1;
            end
        end

        SHOW_RESULT: begin
            
            if (finalDisp) begin
                startDelayB[0] <= 1'b1;
                finalDisp <= 1'b0;
            end 
            else if (buttonOut == 4'd12) begin
                state <= ENTER_A;
                bin <= 0;
                startDelayB[0] <= 1'b1;
                numberA <= 0;
                numberB <= 0;
            end /*
            else if (buttonOut == 4'd10) begin
                state <= ENTER_B;
                //bin <= 0;
                //startDelayB[0] <= 1'b1;
                //numberA <= numberA + numberB;
                numberB <= 0;
            end */

        end

        ERROR: begin
            if (|numberA || |numberB) begin
                numberA <= 0;
                numberB <= 0;
                din <= 32'h00000bcc;
                startDelayD[0] <= 1;
            end 
            else if (buttonOut == 4'd12) begin
                state <= ENTER_A;
                bin <= 0;
                startDelayB[0] <= 1'b1;
            end
        end

        default: ;
    endcase
end

endmodule