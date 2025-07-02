#!/bin/bash 

plot() {
  # plot ISA-based results
  export TYPE="isa"
  export VERSION="simple"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000" 
  export TYPE="isa"
  export VERSION="hybrid"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000" 
  # plot ISE-based results
  export TYPE="ise"
  export VERSION="simple"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000" 
  export TYPE="ise"
  export VERSION="hybrid"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000" 
}

rm -rf ./scan/*

export MPISE_DESTRUCTIVE="0"
export MPISE_STATELESS="0"

export ARCH="rv32"
export XLEN="32"
cp ${REPO_HOME}/data/intmul-fpga-250627/generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/*.log ./scan
plot

export ARCH="rv64"
export XLEN="64"
cp ${REPO_HOME}/data/intmul-fpga-250627/generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/*.log ./scan
plot

cp ./scan/*.pdf ${1}/image
