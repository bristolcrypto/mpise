rm -rf ./scan/*

export MPISE_DESTRUCTIVE="0"
export MPISE_STATELESS="0"

export ARCH="rv32"
cp ${REPO_HOME}/data/intmul-fpga-250627/generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/*.log ./scan
PLATFORM="" RISCV="" bash scan.sh plot-fpga
rm ./scan/intmul-${ARCH}_2x2_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf

export ARCH="rv64"
cp ${REPO_HOME}/data/intmul-fpga-250627/generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/*.log ./scan
PLATFORM="" RISCV="" bash scan.sh plot-fpga
rm ./scan/intmul-${ARCH}_2x2_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf


