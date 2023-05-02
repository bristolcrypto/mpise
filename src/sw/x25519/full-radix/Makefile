
export SPIKE_FULL_INSTALL=${REPO_HOME}/build/sw-toolchain/spike_full
export PK_INSTALL=${REPO_HOME}/build/sw-toolchain/pk

# =============================================================================

CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${SPIKE_FULL_INSTALL}/bin/spike
ISA    =rv64gc
PK     =${PK_INSTALL}/riscv64-unknown-elf/bin/pk

# =============================================================================

SRCS  = $(wildcard src/*.c) $(wildcard src/asm/isa/*.S) $(wildcard src/asm/ise/*.S)

RISCV_GCC_OPT ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf
CCFLAGS += -march=${ISA} -lm -lgcc
OUTPUT  = ${WORK_DIR}/x25519.elf
DISASM  = ${WORK_DIR}/x25519.disasm

# =============================================================================

ifeq ($(MODE), debug)
	CCFLAGS += -DDEBUG
endif

# =============================================================================

all: clean ${OUTPUT} ${DISASM}
	@${SIM} --isa=${ISA} ${PK} ${OUTPUT}

${OUTPUT} : ${SRCS}
	@mkdir -p ${WORK_DIR}
	@${CC} ${RISCV_GCC_OPT} ${CCFLAGS} -D${TYPE} -o $@ $^

${DISASM} : ${OUTPUT}
	@${OBJDUMP} -d -t $< > $@

clean:
	@rm -rf ${WORK_DIR}

# =============================================================================
