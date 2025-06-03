# =============================================================================

ifeq "${ARCH}" "rv32"
export XLEN=32
endif
ifeq "${ARCH}" "rv64"
export XLEN=64
endif

ifeq "${VERSION}" "simple"
export CONF="-DVERSION_SIMPLE"
endif
ifeq "${VERSION}" "hybrid"
export CONF="-DVERSION_HYBRID"
endif

# -----------------------------------------------------------------------------

${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf :
	make --directory="${REPO_HOME}" ALG="intmul" ARCH="${ARCH}" TYPE="${TYPE}" RADIX="${RADIX}" PLATFORM="${PLATFORM}" sw-clean sw-build
	mv ${REPO_HOME}/build/intmul/intmul-${ARCH}_${TYPE}.elf ${@}
	mv ${REPO_HOME}/build/intmul/intmul-${ARCH}_${TYPE}.bin ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.bin
	mv ${REPO_HOME}/build/intmul/intmul-${ARCH}_${TYPE}.asm ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.asm

${REPO_HOME}/src/sw/intmul/scan/${ARCH}/mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf : ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
	@echo "Moving ELF, ASM, BIN files to scan/${ARCH}/"
	# Move ELF, ASM, and BIN file to scan folder. These will be used for building SD card image (FPGA).
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf ${REPO_HOME}/src/sw/intmul/scan/${ARCH}/mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.bin ${REPO_HOME}/src/sw/intmul/scan/${ARCH}/mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.asm ${REPO_HOME}/src/sw/intmul/scan/${ARCH}/mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/

${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log : ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
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
	@echo "VERSION           := ${VERSION}"                                                               | tee --append ${@}
	@echo "<<<<"                                                                                          | tee --append ${@}

ifeq "${ARCH}" "rv32"
ifeq "${PLATFORM}" "spike"
	@${RISCV}/bin/spike --isa='rv32imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv32-unknown-elf/bin/pk ${<} | tee --append ${@}
endif
ifeq "${PLATFORM}" "cva6-verilator"
	# Move ELF, ASM, and BIN file to build/intmul. mpise-sim.sh will consume these files.
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf ${REPO_HOME}/build/intmul/
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.bin ${REPO_HOME}/build/intmul/
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.asm ${REPO_HOME}/build/intmul/
	@ALG="intmul" bash ${CVA6}/verif/sim/mpise-sim.sh intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION} | tee --append ${@}
endif
endif

ifeq "${ARCH}" "rv64"
ifeq "${PLATFORM}" "spike"
	@${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk ${<} | tee --append ${@}
endif
ifeq "${PLATFORM}" "cva6-verilator"
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf ${REPO_HOME}/build/intmul/
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.bin ${REPO_HOME}/build/intmul/
	@cp ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.asm ${REPO_HOME}/build/intmul/
	@ALG="intmul" bash ${CVA6}/verif/sim/mpise-sim.sh intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION} | tee --append ${@}
endif
endif

	@echo ">>>>"                                                                                          | tee --append ${@}

${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf :
	@cat ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ${REPO_HOME}/src/sw/intmul/scan.py --type="${TYPE}" --xlen="${XLEN}" --output="${@}"

# -----------------------------------------------------------------------------

build :
	@mkdir --parents        ${REPO_HOME}/build/intmul
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv64/mpise_00
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv64/mpise_01
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv64/mpise_10
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv64/mpise_11
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv32/mpise_00
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv32/mpise_01
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv32/mpise_10
	@mkdir --parents	${REPO_HOME}/src/sw/intmul/scan/rv32/mpise_11

clean :
	@rm --force --recursive ${REPO_HOME}/build/intmul ${REPO_HOME}/src/sw/intmul/scan/*

# =============================================================================
