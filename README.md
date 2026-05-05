# HWCoding - VerilogCoder Adder Design

This repository contains Verilog implementations of hardware designs generated using Nvidia's VerilogCoder approach.

## Project Overview

**VerilogCoder** is an AI-powered tool for automating Verilog code generation. This project demonstrates its application in creating hardware components, starting with an 8-bit binary adder.

## Contents

### 1. **adder.v**
A parameterized 8-bit full adder module with the following features:
- **8-bit operands** (a, b)
- **Carry input** (cin) for chaining multiple adders
- **Sum output** (8 bits)
- **Carry output** (cout) for overflow detection
- Uses **generate blocks** for scalable, clean RTL design
- Full adder logic at each bit position

#### Module Ports:
```verilog
module adder (
    input  [7:0] a,     // First operand
    input  [7:0] b,     // Second operand
    input        cin,   // Carry input
    output [7:0] sum,   // Sum result
    output       cout   // Carry output
);
```

### 2. **adder_tb.v**
Comprehensive testbench with 6 test cases covering:
- Simple addition without carry
- Addition with carry input
- Overflow scenarios
- Large number operations
- Maximum value with carry
- Zero addition edge case

## How to Simulate

### Using ModelSim or Vivado:
```bash
# Compile the modules
vlog adder.v adder_tb.v

# Simulate
vsim adder_tb

# View waveforms
run -all
```

### Using open-source tools (Icarus Verilog):
```bash
iverilog -o adder_sim adder.v adder_tb.v
vvp adder_sim
```

## Design Highlights

1. **Full Adder Cell**: Implements standard full adder logic (S = A XOR B XOR Cin, Cout = AB + Cin(A XOR B))
2. **Carry Propagation**: Ripple-carry architecture for straightforward implementation
3. **Scalability**: Easy to extend to different bit widths by modifying the input/output widths
4. **Clean RTL**: Uses generate blocks for readable, maintainable code

## Verification Results

Expected behavior for test cases:
| A   | B   | Cin | Sum | Cout |
|-----|-----|-----|-----|------|
| 3   | 5   | 0   | 8   | 0    |
| 15  | 1   | 1   | 17  | 0    |
| 255 | 1   | 0   | 0   | 1    |
| 170 | 85  | 0   | 255 | 0    |
| 255 | 255 | 1   | 255 | 1    |
| 0   | 0   | 0   | 0   | 0    |

## Future Enhancements

- [ ] Implement carry-lookahead adder (CLA) for faster operation
- [ ] Add pipelined adder variant
- [ ] Create parametric version with configurable bit width
- [ ] Add formal verification using SVA
- [ ] Compare timing/area with synthesized implementations

## References

- Nvidia VerilogCoder: AI-assisted Verilog code generation
- IEEE 754 floating-point adder extensions
- ASIC design best practices

---

**Generated using VerilogCoder approach** - Rapid hardware prototyping with AI assistance
