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

update_radixes() {
  if   [ "${ARCH}" = "rv32" ] ; then
    if   [ "${TYPE}" = "isa" ] ; then
      export RADIXES="32 30 29 28 27 26 25 24 23 22 21 20"       # full-radix = XLEN = 32, plus reduced-radix down from XLEN-2 = 32-2 = 30
    elif [ "${TYPE}" = "ise" ] ; then
      export RADIXES="32    29 28 27 26 25 24 23 22 21 20"       # full-radix = XLEN = 32, plus reduced-radix down from XLEN-3 = 32-3 = 29
    fi
  elif [ "${ARCH}" = "rv64" ] ; then
    if   [ "${TYPE}" = "isa" ] ; then
      export RADIXES="64 62 61 60 59 58 57 56 55 54 53 52 51 50" # full-radix = XLEN = 64, plus reduced-radix down from XLEN-2 = 64-2 = 62
    elif [ "${TYPE}" = "ise" ] ; then
      export RADIXES="64    61 60 59 58 57 56 55 54 53 52 51 50" # full-radix = XLEN = 64, plus reduced-radix down from XLEN-3 = 64-3 = 61
    fi
  fi
}

echo "PLATFORM = ${PLATFORM}"
echo "RISCV    = ${RISCV}"
echo "ARCH     = ${ARCH}"

# =============================================================================

case ${1} in
  build)
    make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" build
    ;;
  clean)
    make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" clean
    ;;

  collect)
    # build then relocate ISA-based benchmarks
    export TYPE="isa"
    update_radixes
    echo "-- doing TYPE=${TYPE}, RADIXES=${RADIXES}"
    for RADIX in ${RADIXES} ; do
      export RADIX
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
    done
    # build then relocate ISE-based benchmarks
    export TYPE="ise"
    update_radixes
    echo "-- doing TYPE=${TYPE}, RADIXES=${RADIXES}"
    for RADIX in ${RADIXES} ; do
      export RADIX
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.elf
    done
    ;;

  execute)
    # execute ISA-based benchmarks
    export TYPE="isa"
    update_radixes
    echo "-- doing TYPE=${TYPE}, RADIXES=${RADIXES}"
    for RADIX in ${RADIXES} ; do
      export RADIX
      export VERSION="simple"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
      export VERSION="hybrid"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}_${VERSION}.log
    done
    # execute ISE-based benchmarks
    export TYPE="ise"
    update_radixes
    echo "-- doing TYPE=${TYPE}, RADIXES=${RADIXES}"
    for RADIX in ${RADIXES} ; do
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
