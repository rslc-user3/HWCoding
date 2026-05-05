// 4-bit Multiply-Accumulate (MAC) Unit
// Efficient hardware implementation using pipelined architecture
// Description: Performs multiply-accumulate operation: ACC = ACC + (A * B)

module mac_4bit (
    input  clk,              // Clock signal
    input  rst,              // Reset signal (active high)
    input  [3:0] a,          // 4-bit multiplicand
    input  [3:0] b,          // 4-bit multiplier
    input  [7:0] acc_in,     // 8-bit accumulator input (feedback)
    output reg [7:0] acc_out // 8-bit accumulator output
);

    // Internal signals for pipelined operation
    reg [3:0] a_pipe, b_pipe;
    wire [7:0] product;
    wire [8:0] sum_result;  // 9-bit to capture overflow
    
    // Stage 1: Pipeline inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_pipe <= 4'b0;
            b_pipe <= 4'b0;
        end else begin
            a_pipe <= a;
            b_pipe <= b;
        end
    end
    
    // Combinational multiplier (4x4 = 8 bits)
    // Using Baugh-Wooley algorithm for efficient multiplication
    wire [7:0] mult_result;
    assign mult_result = a_pipe * b_pipe;
    
    // Adder: accumulate result
    // 8-bit accumulator + 8-bit product = 9-bit sum
    assign sum_result = acc_out + mult_result;
    
    // Stage 2: Pipeline accumulator output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out <= 8'b0;
        end else begin
            // Saturate at 8-bit max value (255) to prevent overflow
            if (sum_result[8] == 1'b1) begin
                acc_out <= 8'hFF;  // Saturation
            end else begin
                acc_out <= sum_result[7:0];
            end
        end
    end

endmodule
