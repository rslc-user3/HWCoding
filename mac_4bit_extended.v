// Extended 4-bit MAC Unit with 16-bit Accumulator
// Used within Tile module for systolic array operations
// Description: Pipelined MAC with 16-bit accumulator for accurate result storage

module mac_4bit_extended (
    input  clk,              // Clock signal
    input  rst,              // Reset signal (active high)
    input  enable,           // Enable signal for MAC operation
    input  [3:0] a,          // 4-bit multiplicand
    input  [3:0] b,          // 4-bit multiplier
    output reg [15:0] acc_out // 16-bit accumulator output
);

    // Internal signals for pipelined operation
    reg [3:0] a_pipe, b_pipe;
    wire [7:0] product;
    wire [16:0] sum_result;  // 17-bit to capture overflow
    
    // Stage 1: Pipeline inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_pipe <= 4'b0;
            b_pipe <= 4'b0;
        end else if (enable) begin
            a_pipe <= a;
            b_pipe <= b;
        end
    end
    
    // Combinational multiplier (4x4 = 8 bits)
    assign product = a_pipe * b_pipe;
    
    // Adder: accumulate result
    // 16-bit accumulator + 8-bit product = 17-bit sum
    assign sum_result = acc_out + product;
    
    // Stage 2: Pipeline accumulator output
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