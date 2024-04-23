#!/bin/bash

export HW_TOOL_BUILD=${REPO_HOME}/build/hw-toolchain

# =============================================================================

export ROCKET_GNU_REPO="${HW_TOOL_BUILD}/riscv-gnu-toolchain"
export ROCKET_GNU_COMMIT="b468107e701433e1caca3dbc8aef8d40e0c967ed"
export ROCKET_GNU_BUILD="${ROCKET_GNU_REPO}/build"

# =============================================================================

export ROCKET_FESVR_REPO="${REPO_HOME}/work/hw-toolchain/riscv-fesvr"
export ROCKET_FESVR_COMMIT="21e48156e8dc2d0ac53bee50c72b022f95529651"
export ROCKET_FESVR_BUILD="${ROCKET_FESVR_REPO}/build"

export BRANCH="mpise"

# =============================================================================
