# =============================================================================

export GCC_FLAGS  += -DMPISE_DESTRUCTIVE="${MPISE_DESTRUCTIVE}" -DMPISE_STATELESS="${MPISE_STATELESS}"

ifeq "${ARCH}" "rv32"
export GCC_PREFIX  = riscv64-unknown-elf
export GCC_FLAGS  += -march='rv32imafdc_zicsr_zifencei_zicntr' -mabi='ilp32'
export GCC_FLAGS  += -DMPISE_XLEN="32" 
endif
ifeq "${ARCH}" "rv64"
export GCC_PREFIX  = riscv64-unknown-elf
export GCC_FLAGS  += -march='rv64imafdc_zicsr_zifencei_zicntr' -mabi='lp64d'
export GCC_FLAGS  += -DMPISE_XLEN="64"
endif

export INCLUDES   += ${REPO_HOME}/src/sw/share
export INCLUDES   += ${REPO_HOME}/src/sw/share/arch/${ARCH}

export CASE       := ${MPISE_DESTRUCTIVE}${MPISE_STATELESS}

# -----------------------------------------------------------------------------

${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_generate.S   : $(wildcard generate.*)
	@${RISCV}/bin/${GCC_PREFIX}-gcc ${GCC_FLAGS} ${GCC_PATHS} $(addprefix -I ,${INCLUDES}) -Wall -std='gnu99' -O3 -S -o ${@} $(filter %.c,${^})
${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_generate.elf : ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_generate.S
	@${RISCV}/bin/${GCC_PREFIX}-gcc ${GCC_FLAGS} ${GCC_PATHS} $(addprefix -I ,${INCLUDES}) -Wall -std='gnu99' -O3    -o ${@}                    $(filter %.S,${^})
${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_generate.asm : ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_generate.elf
	@${RISCV}/bin/${GCC_PREFIX}-objdump --disassemble-all ${<} > ${@}

${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.txt :                      ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_generate.elf
ifeq "${ARCH}" "rv32"
	@${RISCV}/bin/spike --isa='rv32imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv32-unknown-elf/bin/pk ${<} ${COUNT} ${INSN} > ${@}
endif
ifeq "${ARCH}" "rv64"
	@${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk ${<} ${COUNT} ${INSN} > ${@}
endif

${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.S   :                      ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.txt
	@cat ${<} | grep '//' | cut -c4- > ${@}
${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.elf : $(wildcard driver.*) ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.S
	@${RISCV}/bin/${GCC_PREFIX}-gcc ${GCC_FLAGS} ${GCC_PATHS} $(addprefix -I ,${INCLUDES}) -Wall -std='gnu99' -O3    -o ${@} $(filter %.c,${^}) $(filter %.S,${^})

${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.log :                      ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.elf
ifeq "${ARCH}" "rv32"
	@${RISCV}/bin/spike --isa='rv32imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv32-unknown-elf/bin/pk ${<} | tee ${@}
endif
ifeq "${ARCH}" "rv64"
	@${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk ${<} | tee ${@}
endif

# -----------------------------------------------------------------------------

build :                         
	@mkdir --parents        ${REPO_HOME}/build/unittest

clean :
	@rm --force --recursive ${REPO_HOME}/build/unittest

# =============================================================================
