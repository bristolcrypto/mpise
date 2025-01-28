# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# =============================================================================

export ALG      ?= x25519
export ARCH     ?= rv64   # rv32, rv64
export TYPE     ?= isa    # isa, ise
export RADIX    ?=   64   
export PLATFORM ?= spike  # spike, cva6-verilator, cva6-fpga
ifeq "${PLATFORM}" "spike"
export RISCV=${RISCV_MPISE}
endif
ifeq "${PLATFORM}" "cva6-verilator"
export RISCV=${RISCV_CVA6}
endif

# =============================================================================

sw-toolchain-build :
	@make --directory="${REPO_HOME}/src/sw-toolchain" clone 
	@make --directory="${REPO_HOME}/src/sw-toolchain" apply 
	@make --directory="${REPO_HOME}/src/sw-toolchain" build

sw-toolchain-clean :
	@make --directory="${REPO_HOME}/src/sw-toolchain" clean

# -----------------------------------------------------------------------------

sw-build :
	@make --directory="${REPO_HOME}/src/sw/${ALG}" build

sw-clean :
	@make --directory="${REPO_HOME}/src/sw/${ALG}" clean

sw-run   :
	@make --directory="${REPO_HOME}/src/sw/${ALG}" run

sw-debug :
	@make --directory="${REPO_HOME}/src/sw/${ALG}" debug

# =============================================================================
