# RISC-V ISEs for multi-precision integer arithmetic

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
  export CVA6="${REPO_HOME}/build/cva6"
  export RISCV="${REPO_HOME}/build/riscv"
  ```

- Clone the 
  [CVA6]()
  core repo.
  into `${CVA6}`:

  ```sh     
  git clone https://github.com/isa084/cva6_mpise ${REPO_HOME}/build/cva6
  cd ${REPO_HOME}/build/cva6
  git submodule update --init --recursive  
  ```

  noting this is a fork of the
  `https://github.com/openhwgroup/cva6.git`.

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

  Note that at some point, the repo. seems to have some problems that mean
  one needs to execute

  ```sh
  sed -i '/shallow = true/d' .gitmodules
  sed -i 's/--depth 1//g' Makefile.in
  ```

  to resolve an 
  [issue](https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1669) 
  with shallow cloning sub-modules.

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

- Execute software simulation:

  ```sh
  ALG="intmul" ARCH="rv64" TYPE="isa" RADIX="64" PLATFORM="spike" make sw-clean sw-build sw-run # ISA-based,    full-radix (i.e., 64-bit)
  ALG="intmul" ARCH="rv64" TYPE="ise" RADIX="64" PLATFORM="spike" make sw-clean sw-build sw-run # ISE-based,    full-radix (i.e., 64-bit)
  ALG="intmul" ARCH="rv64" TYPE="isa" RADIX="51" PLATFORM="spike" make sw-clean sw-build sw-run # ISA-based, reduced-radix (i.e., 51-bit)
  ALG="intmul" ARCH="rv64" TYPE="ise" RADIX="51" PLATFORM="spike" make sw-clean sw-build sw-run # ISE-based, reduced-radix (i.e., 51-bit)

  ALG="x25519" ARCH="rv64" TYPE="isa" RADIX="64" PLATFORM="spike" make sw-clean sw-build sw-run # ISA-based,    full-radix (i.e., 64-bit)
  ALG="x25519" ARCH="rv64" TYPE="ise" RADIX="64" PLATFORM="spike" make sw-clean sw-build sw-run # ISE-based,    full-radix (i.e., 64-bit)
  ALG="x25519" ARCH="rv64" TYPE="isa" RADIX="51" PLATFORM="spike" make sw-clean sw-build sw-run # ISA-based, reduced-radix (i.e., 51-bit)
  ALG="x25519" ARCH="rv64" TYPE="ise" RADIX="51" PLATFORM="spike" make sw-clean sw-build sw-run # ISE-based, reduced-radix (i.e., 51-bit)
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
