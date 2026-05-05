// 8-bit Full Adder Module
// Generative Design using VerilogCoder approach
// Description: This module implements an 8-bit binary adder with carry in/out

module adder (
    input  [7:0] a,           // First operand (8 bits)
    input  [7:0] b,           // Second operand (8 bits)
    input        cin,         // Carry input
    output [7:0] sum,         // Sum output (8 bits)
    output       cout         // Carry output
);

    // Internal signals for carry propagation
    wire [8:0] carry;
    
    // Assign carry input
    assign carry[0] = cin;
    
    // Generate adder stages for each bit
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : adder_stage
            // Full adder logic for each bit
            assign sum[i] = a[i] ^ b[i] ^ carry[i];
            assign carry[i+1] = (a[i] & b[i]) | (carry[i] & (a[i] ^ b[i]));
        end
    endgenerate
    
    // Assign carry output
    assign cout = carry[8];

endmodule
