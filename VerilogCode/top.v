module top
(
    input clk,
    input [14:0] button,
    output [7:0] seg,
    output [7:0] disp    
);

// Input to number converter, binary number
reg [24:0] bin;
reg [31:0] din; // unused
// 4-bit digits passed from numberConverter to sevenSegDriver
// Start requires high for one clock cycle to begin, done exists for testing only
wire [3:0] digitOne;
wire [3:0] digitTwo;
wire [3:0] digitThree;
wire [3:0] digitFour;
wire [3:0] digitFive;
wire [3:0] digitSix;
wire [3:0] digitSeven;
wire [3:0] digitEight;
wire done;
reg startD; // unused
reg startB;

// Output from sevenSegDriver, assigned directly to display's continuously to handle multiplexing
reg [15:0] sevenSegOutput;

// Button handling, output one cycle non zero value
reg [3:0] buttonOut;


numberConverter converter (
    .clk(clk),
    .bin(bin),
    .din(din),
    .d1(digitOne),
    .d2(digitTwo),
    .d3(digitThree),
    .d4(digitFour),
    .d5(digitFive),
    .d6(digitSix),
    .d7(digitSeven),
    .d8(digitEight),
    .done  (done),
    .startB  (startB),
    .startD (startD)
);

sevenSegDriver driver (
    .clk(clk),
    .d1(digitOne),
    .d2(digitTwo),
    .d3(digitThree),
    .d4(digitFour),
    .d5(digitFive),
    .d6(digitSix),
    .d7(digitSeven),
    .d8(digitEight),
    .sevenSegOutput(sevenSegOutput)
);


buttonHandler buttonH (
    .clk(clk),
    .button(button),
    .buttonOut(buttonOut)
);


calcStateMachine calcStateMachine (
    .clk(clk),
    .buttonOut(buttonOut),
    .bin(bin),
    .din(din),
    .startB(startB),
    .startD(startD)
);

// Output assignment

assign seg  = sevenSegOutput[7:0];
assign disp = sevenSegOutput[15:8];

endmodule