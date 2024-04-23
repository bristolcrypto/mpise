
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

ifndef RISCV_ROCKET
  $(error "set RISCV_ROCKET environment variable to point at the Rocket Chip toolchain installation")
endif

#ROCKETCHIP_REPO = ${REPO_HOME}/build/rocketchip
ifndef ROCKETCHIP_REPO
  $(error "set ROCKETCHIP_REPO environment variable to point at the Rocket Chip repository")
endif

# =============================================================================

export PORT  ?= /dev/ttyUSB0
export ALG   ?= x25519
export RADIX ?= reduced
export TYPE  ?= ISA
export ARCH  ?= rv64
export IMP   ?= rv64
export ISE   ?= xalu

# =============================================================================

include ${REPO_HOME}/src/hw/fpga/Makefile.in
include ${REPO_HOME}/src/hw/rocketchip/Makefile.in
include ${REPO_HOME}/src/hw/verilator/Makefile.in

# =============================================================================
