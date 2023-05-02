# ISEs for Multi-Precision Integer arithmetic

<!--- ==================================================================== --->

## Overview

We consider the RISC-V baseline ISA as being `rv64gc` meaning that the following standard extensions
  - M      (multiplication)
  - A      (atomic)
  - F      (single-precision floating-point)
  - D      (double-precision floating-point)
  - C      (compressed)

  are available by default.

<!--- ==================================================================== --->

## Implementations 

We plan to develop below 8 implementations of X25519 and optimal Ate
pairing over BLS12-381 as the case studies:

  |  Algorithm         |  Radix   |  Type            |  Software                                           |  Hardware  |
  | :----------------: | :------: | :--------------: | :-------------------------------------------------: | :--------: |
  |  x25519            |  full    |  isa-only        |  [o](./src/sw/x25519/full-radix/src/asm/isa/)       |  o         |
  |  x25519            |  full    |  ise-assisted    |  [o](./src/sw/x25519/full-radix/src/asm/ise/)       |  o         |
  |  x25519            |  reduced |  isa-only        |  [o](./src/sw/x25519/reduced-radix/src/asm/isa/)    |  o         |
  |  x25519            |  reduced |  ise-assisted    |  [o](./src/sw/x25519/reduced-radix/src/asm/ise/)    |  o         |
  |  bls12-381 pairing |  full    |  isa-only        |  [o](./src/sw/bls12-381/full-radix/src/asm/isa/)    |  o         |
  |  bls12-381 pairing |  full    |  ise-assisted    |  [o](./src/sw/bls12-381/full-radix/src/asm/ise/)    |  o         |
  |  bls12-381 pairing |  reduced |  isa-only        |  [o](./src/sw/bls12-381/reduced-radix/src/asm/isa/) |            |
  |  bls12-381 pairing |  reduced |  ise-assisted    |  [o](./src/sw/bls12-381/reduced-radix/src/asm/ise/) |            |

<!--- ==================================================================== --->

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

### Software simulation 

- Clone the repo. 

  ```sh
  git clone https://github.com/scarv/mpise.git 
  cd ./mpise 
  ```

- Fix paths, e.g., 
  
  ```sh
  export RISCV=/opt/riscv
  ```

- Set up local variables for repo.

  ```sh
  source ./bin/conf.sh 
  ```

- Build software toolchains 

  ```sh 
  make sw-toolchain-build
  ```

- Build and execute implementations

  ```sh
  make sw-run ALG=[x25519/bls12-381] RADIX=[full/reduced] TYPE=[ISA/ISE]
  ```

  For example, to build and execute an ISE-assisted reduced-radix optimal Ate pairing over BLS12-381 

  ```sh
  make sw-run ALG=bls12-381 RADIX=reduced TYPE=ISE
  ``` 

### Hardware evaluation 

- **TBA**

<!--- ==================================================================== --->
