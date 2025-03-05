#!/bin/bash

export ARCH="rv64"
export RADIXES="64 63 62 61 60 59 58 57 56 55 54 53 52 51 50"
export PLATFORM="spike"

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
      # build then relocate ISA-based benchmark
      export TYPE="isa"
      export RADIX
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.elf
      # build then relocate ISE-based benchmark
      export TYPE="ise"
      export RADIX
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.elf
    done
    ;;

  execute)
    for RADIX in ${RADIXES} ; do
      # execute ISA-based benchmark
      export TYPE="isa"
      export RADIX
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.log
      # execute ISE-based benchmark
      export TYPE="ise"
      export RADIX
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}_${RADIX}.log
    done
    ;;

  plot)
      # plot ISA-based results
      export TYPE="isa"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}.pdf
      # plot ISE-based results
      export TYPE="ise"
      make --quiet --directory="${REPO_HOME}/src/sw/intmul" --file="${REPO_HOME}/src/sw/intmul/scan.mk" ${REPO_HOME}/src/sw/intmul/scan/intmul-${ARCH}_${TYPE}.pdf
esac

# =============================================================================
