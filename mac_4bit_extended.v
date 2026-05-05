// Extended 4-bit MAC with 16-bit accumulator
// Description: Enhanced MAC for use in Tile with wider accumulator

module mac_4bit_extended (
    input  clk,              // Clock signal
    input  rst,              // Reset signal (active high)
    input  enable,           // Enable signal
    input  [3:0] a,          // 4-bit multiplicand
    input  [3:0] b,          // 4-bit multiplier
    output reg [15:0] acc_out // 16-bit accumulator output
);

    wire [7:0] product;
    wire [16:0] sum_result;  // 17-bit to capture overflow
    
    // Combinational multiplier (4x4 = 8 bits)
    assign product = a * b;
    
    // Adder: accumulate result
    assign sum_result = acc_out + product;
    
    // Synchronous accumulator update
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out <= 16'b0;
        end else if (enable) begin
            // Saturate at 16-bit max value (65535) to prevent overflow
            if (sum_result[16] == 1'b1) begin
                acc_out <= 16'hFFFF;  // Saturation
            end else begin
                acc_out <= sum_result[15:0];
            end
        end
    end

endmodule
