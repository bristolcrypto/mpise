# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# =============================================================================

export SW_WORK_DIR ?= ${REPO_HOME}/build/sw/${ALG}_${RADIX}

export ALG      ?= bls12-381
export RADIX    ?= full
export TYPE     ?= ISA

# =============================================================================

sw-toolchain-build :
	@make --directory="${REPO_HOME}/src/sw-toolchain" clone 
	@make --directory="${REPO_HOME}/src/sw-toolchain" apply 
	@make --directory="${REPO_HOME}/src/sw-toolchain" build

sw-toolchain-clean :
	@make --directory="${REPO_HOME}/src/sw-toolchain" clean

sw-run:
	@make --directory="${REPO_HOME}/src/sw/${ALG}/${RADIX}-radix" all

sw-clean:
	@make --directory="${REPO_HOME}/src/sw/${ALG}/${RADIX}-radix" clean

# =============================================================================
