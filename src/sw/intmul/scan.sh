#!/bin/bash

# bash ./scan.sh clean   => remove everything from ./scan
# bash ./scan.sh collect => build executables into ./scan
# bash ./scan.sh execute => execute executables, and so generate benchmarking output into ./scan

export ARCH="rv64"
export RADIXES="64 63 62 61 60 59 58 57 56 55 54 53 52 51 50"
export PLATFORM="spike"

# =============================================================================

function name() {
  echo "./scan/intmul-${ARCH}_${TYPE}_radix=${1}.${2}"
}

function header() {
  echo "===="                                       | tee --append $(name ${1} log)
  echo "REPO_HOME         := ${REPO_HOME}"          | tee --append $(name ${1} log)
  echo "RISCV             := ${RISCV}"              | tee --append $(name ${1} log)
  echo "MPISE_DESTRUCTIVE := ${MPISE_DESTRUCTIVE}"  | tee --append $(name ${1} log)
  echo "MPISE_STATELESS   := ${MPISE_STATELESS}"    | tee --append $(name ${1} log)
  echo "-----------"
  echo "ARCH              := ${ARCH}"               | tee --append $(name ${1} log)
  echo "TYPE              := ${TYPE}"               | tee --append $(name ${1} log)
  echo "RADIX             := ${1}"                  | tee --append $(name ${1} log)
  echo "PLATFORM          := ${PLATFORM}"           | tee --append $(name ${1} log)
  echo "<<<<"                                       | tee --append $(name ${1} log)
}

function footer() {
  echo ">>>>"                                       | tee --append $(name ${1} log)
}

# -----------------------------------------------------------------------------

case ${1} in
  clean)
    rm --force --recursive ${REPO_HOME}/build/intmul ./scan/*
    ;;

  collect)
    for RADIX in ${RADIXES} ; do
      # build then relocate ISA-based benchmark
      export TYPE="isa"
      make --directory="${REPO_HOME}" ALG="intmul" ARCH="${ARCH}" TYPE="${TYPE}" RADIX="${RADIX}" PLATFORM="${PLATFORM}" sw-clean sw-build
      mv ${REPO_HOME}/build/intmul/intmul-${ARCH}_isa.elf $(name ${RADIX} elf)
      # build then relocate ISE-based benchmark
      export TYPE="ise"
      make --directory="${REPO_HOME}" ALG="intmul" ARCH="${ARCH}" TYPE="${TYPE}" RADIX="${RADIX}" PLATFORM="${PLATFORM}" sw-clean sw-build
      mv ${REPO_HOME}/build/intmul/intmul-${ARCH}_ise.elf $(name ${RADIX} elf)
    done
    ;;

  execute)
    for RADIX in ${RADIXES} ; do
      if   [ "${PLATFORM}" == "spike" ] ; then
        # execute ISA-based benchmark
        export TYPE="isa"
        header ${RADIX}
        ${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk $(name ${RADIX} elf) | tee --append $(name ${RADIX} log)
        footer ${RADIX}
        # execute ISE-based benchmark
        export TYPE="ise"
        header ise ${RADIX} ${PLATFORM}
        ${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk $(name ${RADIX} elf) | tee --append $(name ${RADIX} log)
        footer ise ${RADIX} ${PLATFORM}

      elif [ "${PLATFORM}" == "cva6"  ] ; then
        # execute ISA-based benchmark
        export TYPE="isa"
        header isa ${RADIX} ${PLATFORM}
                                                                                                        $(name ${RADIX} elf) | tee --append $(name ${RADIX} log)
        footer isa ${RADIX} ${PLATFORM}
        # execute ISE-based benchmark
        export TYPE="ise"
        header ise ${RADIX} ${PLATFORM}
                                                                                                        $(name ${RADIX} elf) | tee --append $(name ${RADIX} log)
        footer ise ${RADIX} ${PLATFORM}
      fi
    done
    ;;
esac

# =============================================================================
