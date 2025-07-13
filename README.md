# ENHANCED-TDMRC 
E-TDMRC (Enhanced Time-Divided Multi-Round Cipher) is a lightweight Verilog-based encryption algorithm using nonlinear congruential generators (NLCG) and modular key mixing. This reduced 5-byte version encrypts input using dynamic subkeys and outputs a 40-bit cipher and decrypted result. 

## Files
- `e_tdmrc.v`: Core modules and logic
- `tb_e_tdmrc.v `: Testbench for simulation
## 🔧 Features 
- 5-byte plaintext input
- 40-bit cipher output
- NLCG-based pseudo-random series
- Modular and synthesizable Verilog code
- Testbench included for simulation

## 🚀 How to Simulate 
1. Open in Vivado or any Verilog simulator.
2. Compile both `e_tdmrc.v` and `tb_e_tdmrc.v`.
3. Run the simulation.
4. Observe cipher and decrypted output
