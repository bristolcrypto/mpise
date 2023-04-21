# ISEs for Multi-Precision Integer arithmetic

## Overview

- We consider the RISC-V baseline ISA as being `rv64gc` meaning that the following standard extensions
  - M      (multiplication)
  - A      (atomic)
  - F      (single-precision floating-point)
  - D      (double-precision floating-point)
  - C      (compressed)

  are available by default.

## Implementations 

- We plan to develop 4 types of implementation for each of X25519 and optimal Ate pairing over BLS12-381:
  - [x] full-radix    pure-software  x25519
  - [x] full-radix    ISE-assisted   x25519
  - [x] reduced-radix pure-software  x25519
  - [x] reduced-radix ISE-assisted   x25519
  - [ ] full-radix    pure-software  BLS12-381 pairing
  - [ ] full-radix    ISE-assisted   BLS12-381 pairing
  - [ ] reduced-radix pure-software  BLS12-381 pairing
  - [ ] reduced-radix ISE-assisted   BLS12-381 pairing

## Organization 

```
├── bin                       - scripts (e.g., environment configuration)
├── doc                       - documentation (e.g., encoding and design)
├── src                       - source code
│   ├── hw                    - hardware part
│   │   ├── fpga                - source code for the FPGA implementation using Vivado
│   │   │   ├── board             - source for supporting targeted boards (i.e., sakura-x and arty100T)
│   │   │   ├── script            - scripts for handling the FPGA bitstream on Vivado
│   │   │   ├── soc               - the Vivado projects based on the Rocket Chip SoC.
│   │   │   └── software          - build algorithm-specific sofware running on the FPGA.
│   │   ├── rocketchip          - source code for ISE-enabled Rocket Chip
│   │   ├── rtl                 - rtl implementation
│   │   │   ├── rvzbk             - Implementation of RV64Zbk ISE
│   │   │   ├── bls12-381         - Implementation of RV64 bls12-381 ISE
│   │   │   └── x25519            - Implementation of RV64 x25519    ISE
│   │   └── verilator         - source code for emulator for use with Rocket Chip 
│   │
│   ├── bls12-381             - bls12-381 implementations
│   │   ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│   │   └── reduced-radix         - radix-2^55 (pure-sw + ise-assisted)
│   └── x25519                - x25519 implementations
│       ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│       └── reduced-radix         - radix-2^51 (pure-sw + ise-assisted)
├── bitstream                 - pre-built bitstreams for the arty100T board 
├── hw-toolchain              - scripts to install RISC-V hardware toolchains 
├── sw-toolchain              - scripts to install RISC-V software toolchains 
└── work                      - working directory for build
```

## Usage 

**TBA**