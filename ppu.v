// Processing Unit (PPU) with Variable Number of Tiles
// Hierarchical systolic array architecture with shared cache
// Description: PPU_Cache distributes data to multiple Tile units in parallel

module ppu #(
    parameter NUM_TILES = 4,                    // Number of Tile units
    parameter CACHE_DEPTH = 1024,               // PPU Cache depth (words)
    parameter CACHE_WIDTH = 32,                 // PPU Cache width (bits)
    parameter TILE_INPUT_SRAM_DEPTH = 256,     // Input SRAM depth per Tile
    parameter TILE_INPUT_SRAM_WIDTH = 8,       // Input SRAM width per Tile
    parameter TILE_OUTPUT_SRAM_DEPTH = 256,    // Output SRAM depth per Tile
    parameter TILE_OUTPUT_SRAM_WIDTH = 16,     // Output SRAM width per Tile
    parameter CACHE_ADDR_WIDTH = 10,           // Address width for cache
    parameter TILE_ADDR_WIDTH_IN = 8,          // Address width for Tile input SRAM
    parameter TILE_ADDR_WIDTH_OUT = 8          // Address width for Tile output SRAM
) (
    input  clk,                                 // Clock signal
    input  rst,                                 // Reset signal (active high)
    
    // External PPU Cache Port (to load data from external source)
    input  [CACHE_ADDR_WIDTH-1:0] cache_ext_wr_addr,     // External write address
    input  [CACHE_WIDTH-1:0] cache_ext_wr_data,          // External write data
    input  cache_ext_wr_en,                              // External write enable
    
    // PPU Cache read ports (one per Tile)
    input  [TILE_ADDR_WIDTH_IN-1:0] cache_rd_addr [NUM_TILES-1:0],  // Read addresses from Tiles
    output [TILE_INPUT_SRAM_WIDTH-1:0] cache_data [NUM_TILES-1:0],  // Read data to Tiles
    
    // Tile control signals (broadcasted to all tiles)
    input  tile_enable,                        // Enable all Tiles
    
    // Tile output data (from all Tiles)
    output [TILE_OUTPUT_SRAM_WIDTH-1:0] tile_out [NUM_TILES-1:0]
);

    // PPU Cache SRAM
    reg [CACHE_WIDTH-1:0] ppu_cache [0:CACHE_DEPTH-1];
    
    // Internal signals for data distribution
    wire [TILE_INPUT_SRAM_WIDTH-1:0] cache_data_internal [NUM_TILES-1:0];
    
    // Generate logic for each Tile
    genvar i, j;
    
    // Cache write operation (external port)
    always @(posedge clk) begin
        if (cache_ext_wr_en) begin
            ppu_cache[cache_ext_wr_addr] <= cache_ext_wr_data;
        end
    end
    
    // Cache read operations for each Tile
    generate
        for (i = 0; i < NUM_TILES; i = i + 1) begin : cache_read_ports
            // Extract relevant bits from cache for each Tile
            // Can read 8-bit, 16-bit, or 32-bit words depending on configuration
            assign cache_data[i] = ppu_cache[cache_rd_addr[i]][TILE_INPUT_SRAM_WIDTH-1:0];
        end
    endgenerate
    
    // Instantiate variable number of Tile units
    generate
        for (i = 0; i < NUM_TILES; i = i + 1) begin : tile_array
            tile #(
                .INPUT_SRAM_DEPTH(TILE_INPUT_SRAM_DEPTH),
                .INPUT_SRAM_WIDTH(TILE_INPUT_SRAM_WIDTH),
                .OUTPUT_SRAM_DEPTH(TILE_OUTPUT_SRAM_DEPTH),
                .OUTPUT_SRAM_WIDTH(TILE_OUTPUT_SRAM_WIDTH),
                .ADDR_WIDTH_IN(TILE_ADDR_WIDTH_IN),
                .ADDR_WIDTH_OUT(TILE_ADDR_WIDTH_OUT)
            ) tile_inst (
                .clk(clk),
                .rst(rst),
                
                // Input SRAM interface (data from PPU Cache)
                .in_sram_rd_addr(cache_rd_addr[i]),
                .in_sram_data(cache_data[i]),
                .in_sram_wr_en(1'b0),           // Tiles read-only from PPU Cache
                .in_sram_wr_addr('d0),
                .in_sram_wr_data('d0),
                
                // Output SRAM interface (results)
                .out_sram_rd_addr('d0),
                .out_sram_data(tile_out[i]),
                .out_sram_wr_en(1'b0),
                .out_sram_wr_addr('d0),
                .out_sram_wr_data('d0),
                
                // MAC control (broadcasted)
                .mac_a(),
                .mac_b(),
                .mac_enable(tile_enable),
                .mac_out()
            );
        end
    endgenerate

endmodule
