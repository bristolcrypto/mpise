# ISEs for Multi-Precision Integer arithmetic

## Overview

We consider the RISC-V baseline ISA as being `rv64gc` meaning that the following standard extensions
  - M      (multiplication)
  - A      (atomic)
  - F      (single-precision floating-point)
  - D      (double-precision floating-point)
  - C      (compressed)

  are available by default.

## Implementations 

We plan to develop 4 types of implementation for each of X25519 and optimal Ate pairing over BLS12-381:

  |  Status  |  Radix   |  Implementation |  Algorithm         |
  | :------: | :------: | :-------------: | :----------------: |
  |  &check; |  full    |  isa-only       |  x25519            |
  |  &check; |  full    |  ise-assisted   |  x25519            |
  |  &check; |  reduced |  isa-only       |  x25519            |
  |  &check; |  reduced |  ise-assisted   |  x25519            |
  |  &check; |  full    |  isa-only       |  bls12-381 pairing |
  |  &check; |  full    |  ise-assisted   |  bls12-381 pairing |
  |  &check; |  reduced |  isa-only       |  bls12-381 pairing |
  |          |  reduced |  ise-assisted   |  bls12-381 pairing |

## Organization 

```
├── bin                     - scripts (e.g., environment configuration)
├── build                   - working directory for build
└── src                     - source code
    ├── hw                    - source code for hardware
    ├── hw-toolchain          - source code for hardware toolchain
    ├── sw                    - source code for software
    │   ├── bls12-381           - optimal Ate pairing over BLS12-381 
    │   │   ├── full-radix        - 64-bit-per-limb implementation   
    │   │   └── reduced-radix     - 55-bit-per-limb implementation   
    │   └── x25519              - x25519 key exchange
    │       ├── full-radix        - 64-bit-per-limb implementation   
    │       └── reduced-radix     - 51-bit-per-limb implementation  
    └── sw-toolchain          - source code for software toolchain
```

## Usage 

**TBA**