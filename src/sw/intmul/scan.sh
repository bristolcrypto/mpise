#!/bin/bash

if [ -z ${PLATFORM} ] ; then
  export PLATFORM="spike"
fi

if [ -z ${RISCV}    ] ; then
  export RISCV=${RISCV_SPIKE}
fi

if [ -z ${ARCH}     ] ; then
  export ARCH="rv64"
fi

if [ -z ${RADIXES}  ] ; then
  if   [ "${ARCH}" = "rv32" ] ; then
    export RADIXES="32 31 30 29 28 27 26 25"
  elif [ "${ARCH}" = "rv64" ] ; then
    export RADIXES="64 63 62 61 60 59 58 57 56 55 54 53 52 51 50"
  fi
fi

echo "PLATFORM = ${PLATFORM}"
echo "RISCV    = ${RISCV}"
echo "ARCH     = ${ARCH}"
echo "RADIXES  = ${RADIXES}"

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
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      # build then relocate ISE-based benchmarks
      export TYPE="ise"
      export RADIX
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
    done
    ;;

  execute)
    for RADIX in ${RADIXES} ; do
      # execute ISA-based benchmarks
      export TYPE="isa"
      export RADIX
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      # execute ISE-based benchmarks
      export TYPE="ise"
      export RADIX
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
    done
    ;;

  plot)
      # plot ISA-based results
      export TYPE="isa"
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
      # plot ISE-based results
      export TYPE="ise"
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${VERSION}.pdf
esac

# =============================================================================
