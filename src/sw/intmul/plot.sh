#!/bin/bash 

 export ARCHIVE="${REPO_HOME}/data/251211-intmul"

plot() {
  # plot ISA-based results
  export TYPE="isa"
  export VERSION="simple"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  echo "--- plotting ARCH=${ARCH}, XLEN=${XLEN}, TYPE=${TYPE}, VERSION=${VERSION}"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --output-ht="10" --output-wd="16" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000"
  export TYPE="isa"
  export VERSION="hybrid"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  echo "--- plotting ARCH=${ARCH}, XLEN=${XLEN}, TYPE=${TYPE}, VERSION=${VERSION}"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --output-ht="10" --output-wd="16" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000"
  # plot ISE-based results
  export TYPE="ise"
  export VERSION="simple"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  echo "--- plotting ARCH=${ARCH}, XLEN=${XLEN}, TYPE=${TYPE}, VERSION=${VERSION}"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --output-ht="10" --output-wd="16" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000"
  export TYPE="ise"
  export VERSION="hybrid"
  export OUTPUT="./scan/intmul-${ARCH}_${TYPE}_${VERSION}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}.pdf"
  echo "--- plotting ARCH=${ARCH}, XLEN=${XLEN}, TYPE=${TYPE}, VERSION=${VERSION}"
  cat ./scan/intmul-${ARCH}_${TYPE}_*_${VERSION}.log | grep '^!' | cut -c 3- | python3 ./scan.py --type="${TYPE}" --xlen="${XLEN}" --version="${VERSION}" --output="${OUTPUT}" --output-ht="10" --output-wd="16" --scale-x-max="4500" --scale-x-step="256" --scale-y-max="80000" --scale-y-step="10000"
}

rm -rf ./scan/*

export MPISE_DESTRUCTIVE="0"
export MPISE_STATELESS="0"

export ARCH="rv32"
export XLEN="32"
cp ${ARCHIVE}/generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/*.log ./scan
plot

export ARCH="rv64"
export XLEN="64"
cp ${ARCHIVE}/generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}/*.log ./scan
plot

if [ ! -z "${1}" ] ; then
  cp ./scan/*.pdf ${1}
else
  echo "!! not copying the results"
fi
