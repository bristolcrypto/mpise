#!/bin/bash

export RADIXES="64 63 62 61 60 59 58 57 56 55 54 53 52 51 50"
if [ -z ${PLATFORM} ];
then
    export PLATFORM="spike"
else
    echo "Platform is ${PLATFORM}"
fi
if [ -z ${RISCV} ];
then
    export RISCV=${RISCV_SPIKE}
else
    echo "RISCV is ${RISCV}"
fi
if [ -z ${ARCH} ];
then
    export ARCH="rv64"
else
    echo "ARCH is ${ARCH}"
fi

# =============================================================================

case ${1} in
  build)
    make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" build
    ;;
  clean)
    make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" clean
    ;;

  collect)
    for RADIX in ${RADIXES} ; do
      # build then relocate ISA-based benchmarks
      export TYPE="isa"
      export RADIX
      export IMP="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      export IMP="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      # build then relocate ISE-based benchmarks
      export TYPE="ise"
      export RADIX
      export IMP="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      export IMP="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
    done
    ;;

  execute)
    for RADIX in ${RADIXES} ; do
      # execute ISA-based benchmarks
      export TYPE="isa"
      export RADIX
      export IMP="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      export IMP="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      # execute ISE-based benchmarks
      export TYPE="ise"
      export RADIX
      export IMP="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      export IMP="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
    done
    ;;

  plot)
      # plot ISA-based results
      export TYPE="isa"
      export IMP="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
      export IMP="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
      # plot ISE-based results
      export TYPE="ise"
      export IMP="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
      export IMP="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
esac

# =============================================================================
