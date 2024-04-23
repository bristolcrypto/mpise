#!/bin/bash

# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

# =============================================================================

export PK_REPO="${REPO_HOME}/build/riscv-pk"
export PK_BUILD="${PK_REPO}/build"
export PK_COMMIT="b7ee9734776123c34a8c0d37fa981169521614ad"
export PK_BRANCH="mpise"
export PK_PATCH="${PWD}/pk.patch"
export PK_INSTALL="${REPO_HOME}/build/riscv"

export SPIKE_REPO="${REPO_HOME}/build/riscv-isa-sim"
export SPIKE_BUILD="${SPIKE_REPO}/build"
export SPIKE_COMMIT="c6ec6f3582eb2ae106dff95e569b7da927910629"
export SPIKE_BRANCH="mpise"
export SPIKE_PATCH="${PWD}/spike.patch"
export SPIKE_INSTALL="${REPO_HOME}/build/riscv"

# =============================================================================
