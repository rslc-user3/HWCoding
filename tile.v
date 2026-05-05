// Tile Module with Variable-Size SRAM and 4 MACs
// Efficient systolic array element for tensor operations
// Description: Provides data from input SRAM to 4 parallel MACs, stores results in output SRAM

module tile #(
    parameter INPUT_SRAM_DEPTH = 256,   // Input SRAM depth (words)
    parameter INPUT_SRAM_WIDTH = 8,     // Input SRAM width (bits)
    parameter OUTPUT_SRAM_DEPTH = 256,  // Output SRAM depth (words)
    parameter OUTPUT_SRAM_WIDTH = 16,   // Output SRAM width (bits, for accumulator results)
    parameter ADDR_WIDTH_IN = 8,        // Address width for input SRAM
    parameter ADDR_WIDTH_OUT = 8        // Address width for output SRAM
) (
    input  clk,                         // Clock signal
    input  rst,                         // Reset signal (active high)
    
    // Input SRAM control
    input  [ADDR_WIDTH_IN-1:0] in_sram_rd_addr,  // Input SRAM read address
    output [INPUT_SRAM_WIDTH-1:0] in_sram_data,  // Input SRAM read data
    input  in_sram_wr_en,                        // Input SRAM write enable
    input  [ADDR_WIDTH_IN-1:0] in_sram_wr_addr,  // Input SRAM write address
    input  [INPUT_SRAM_WIDTH-1:0] in_sram_wr_data, // Input SRAM write data
    
    // Output SRAM control
    input  [ADDR_WIDTH_OUT-1:0] out_sram_rd_addr, // Output SRAM read address
    output [OUTPUT_SRAM_WIDTH-1:0] out_sram_data, // Output SRAM read data
    input  out_sram_wr_en,                        // Output SRAM write enable
    input  [ADDR_WIDTH_OUT-1:0] out_sram_wr_addr, // Output SRAM write address
    input  [OUTPUT_SRAM_WIDTH-1:0] out_sram_wr_data, // Output SRAM write data
    
    // MAC Control
    input  [3:0] mac_a [3:0],           // 4-bit operands for 4 MACs
    input  [3:0] mac_b [3:0],
    input  mac_enable,                  // Enable all MACs
    output [15:0] mac_out [3:0]         // 16-bit outputs from 4 MACs
);

    // Internal SRAM arrays
    reg [INPUT_SRAM_WIDTH-1:0] input_sram [0:INPUT_SRAM_DEPTH-1];
    reg [OUTPUT_SRAM_WIDTH-1:0] output_sram [0:OUTPUT_SRAM_DEPTH-1];
    
    // Internal MAC accumulator outputs
    wire [15:0] mac_acc [3:0];
    
    // Input SRAM read operation
    assign in_sram_data = input_sram[in_sram_rd_addr];
    
    // Input SRAM write operation
    always @(posedge clk) begin
        if (in_sram_wr_en) begin
            input_sram[in_sram_wr_addr] <= in_sram_wr_data;
        end
    end
    
    // Output SRAM read operation
    assign out_sram_data = output_sram[out_sram_rd_addr];
    
    // Output SRAM write operation
    always @(posedge clk) begin
        if (out_sram_wr_en) begin
            output_sram[out_sram_wr_addr] <= out_sram_wr_data;
        end
    end
    
    // Instantiate 4 MAC units
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : mac_array
            mac_4bit_extended mac_inst (
                .clk(clk),
                .rst(rst),
                .enable(mac_enable),
                .a(mac_a[i]),
                .b(mac_b[i]),
                .acc_out(mac_acc[i])
            );
        end
    endgenerate
    
    // Connect MAC outputs
    assign mac_out[0] = mac_acc[0];
    assign mac_out[1] = mac_acc[1];
    assign mac_out[2] = mac_acc[2];
    assign mac_out[3] = mac_acc[3];

endmodule
