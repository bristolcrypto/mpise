#!/bin/bash

# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

# =============================================================================

export REPO_HOME="${PWD}"
export CVA6="${REPO_HOME}/build/cva6"
# Two toolchain installations, the default SPIKE version is now renamed to RISCV_MPISE. The CVA6-compatible version is named RISCV_CVA6. Depending on simulation target (spike, cva6-verilator), the appropriate toolchain is picked.

export RISCV_MPISE="${REPO_HOME}/build/riscv"
export RISCV_CVA6=/home/gk24545/Documents/software/riscv
# CVA6-specific parameters
export DV_SIMULATORS=veri-testharness
export DV_TARGET=cv64a6_imafdc_sv39_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}

export REPO_VERSION_MAJOR="0"
export REPO_VERSION_MINOR="1"
export REPO_VERSION_PATCH="0"

export REPO_VERSION="${REPO_VERSION_MAJOR}.${REPO_VERSION_MINOR}.${REPO_VERSION_PATCH}"

# =============================================================================
