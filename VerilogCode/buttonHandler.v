// This module handles external push buttons. Features basic debouncing correction.

module buttonHandler (
    input wire clk,
    input wire [14:0] button,
    output reg [3:0] buttonOut 
);

reg [14:0] button_prev;
wire [14:0] button_rise = button & ~button_prev;
reg debounceActive;
reg [23:0] debounceCounter;

always @(posedge clk) begin

    // Edge detect
    button_prev <= button;

    // Debounce handling
    if (debounceActive) begin
        debounceCounter <= debounceCounter + 1;
        if (debounceCounter == 24'd3375000) begin  // 1/8 of a seccond
            debounceActive <= 0;
            debounceCounter <= 0;
        end
    end


    // Press detection
    if (|button_rise & ~debounceActive) begin
        debounceActive <= 1;
        if      (button_rise[0])  buttonOut <= 4'd1;
        else if (button_rise[1])  buttonOut <= 4'd2;
        else if (button_rise[2])  buttonOut <= 4'd3;
        else if (button_rise[3])  buttonOut <= 4'd4;
        else if (button_rise[4])  buttonOut <= 4'd5;
        else if (button_rise[5])  buttonOut <= 4'd6;
        else if (button_rise[6])  buttonOut <= 4'd7;
        else if (button_rise[7])  buttonOut <= 4'd8;
        else if (button_rise[8])  buttonOut <= 4'd9;
        else if (button_rise[9])  buttonOut <= 4'd10;
        else if (button_rise[10]) buttonOut <= 4'd11;
        else if (button_rise[11]) buttonOut <= 4'd12;
        else if (button_rise[12]) buttonOut <= 4'd13;
        else if (button_rise[13]) buttonOut <= 4'd14;
        else if (button_rise[14]) buttonOut <= 4'd15;
    end

    if (buttonOut != 0) begin
        buttonOut <= 0;  // Forces input to generate output for one clock cycle
    end
end

endmodule
