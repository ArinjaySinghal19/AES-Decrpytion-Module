# AES Decryption Hardware Implementation

## Overview
This project implements a complete **AES (Advanced Encryption Standard) Decryption Module** in hardware using VHDL, specifically designed for the **Basys 3 FPGA board**. The implementation follows the standard AES-128 decryption algorithm with a complete 10-round (including initial round) decryption process. The system performs full hardware-based AES decryption with real-time display of results on 7-segment displays.

## Architecture Overview

The system is organized into several key components working together to perform AES decryption through three main operational phases:

- **Phase 0**: Data loading and state initialization from memory
- **Phase 1**: AES decryption processing (controlled by finite state machine)  
- **Phase 2**: Result display on 7-segment displays with scrolling output

## Key Components

### 1. **Main Control Unit (`main_control.vhd`)**
The central orchestrator that manages the entire decryption process:

- **Memory Interface Management**: Controls RAM and ROM access for input data and round keys
- **Component Coordination**: Manages all AES compute units (AddRoundKey, InvMixColumns, InvShiftRows, InvSubBytes)
- **Data Flow Control**: Handles 128-bit state management and byte-level processing
- **Phase Management**: Coordinates three-phase operation cycle
- **Output Organization**: Arranges final results into 4×32-bit rows for display

**Key Signals:**
- `whole_state`: 128-bit internal AES state
- `current_process`: Controls three-phase operation (0=load, 1=decrypt, 2=display)
- `row_output_1-4`: Final decrypted result organized for display

### 2. **Finite State Machine (`fsm.vhd`)**
Sophisticated state controller managing the step-by-step AES decryption:

- **Round Management**: Handles 10 rounds of decryption (rounds 0-9)
- **Process Control**: Manages 4 different operations per round:
  - Process 0: AddRoundKey operation (XOR with round key)
  - Process 1: InvMixColumns operation (Galois Field arithmetic)
  - Process 2: InvShiftRows operation (row shifting)
  - Process 3: InvSubBytes operation (S-box substitution)
- **Step Sequencing**: Controls individual steps within each process (0-8 steps depending on operation)
- **Timing Control**: Built-in delay mechanisms (10 clock cycles) for proper synchronization
- **Special Round Handling**: Different logic for first round (round 0) and final round (round 9)

### 3. **Memory Architecture**

#### **State RAM (`blk_mem_gen_0`)**
- **Purpose**: Stores 128-bit input ciphertext blocks
- **Capacity**: 32 bytes (supports multiple test vectors)
- **Addressing**: 5-bit addresses (32 locations)
- **Data Width**: 8-bit (byte-addressable)
- **Access Pattern**: Sequential byte loading during Phase 0

#### **Round Key ROM (`blk_mem_gen_1`)**  
- **Purpose**: Contains all pre-computed round keys
- **Capacity**: 160 bytes (10 rounds × 16 bytes)
- **Addressing**: 8-bit addresses (256 locations)
- **Data Source**: Initialized from `round.coe` file
- **Key Schedule**: Eliminates need for real-time key expansion
- **Access Pattern**: `(9-round_number)*16 + byte_index` for reverse round order

#### **Inverse S-box ROM (`blk_mem_gen_2`)**
- **Purpose**: Lookup table for InvSubBytes operation
- **Capacity**: 256 entries (complete 8-bit to 8-bit mapping)
- **Addressing**: Direct 8-bit input value
- **Data Source**: Initialized from `sbox_inv.coe` file
- **Usage**: Byte substitution during InvSubBytes process

### 4. **AES Compute Units**

#### **AddRoundKey (`AddRoundKey.vhd`)**
- **Operation**: Bitwise XOR between state bytes and round key bytes
- **Implementation**: `state_out <= state_in XOR round_key`
- **Data Width**: 8-bit (processes one byte per clock cycle)
- **Timing**: Single clock cycle operation
- **Usage**: Applied in all rounds, fundamental AES operation

#### **InvMixColumns (`InvMixColums.vhd`)**
- **Operation**: Inverse MixColumns transformation using Galois Field (GF(2⁸)) arithmetic
- **Matrix Multiplication**: Uses constants 0x0E, 0x0B, 0x0D, 0x09
- **Optimized Functions**:
  - `xtimes_02`: Multiplication by 2 in GF(2⁸) with polynomial reduction
  - `xtimes_04`, `xtimes_08`: Higher powers using recursive doubling
  - `xtimes_09`, `xtimes_0b`, `xtimes_0d`, `xtimes_0e`: Specific matrix constants
- **Data Processing**: 32-bit columns (4 bytes) processed simultaneously
- **Implementation**: Combinational logic with polynomial arithmetic (x^8 + x^4 + x^3 + x + 1)

#### **InvShiftRows (`InvShiftRows.vhd`)**  
- **Operation**: Performs inverse row shifting (right circular shifts)
- **Shift Patterns**:
  - Row 0: No shift (num_shift = "00")
  - Row 1: Shift right by 1 position (num_shift = "01")
  - Row 2: Shift right by 2 positions (num_shift = "10")
  - Row 3: Shift right by 3 positions (num_shift = "11")
- **Data Width**: 32-bit rows (4 bytes)
- **Implementation**: Multiplexer-based bit concatenation

#### **InvSubBytes (`InvSubBytes.vhd`)**
- **Operation**: Inverse byte substitution using lookup table
- **Address Calculation**: 
  - `row <= state_in(7 downto 4)` (upper 4 bits)
  - `col <= state_in(3 downto 0)` (lower 4 bits)
  - `addr <= row & col` (8-bit address)
- **ROM Interface**: Connects to inverse S-box ROM component
- **Timing**: Two clock cycle operation (address setup + data read)

### 5. **Display System (`display.vhd`)**

Advanced 7-segment display controller with scrolling capability:

- **Multiplexed Display**: Time-division multiplexing of 4 digits
- **Character Support**: 
  - Digits: 0-9 (ASCII 0x30-0x39)
  - Hex: A-F (ASCII 0x41-0x46, 0x61-0x66)
  - Default: "-" for unsupported characters
- **Refresh Rate**: 50,000 clock cycles per digit update
- **Display Sequence**: Shows 16 bytes of result in 4 groups of 4 characters
- **Output Signals**: Individual segment controls (A-G) and anode selection

## Algorithm Implementation

### AES Decryption Flow

The implementation follows standard AES decryption with proper round structure:

1. **Initial Round (Round 0)**:
   - AddRoundKey with round key 10
   - InvShiftRows
   - InvSubBytes
   - (No InvMixColumns in initial round)

2. **Main Rounds (Rounds 1-8)**:
   - AddRoundKey with round keys 9-2
   - InvMixColumns  
   - InvShiftRows
   - InvSubBytes

3. **Final Round (Round 9)**:
   - AddRoundKey with round key 1
   - (No InvMixColumns in final round)

### Data Flow and State Management

1. **Input Loading (Phase 0)**:
   - Sequential loading of 16 bytes from RAM
   - Assembly into 128-bit `updated_state`
   - Transition to `whole_state` for processing

2. **Round Processing (Phase 1)**:
   - Byte-by-byte and column-by-column transformations
   - State updates through `whole_state` register
   - Final round result stored in `row_output_1-4`

3. **Display Output (Phase 2)**:
   - Sequential display of 4 result rows
   - Scrolling presentation on 7-segment displays
   - Automatic cycling back to Phase 0

## Memory Initialization and Test Data

### Input Data Format (`input_128_bits.coe`)
```
memory_initialization_radix = 10;
memory_initialization_vector = 90, 245, 253, 134, 212, 243, 146, 128, 203, 155, 136, 100, 17, 136, 107, 222;
; Expected output F5C392a1A1339b88
```

### Round Keys (`round.coe`)  
- **Format**: Hexadecimal values
- **Content**: 160 bytes of pre-computed round keys
- **Organization**: 10 rounds × 16 bytes per round
- **Access**: Reverse order (round 10 keys first, round 1 keys last)

### S-box Data (`sbox_inv.coe`)
- **Content**: Complete 256-entry inverse S-box lookup table
- **Format**: Standard AES inverse S-box values
- **Usage**: Direct lookup for InvSubBytes transformation

## Performance Characteristics

### Timing Analysis
- **Total Latency**: ~2,000-3,000 clock cycles per 128-bit block
- **Round Latency**: ~200-300 cycles per round
- **Memory Access**: 1-2 cycles per byte operation
- **Display Update**: 50,000 cycles per digit refresh

### Resource Utilization
- **Memory Blocks**: 3 BRAM instances (input, keys, S-box)
- **Logic Elements**: Arithmetic units, multiplexers, state registers
- **Clock Domains**: Single clock domain design
- **I/O Requirements**: 7-segment display pins, clock, reset

## Testing and Verification

### Test Strategy
- **Known Test Vectors**: Verified against standard AES test cases
- **Expected Output**: "F5C392a1A1339b88" for given input
- **Simulation**: Comprehensive testbenches for all components
- **Hardware Validation**: FPGA implementation testing

### Debugging Features
- **Status Outputs**: `fsmd`, `upd`, `segd` for phase monitoring
- **Internal Signals**: Extensive signal exposure for debugging
- **Commented Outputs**: Optional debug outputs for development

## Hardware Implementation

### Target Platform
- **FPGA**: Basys 3 Board (Xilinx Artix-7)
- **Tools**: Vivado Design Suite
- **Clock**: System clock (typically 100 MHz)
- **I/O**: 7-segment display, reset button

### Design Methodology
- **Modular Architecture**: Clear separation of functional units
- **Synchronous Design**: All operations clock-synchronized
- **Reset Strategy**: Comprehensive reset handling
- **Memory Management**: Efficient BRAM utilization

## Usage and Development

### Building the Project
1. Clone the repository to your local machine
2. Open Vivado Design Suite
3. Create a new project and add all VHDL source files
4. Generate memory components using Vivado's IP Catalog:
   - Configure Block Memory Generator for RAM (blk_mem_gen_0)
   - Configure Block Memory Generator for ROM (blk_mem_gen_1) 
   - Configure Block Memory Generator for S-box (blk_mem_gen_2)
5. Initialize memories using provided COE files:
   - `input_128_bits.coe` for input data
   - `round.coe` for round keys
   - `sbox_inv.coe` for inverse S-box
6. Set `main_control` as the top-level entity
7. Synthesize and implement the design
8. Generate bitstream and program the Basys 3 board

### Pin Configuration
Configure the following pins for Basys 3 board:
- **Clock**: W5 (100 MHz system clock)
- **Reset**: T18 (center button)
- **7-Segment Display**:
  - Segments A-G: W7, W6, U8, V8, U5, V5, U7
  - Anodes: U2, U4, V4, W4

### Simulation and Testing
1. Use provided testbenches:
   - `main_control_tb.vhd`: Full system simulation
   - `fsm_tb.vhd`: FSM verification
2. Run behavioral simulation in Vivado
3. Verify waveforms against expected AES decryption behavior
4. Check timing constraints and critical path analysis

## Advanced Features

### Multiple Input Support
- System supports multiple input sets via `max_input_set` parameter
- Automatic cycling between different test vectors
- Memory addressing: `16*current_input_set + byte_offset`

### Debug and Monitoring
- **Status Signals**:
  - `fsmd`: FSM completion status
  - `upd`: Update process completion
  - `segd`: Segment display completion
- **Internal State Access**: Comprehensive signal monitoring capabilities
- **Phase Indicators**: Clear separation of operational phases

### Extensibility
- **AES-192/256 Support**: Architecture can be extended for longer key lengths
- **Pipeline Optimization**: Design supports future pipelining enhancements
- **Custom S-boxes**: Easy replacement of S-box content via COE files
- **Additional Interfaces**: UART, SPI, or other communication protocols can be added

## Technical Specifications

### Clock Domain
- **Single Clock Design**: All operations synchronized to system clock
- **Clock Frequency**: Supports up to 100 MHz on Basys 3
- **Reset Strategy**: Synchronous reset with proper initialization

### Memory Requirements
- **Total BRAM Usage**: 3 memory blocks
  - Input RAM: 32 bytes (256 bits)
  - Round Key ROM: 160 bytes (1,280 bits)  
  - S-box ROM: 256 bytes (2,048 bits)
- **Logic Utilization**: Moderate LUT and FF usage
- **DSP Blocks**: Not required (pure logic implementation)

### Power Consumption
- **Static Power**: Typical FPGA static consumption
- **Dynamic Power**: Dependent on clock frequency and switching activity
- **Optimization**: Clock gating opportunities in display refresh logic

## Known Limitations and Future Work

### Current Limitations
- **Throughput**: Single-block processing (no pipeline)
- **Key Management**: Static key storage (no dynamic key input)
- **Interface**: Limited to 7-segment display output
- **Error Handling**: Minimal error detection and recovery

### Future Enhancements
- **Pipeline Implementation**: Multi-stage pipeline for higher throughput
- **Key Schedule**: Real-time key expansion from initial key
- **Communication Interfaces**: UART, SPI, or Ethernet connectivity
- **Error Correction**: Built-in error detection and correction codes
- **Performance Optimization**: Critical path optimization for higher frequencies

## File Structure and Dependencies

### Source Files Hierarchy
```
Source/
├── FSM/
│   ├── main_control.vhd    (Top-level controller)
│   └── fsm.vhd            (State machine)
├── Compute Units/
│   ├── AddRoundKey.vhd    (XOR operation)
│   ├── InvMixColums.vhd   (GF arithmetic)
│   ├── InvShiftRows.vhd   (Row shifting)
│   ├── InvSubBytes.vhd    (S-box lookup)
│   └── sbox_rom.vhd       (S-box memory interface)
├── Display/
│   └── display.vhd        (7-segment controller)
├── COE Files/
│   ├── input_128_bits.coe (Test vectors)
│   ├── round.coe          (Round keys)
│   └── sbox_inv.coe       (Inverse S-box)
└── Testing/
    ├── main_control_tb.vhd (System testbench)
    ├── fsm_tb.vhd         (FSM testbench)
    └── clock_util.txt     (Timing utilities)
```

### Component Dependencies
- `main_control` depends on all compute units and memory blocks
- All components require IEEE standard libraries
- Memory blocks require Vivado IP core generation
- Testbenches require simulation libraries

## Troubleshooting

### Common Issues
1. **Memory Initialization Failures**:
   - Verify COE file paths and formats
   - Check memory block configurations in IP Catalog
   - Ensure correct radix settings (decimal vs. hexadecimal)

2. **Timing Violations**:
   - Analyze critical paths in timing reports
   - Consider clock frequency reduction
   - Add pipeline registers if necessary

3. **Display Issues**:
   - Verify pin assignments for 7-segment display
   - Check anode/cathode polarity
   - Confirm refresh rate settings

4. **Simulation Mismatches**:
   - Verify reset sequences and initialization values
   - Check clock edge sensitivity
   - Validate memory initialization data

### Debug Strategies
- Use ChipScope or ILA for in-system debugging
- Monitor phase control signals for proper sequencing
- Verify memory read/write operations
- Check FSM state transitions in simulation

## Contributors
- Arinjay Singhal
- Vihaan Luhariwala

## Course Information
- Course: COL215: Digital Logic and System Design
- Institution: Indian Institute of Technology Delhi
