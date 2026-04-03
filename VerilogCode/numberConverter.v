// Changed numberConverter to use a more clearly defined state machine.
// This will improve clarity to the module, and ideally allow the passthrough of correctly
// formatted BCD values without the current conversion that takes place in calcStateMachine.
// Idealy should also handle negative numbers
// Maintaining this as a very general file, to allow its use in future projects.

module numberConverter (
    input  wire clk,
    input  wire startB, 
    input  wire startD, // startB, startD are pulsed high one clock cycle to begin.
    input  wire [24:0] bin, // Input to be converted first
    input  wire [31:0] din, // Input to be passed through directly
    output reg  [3:0]  d1, d2, d3, d4, d5, d6, d7, d8,
    output reg done // Only required for testing.
);


localparam Waiting = 3'd0;
localparam BcdHandling = 3'd1;
localparam BinInitialization = 3'd2;
localparam BinHandlingPos = 3'd3;
localparam BinHandlingNeg = 3'd4;

reg [2:0] state = Waiting;
reg latchB, latchD;


reg [24:0] binReg;
reg [31:0] dinReg; // Unused
reg [31:0] bcdReg = 0;
reg [31:0] bcdNext;
reg [4:0]  count;
reg busyB = 0;
reg busyD = 0;

always @(posedge clk) begin

    if (startB) begin
        latchB <= 1;
        state <= Waiting;
    end else if (startD) begin
        latchD <= 1;
        state <= Waiting;
    end

    case (state)

    Waiting: begin

        if (latchB) begin
            state <= BinInitialization;
            latchB <= 0;
        end else if (latchD) begin
            state <= BcdHandling;
            latchD <= 0;
        end
        done <= 0;

    end

    BcdHandling: begin

        bcdReg <= din;
        done <= 1;
        state <= Waiting;

    end

    BinInitialization: begin

        binReg <= bin;
        bcdReg <= 32'd0;
        count   <= 5'd0;
        if (!bin[24]) state <= BinHandlingPos;
        else state <= BinHandlingNeg;

    end

    BinHandlingPos: begin

        // Double-dabble binary to BCD converter

        if (count < 25) begin
            bcdNext = bcdReg; // blocking assignment (combinational temp)

            // Add 3 step
            if (bcdNext[ 3: 0] >= 5) bcdNext[ 3: 0] = bcdNext[ 3: 0] + 3;
            if (bcdNext[ 7: 4] >= 5) bcdNext[ 7: 4] = bcdNext[ 7: 4] + 3;
            if (bcdNext[11: 8] >= 5) bcdNext[11: 8] = bcdNext[11: 8] + 3;
            if (bcdNext[15:12] >= 5) bcdNext[15:12] = bcdNext[15:12] + 3;
            if (bcdNext[19:16] >= 5) bcdNext[19:16] = bcdNext[19:16] + 3;
            if (bcdNext[23:20] >= 5) bcdNext[23:20] = bcdNext[23:20] + 3;
            if (bcdNext[27:24] >= 5) bcdNext[27:24] = bcdNext[27:24] + 3;
            if (bcdNext[31:28] >= 5) bcdNext[31:28] = bcdNext[31:28] + 3;

            // Shift 
            bcdReg <= {bcdNext[30:0], binReg[24]};
            binReg <= {binReg[23:0], 1'b0};

            count <= count + 1'b1;
        end
        else begin
            state <= Waiting;
            done <= 1'b1;
        end

    end

    BinHandlingNeg: begin

        if (binReg[24] && !count) begin
            binReg <= ~binReg + 1;
        end else if (count < 25) begin
            bcdNext = bcdReg; // blocking assignment (combinational temp)

            // Add 3 step
            if (bcdNext[ 3: 0] >= 5) bcdNext[ 3: 0] = bcdNext[ 3: 0] + 3;
            if (bcdNext[ 7: 4] >= 5) bcdNext[ 7: 4] = bcdNext[ 7: 4] + 3;
            if (bcdNext[11: 8] >= 5) bcdNext[11: 8] = bcdNext[11: 8] + 3;
            if (bcdNext[15:12] >= 5) bcdNext[15:12] = bcdNext[15:12] + 3;
            if (bcdNext[19:16] >= 5) bcdNext[19:16] = bcdNext[19:16] + 3;
            if (bcdNext[23:20] >= 5) bcdNext[23:20] = bcdNext[23:20] + 3;
            if (bcdNext[27:24] >= 5) bcdNext[27:24] = bcdNext[27:24] + 3;
            if (bcdNext[31:28] >= 5) bcdNext[31:28] = bcdNext[31:28] + 3;

            // Shift 
            bcdReg <= {bcdNext[30:0], binReg[24]};
            binReg <= {binReg[23:0], 1'b0};

            count <= count + 1'b1;
        end
        else begin
            if (!bcdReg[31:4]) bcdReg[7:4] <= 4'hd;
            else if (!bcdReg[31:8]) bcdReg[11:8] <= 4'hd;
            else if (!bcdReg[31:12]) bcdReg[15:12] <= 4'hd;
            else if (!bcdReg[31:16]) bcdReg[19:16] <= 4'hd;
            else if (!bcdReg[31:20]) bcdReg[23:20] <= 4'hd;
            else if (!bcdReg[31:24]) bcdReg[27:24] <= 4'hd;
            else if (!bcdReg[31:28]) bcdReg[31:28] <= 4'hd;
            state <= Waiting;
            done <= 1'b1;
        end

    end

    endcase

    d8 <= (bcdReg[31:28] == 0) ? 4'hA : bcdReg[31:28];
    d7 <= (bcdReg[31:24] == 0) ? 4'hA : bcdReg[27:24];
    d6 <= (bcdReg[31:20] == 0) ? 4'hA : bcdReg[23:20];
    d5 <= (bcdReg[31:16] == 0) ? 4'hA : bcdReg[19:16];
    d4 <= (bcdReg[31:12] == 0) ? 4'hA : bcdReg[15:12];
    d3 <= (bcdReg[31: 8] == 0) ? 4'hA : bcdReg[11: 8];
    d2 <= (bcdReg[31: 4] == 0) ? 4'hA : bcdReg[ 7: 4];
    d1 <= bcdReg[3:0];

    //if ((d8 != 4'hA)||(d8 != 4'hD)) bcdReg <= 8'h00000bcc;

end

endmodule