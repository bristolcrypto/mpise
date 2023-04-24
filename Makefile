
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

ifndef RISCV
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# =============================================================================

export WORK_DIR ?= ${REPO_HOME}/build/${ALG}_${RADIX}

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
