// Continuously multiplexes output on d1-d8 to display.
// Decodes hex value to corresponding led segments to be lit.

module sevenSegDriver (
    input clk,
    input [3:0] d1, d2, d3, d4, d5, d6, d7, d8,
    output reg [15:0] sevenSegOutput
);

reg [2:0] currentDigit = 0;
reg [15:0] refreshCounter = 0;

// Refresh counter to slow multiplexing
always @(posedge clk) begin
    refreshCounter <= refreshCounter + 1;
    if (refreshCounter == 0)
        currentDigit <= currentDigit + 1;
end

reg [3:0] digit_value;
reg [7:0] seg;
reg [7:0] disp;

// Digit selection
always @(*) begin
    case (currentDigit)
        3'd0: begin digit_value = d1; disp = 8'b11111110; end
        3'd1: begin digit_value = d2; disp = 8'b11111101; end
        3'd2: begin digit_value = d3; disp = 8'b11111011; end
        3'd3: begin digit_value = d4; disp = 8'b11110111; end
        3'd4: begin digit_value = d5; disp = 8'b11101111; end
        3'd5: begin digit_value = d6; disp = 8'b11011111; end
        3'd6: begin digit_value = d7; disp = 8'b10111111; end
        3'd7: begin digit_value = d8; disp = 8'b01111111; end
        default: begin digit_value = 4'd0; disp = 8'b11111111; end
    endcase
end

// 4-bit → 7-seg (hex 0–F)
always @(*) begin
    case (digit_value)
        4'h0: seg = 8'b00111111;
        4'h1: seg = 8'b00000110;
        4'h2: seg = 8'b01011011;
        4'h3: seg = 8'b01001111;
        4'h4: seg = 8'b01100110;
        4'h5: seg = 8'b01101101;
        4'h6: seg = 8'b01111101;
        4'h7: seg = 8'b00000111;
        4'h8: seg = 8'b01111111;
        4'h9: seg = 8'b01101111;
        4'hA: seg = 8'b00000000; // Null character
        4'hB: seg = 8'b01111001; // Character E
        4'hC: seg = 8'b01010000; // Character r
        4'hD: seg = 8'b01000000; // Negative sign (Currently unused)
        4'hE: seg = 8'b01011100; // Character o
        4'hF: seg = 8'b00000000; // Unused
        default: seg = 8'b11111111;
    endcase
end

// Combine outputs
always @(*) begin
    sevenSegOutput = {disp, seg};
end

endmodule