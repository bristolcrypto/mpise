# RISC-V ISEs for multi-precision integer arithmetic

<!--- ==================================================================== --->


<!--- ==================================================================== --->

## Overview

<!--- ==================================================================== --->

## Organisation

```
├── bin                     - scripts (e.g., environment configuration)
├── build                   - working directory for build
├── doc                     - documentation
└── src                     - source code
    ├── sw                  - source code for software
    └── sw-toolchain        - source code for software tool-chain
```

<!--- ==================================================================== --->

## Usage 

- Options which use a RISC-V baseline ISA plus custom ISE do so via the
  [`.insn`](https://www.sourceware.org/binutils/docs/as/RISC_002dV_002dFormats.html)
  directive, rather than an invasive change to `binutils` itself.

- Clone the repo.

  ```sh
  git clone https://github.com/scarv/mpise.git ./mpise
  cd ./mpise
  git submodule update --init --recursive
  source ./bin/conf.sh
  ```

- Fix configuration, e.g., 

  - one option from

    ```sh
    export MPISE_DESTRUCTIVE="0"
    export MPISE_DESTRUCTIVE="1"
    ```
     
    to disable (resp. enable) destructive instruction variants.

  - one option from

    ```sh
    export MPISE_STATELESS="0"
    export MPISE_STATELESS="1"
    ```

    to disable (resp. enable) stateless   instruction variants.

- Fix paths, e.g., 
  
  ```sh
  export RISCV="${REPO_HOME}/build/riscv"
  ```

- Build a multi-architecture 
  [tool-chain](https://github.com/riscv/riscv-gnu-toolchain)
  into `${RISCV}`:
  
  ```sh
  git clone https://github.com/riscv/riscv-gnu-toolchain.git ${REPO_HOME}/build/riscv-gnu-toolchain
  cd ${REPO_HOME}/build/riscv-gnu-toolchain
  git submodule update --init --recursive
  ./configure --prefix="${RISCV}" --enable-multilib --with-multilib-generator="rv32gc-ilp32--;rv64gc-lp64--"
  make
  ```

- Build an ISE-enabled tool-chain, including
  [`spike`](https://github.com/riscv/riscv-isa-sim)
  and associated
  [`pk`](https://github.com/riscv/riscv-pk),
  via

  ```sh 
  make sw-toolchain-build
  ```

  Note that since said tool-chain is 
  [patch](https://savannah.gnu.org/projects/patch)-based,
  making changes to it is somewhat tricky.  The idea, for each component,
  (i.e., `pk` and `spike`) referred to as `${COMPONENT}` is as follows:

  - perform a fresh clone of the component repository,
  - apply the existing patch to the cloned component repository,
  - implement the change in the cloned component repository,
  - stage the change via `git add`, but do *not* commit it, in the cloned component repository,
  - execute `${COMPONENT}-update.sh` to produce an updated patch,
  - optionally commit and push the updated patch.

- Software simulation with `spike` and `pk` 
  ```sh
  make sw-run ALG=x25519 RADIX=[full/reduced] TYPE=[ISA/ISE]
  ```

<!--- ==================================================================== --->

## Acknowledgements

This work has been supported in part
by EPSRC       via grant
[EP/R012288/1](https://gtr.ukri.org/projects?ref=EP/R012288/1) (under the [RISE](http://www.ukrise.org) programme),
and 
by Innovate UK via grant
[10065634](https://gtr.ukri.org/projects?ref=10065634).

<!--- ==================================================================== --->
