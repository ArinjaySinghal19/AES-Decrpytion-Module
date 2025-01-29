# AES Decryption Hardware Implementation

## Overview
This project implements AES (Advanced Encryption Standard) decryption in hardware using VHDL. The implementation is designed for the Basys 3 FPGA board and includes memory components (RAM/ROM) and logical units for performing AES decryption operations. The decrypted plaintext is displayed on a 7-segment display.

## Features
- Complete AES decryption implementation
- Support for 128-bit block size
- 8-round decryption process
- Memory components using Vivado's Memory Generator
  - ROM for storing input text and keys
  - RAM for storing intermediate results
- Hardware modules for all AES operations:
  - InvMixColumns with GF(2⁸) multiplication
  - InvShiftRows
  - InvSubBytes using lookup tables
  - AddRoundKey (XOR operation)
- Seven-segment display output
  - Scrolling text display
  - Support for hexadecimal characters (0-F)
  - Cyclic display of 4 characters at a time

## Components
1. Memory Units
   - Read-Only Memory (ROM) for input text and key storage
   - Read-Write Memory (RAM) for output storage
   - Distributed Memory Generator implementation

2. Compute Units
   - MAC GF(2⁸) unit for Galois Field multiplication
   - Multiplexers for InvRowShift operation
   - Lookup tables for InvSubBytes
   - Gate array for XOR operations

3. Display Unit
   - Seven-segment display controller
   - ASCII to display conversion
   - Scrolling text implementation

## Hardware Requirements
- Basys 3 FPGA Board
- Vivado Design Suite

## Implementation Details
- The AES decryption process follows the standard inverse operations:
  1. InvShiftRows
  2. InvSubBytes
  3. AddRoundKey
  4. InvMixColumns
- Memory implementation uses Vivado's Distributed Memory Generator
- GF(2⁸) multiplication is implemented using shift and XOR operations
- Seven-segment display supports characters 0-F, with "-" for out-of-range characters

## Usage
1. Clone the repository
2. Open the project in Vivado Design Suite
3. Generate memory components using Vivado's IP Catalog
4. Synthesize and implement the design
5. Program the Basys 3 board

## Testing
- Testbenches are provided for all major components
- Use the included COE files for initializing ROM contents
- Simulation should be verified before FPGA implementation

## Documentation
- Detailed implementation report included
- Block diagrams and module descriptions available
- Waveform simulations for verification

## Contributors
- Arinjay Singhal
- Vihaan Luhariwala

## Course Information
- Course: COL215: Digital Logic and System Design
- Institution: Indian Institute of Technology Delhi
