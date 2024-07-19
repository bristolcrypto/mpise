
export SPIKE_INSTALL=${REPO_HOME}/build/riscv
export PK_INSTALL=${REPO_HOME}/build/riscv

# =============================================================================

CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${SPIKE_INSTALL}/bin/spike
ISA    =rv64gc
PK     =${PK_INSTALL}/riscv64-unknown-elf/bin/pk

# =============================================================================

SRCS  = $(wildcard src/*.c) $(wildcard src/asm/isa/*.S) $(wildcard src/asm/ise/*.S) ../../share/share.c ../../share/arch/rv64/rdtsc.c
RISCV_GCC_OPT ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf
CCFLAGS += -march=${ISA} -lm -lgcc -I ../../share -I ../../share/arch/rv64
OUTPUT  = ${SW_WORK_DIR}/x25519.elf
DISASM  = ${SW_WORK_DIR}/x25519.disasm

# =============================================================================

ifeq ($(MODE), debug)
	CCFLAGS += -DDEBUG
endif

# =============================================================================

all: clean ${OUTPUT} ${DISASM}
	@${SIM} --isa=${ISA} ${PK} ${OUTPUT}

${OUTPUT} : ${SRCS}
	@mkdir -p ${SW_WORK_DIR}
	@${CC} ${RISCV_GCC_OPT} ${CCFLAGS} -D${TYPE} -DMPISE_DESTRUCTIVE=${MPISE_DESTRUCTIVE} -DMPISE_STATELESS=${MPISE_STATELESS} -o $@ $^

${DISASM} : ${OUTPUT}
	@${OBJDUMP} -d -t $< > $@

clean:
	@rm -rf ${SW_WORK_DIR}

# =============================================================================
