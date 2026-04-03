// Double-dabble binary to BCD converter
// Converts 25-bit binary  to 8 BCD digits

module numberConverter (
    input  wire clk,
    input  wire startB,
    input  wire startD, // Unused
    input  wire [24:0] bin,
    input  wire [31:0] din,
    output reg  [3:0]  d1, d2, d3, d4, d5, d6, d7, d8,
    output reg done
);

    reg [24:0] binReg;
    reg [31:0] dinReg; // Unused
    reg [31:0] bcdReg;
    reg [31:0] bcdNext;
    reg [4:0]  count;
    reg busyB = 0;
    reg busyD = 0;

    always @(posedge clk) begin

         if (startD) begin
            dinReg <= din;
            count   <= 5'd0;
            done    <= 1'b0;
            busyD    <= 1'b1;
        end
        else if (busyD) begin

            bcdReg <= dinReg;

            busyD <= 1'b0;
            done <= 1'b1;
        end 
        if (startB && (bin == 25'b1111_1111_1111_1111_1111_1111_1)) begin
            bcdReg <= 32'h00000bcc;
            done <= 1'b1;
        end
        else if (startB && ~(bin == 25'b1111_1111_1111_1111_1111_1111_1)) begin
            binReg <= bin;
            bcdReg <= 32'd0;
            count   <= 5'd0;
            done    <= 1'b0;
            busyB    <= 1'b1;
        end
        else if (busyB) begin
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
                busyB <= 1'b0;
                done <= 1'b1;
            end
        end
    end

    // Connect outputs. Sets any leading zero values to hex A, corresponding to nothing displayed.
    always @(posedge clk) begin
            d8 <= (bcdReg[31:28] == 0) ? 4'hA : bcdReg[31:28];
            d7 <= (bcdReg[31:24] == 0) ? 4'hA : bcdReg[27:24];
            d6 <= (bcdReg[31:20] == 0) ? 4'hA : bcdReg[23:20];
            d5 <= (bcdReg[31:16] == 0) ? 4'hA : bcdReg[19:16];
            d4 <= (bcdReg[31:12] == 0) ? 4'hA : bcdReg[15:12];
            d3 <= (bcdReg[31: 8] == 0) ? 4'hA : bcdReg[11: 8];
            d2 <= (bcdReg[31: 4] == 0) ? 4'hA : bcdReg[ 7: 4];
            d1 <= bcdReg[3:0];
    end


endmodule