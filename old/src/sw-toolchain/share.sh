#!/bin/bash

export SW_TOOL_BUILD=${REPO_HOME}/build/sw-toolchain

# =============================================================================

export GCC_REPO="${SW_TOOL_BUILD}/riscv-gnu-toolchain"
export GCC_PATCH="${REPO_HOME}/src/sw-toolchain/gcc.patch"
export GCC_COMMIT="28271f03bb538d926ad2889dc8ad1b0cb1b3b45c"

# =============================================================================

export PK_REPO="${SW_TOOL_BUILD}/riscv-pk"
export PK_BUILD="${PK_REPO}/build"
export PK_PATCH="${REPO_HOME}/src/sw-toolchain/pk.patch"
export PK_INSTALL="${SW_TOOL_BUILD}/pk"
export PK_COMMIT="b7ee9734776123c34a8c0d37fa981169521614ad"

# =============================================================================

export SPIKE_FULL_REPO="${SW_TOOL_BUILD}/riscv-isa-sim-full"
export SPIKE_FULL_BUILD="${SPIKE_FULL_REPO}/build"
export SPIKE_FULL_PATCH="${REPO_HOME}/src/sw-toolchain/spike.patch_full"
export SPIKE_FULL_INSTALL="${SW_TOOL_BUILD}/spike_full"

export SPIKE_REDUCED_REPO="${SW_TOOL_BUILD}/riscv-isa-sim-reduced"
export SPIKE_REDUCED_BUILD="${SPIKE_REDUCED_REPO}/build"
export SPIKE_REDUCED_PATCH="${REPO_HOME}/src/sw-toolchain/spike.patch_reduced"
export SPIKE_REDUCED_INSTALL="${SW_TOOL_BUILD}/spike_reduced"

export SPIKE_COMMIT="c6ec6f3582eb2ae106dff95e569b7da927910629"

# =============================================================================

export BRANCH="mpise"

# =============================================================================
