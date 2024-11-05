export GCC_FLAGS  += -DMPISE_DESTRUCTIVE="${MPISE_DESTRUCTIVE}" -DMPISE_STATELESS="${MPISE_STATELESS}"

ifeq "${ARCH}" "rv32"
export GCC_PREFIX  = riscv32-unknown-elf
export GCC_FLAGS  += -DMPISE_XLEN="32"
endif
ifeq "${ARCH}" "rv64"
export GCC_PREFIX  = riscv64-unknown-elf
export GCC_FLAGS  += -DMPISE_XLEN="64"
endif

export INCLUDES   += ${REPO_HOME}/src/sw/share
export INCLUDES   += ${REPO_HOME}/src/sw/share/arch/${ARCH}

export CASE       := ${MPISE_DESTRUCTIVE}${MPISE_STATELESS}

${REPO_HOME}/build/unittest              :
	@mkdir --parents ${@}

${REPO_HOME}/build/unittest/case-${CASE}_generate.S   : $(wildcard generate.*)
	@${RISCV}/bin/${GCC_PREFIX}-gcc ${GCC_FLAGS} ${GCC_PATHS} $(addprefix -I ,${INCLUDES}) -Wall -std='gnu99' -O3 -S -o ${@} $(filter %.c,${^})
${REPO_HOME}/build/unittest/case-${CASE}_generate.elf : ${REPO_HOME}/build/unittest/case-${CASE}_generate.S
	@${RISCV}/bin/${GCC_PREFIX}-gcc ${GCC_FLAGS} ${GCC_PATHS} $(addprefix -I ,${INCLUDES}) -Wall -std='gnu99' -O3    -o ${@}                    $(filter %.S,${^})
${REPO_HOME}/build/unittest/case-${CASE}_generate.asm : ${REPO_HOME}/build/unittest/case-${CASE}_generate.elf
	@${RISCV}/bin/${GCC_PREFIX}-objdump --disassemble-all ${<} > ${@}

${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.txt : ${REPO_HOME}/build/unittest/case-${CASE}_generate.elf
	@${RISCV}/bin/spike --isa='rv64gc_zicsr_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk ${<} ${COUNT} ${INSN} > ${@}
${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.S   :                      ${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.txt
	@cat ${<} | grep '//' | cut -c4- > ${@}
${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.elf : $(wildcard driver.*) ${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.S
	@${RISCV}/bin/${GCC_PREFIX}-gcc ${GCC_FLAGS} ${GCC_PATHS} $(addprefix -I ,${INCLUDES}) -Wall -std='gnu99' -O3    -o ${@} $(filter %.c,${^}) $(filter %.S,${^})
${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.log :                      ${REPO_HOME}/build/unittest/case-${CASE}_${INSN}.elf
	@${RISCV}/bin/spike --isa='rv64gc_zicsr_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk ${<} ${COUNT} ${INSN} | tee ${@}

build    :                      ${REPO_HOME}/build/unittest

spotless :
	@rm --force --recursive ${REPO_HOME}/build/unittest
