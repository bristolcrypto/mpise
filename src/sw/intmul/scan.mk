# =============================================================================

ifeq "${ARCH}" "rv32"
export XLEN=32
endif
ifeq "${ARCH}" "rv64"
export XLEN=64
endif

# -----------------------------------------------------------------------------

${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.elf :
	make --directory="${REPO_HOME}" ALG="intmul" ARCH="${ARCH}" TYPE="${TYPE}" RADIX="${RADIX}" PLATFORM="${PLATFORM}" sw-clean sw-build
	mv ${REPO_HOME}/build/intmul/intmul-${ARCH}_${TYPE}.elf ${@}

${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.log : ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.elf
	@echo "===="                                                                                          | tee --append ${@}
	@echo "REPO_HOME         := ${REPO_HOME}"                                                             | tee --append ${@}
	@echo "RISCV             := ${RISCV}"                                                                 | tee --append ${@}
	@echo "MPISE_DESTRUCTIVE := ${MPISE_DESTRUCTIVE}"                                                     | tee --append ${@}
	@echo "MPISE_STATELESS   := ${MPISE_STATELESS}"                                                       | tee --append ${@}
	@echo "----"                                                                                          | tee --append ${@}
	@echo "ARCH              := ${ARCH}"                                                                  | tee --append ${@}
	@echo "TYPE              := ${TYPE}"                                                                  | tee --append ${@}
	@echo "RADIX             := ${RADIX}"                                                                 | tee --append ${@}
	@echo "PLATFORM          := ${PLATFORM}"                                                              | tee --append ${@}
	@echo "<<<<"                                                                                          | tee --append ${@}

ifeq "${ARCH}" "rv32"
ifeq "${PLATFORM}" "spike"
	@${RISCV}/bin/spike --isa='rv32imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv32-unknown-elf/bin/pk ${<} | tee --append ${@}
endif
ifeq "${PLATFORM}" "cva6"
	@                                                                                                ${<} | tee --append ${@}
endif
endif

ifeq "${ARCH}" "rv64"
ifeq "${PLATFORM}" "spike"
	@${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk ${<} | tee --append ${@}
endif
ifeq "${PLATFORM}" "cva6"
	@                                                                                                ${<} | tee --append ${@}
endif
endif

	@echo ">>>>"                                                                                          | tee --append ${@}

${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}.pdf :
	@cat ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_*.log | grep '^!' | cut -c 3- | python3 ${REPO_HOME}/src/sw/intmul/scan.py --type="${TYPE}" --xlen="${XLEN}" --output="${@}"

# -----------------------------------------------------------------------------

build :
	@mkdir --parents        ${REPO_HOME}/build/intmul

clean :
	@rm --force --recursive ${REPO_HOME}/build/intmul ${REPO_HOME}/src/sw/intmul/scan/*

# =============================================================================
