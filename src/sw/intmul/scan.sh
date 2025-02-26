#!/bin/bash

# bash ./scan.sh clean   => remove everything from ./scan
# bash ./scan.sh collect => build executables into ./scan
# bash ./scan.sh execute => execute executables, and so generate benchmarking output into ./scan

# =============================================================================

RADIXES="64 63 62 61 60 59 58 57 56 55 54"
PLATFORM="spike"

function name() {
  echo "./scan/intmul-rv64_${1}_radix=${2}.${3}"
}

function header() {
  echo "===="                                       | tee --append $(name ${1} ${2} log_${3})
  echo "REPO_HOME         := ${REPO_HOME}"          | tee --append $(name ${1} ${2} log_${3})
  echo "RISCV             := ${RISCV}"              | tee --append $(name ${1} ${2} log_${3})
  echo "MPISE_DESTRUCTIVE := ${MPISE_DESTRUCTIVE}"  | tee --append $(name ${1} ${2} log_${3})
  echo "MPISE_STATELESS   := ${MPISE_STATELESS}"    | tee --append $(name ${1} ${2} log_${3})
  echo "-----------"
  echo "TYPE              := ${1}"                  | tee --append $(name ${1} ${2} log_${3})
  echo "RADIX             := ${2}"                  | tee --append $(name ${1} ${2} log_${3})
  echo "PLATFORM          := ${3}"                  | tee --append $(name ${1} ${2} log_${3})
  echo "<<<<"                                       | tee --append $(name ${1} ${2} log_${3})
}

function footer() {
  echo ">>>>"                                       | tee --append $(name ${1} ${2} log_${3})
}

# -----------------------------------------------------------------------------

case ${1} in
  clean)
    rm --force ./scan/*
    ;;

  collect)
    for RADIX in ${RADIXES} ; do
      # build then relocate ISA-based benchmark
      make --directory="${REPO_HOME}" ALG="intmul" ARCH="rv64" TYPE="isa" RADIX="${RADIX}" PLATFORM="${PLATFORM}" sw-clean sw-build
      mv ${REPO_HOME}/build/intmul/intmul-rv64_isa.elf $(name isa ${RADIX} elf)
      # build then relocate ISE-based benchmark
      make --directory="${REPO_HOME}" ALG="intmul" ARCH="rv64" TYPE="ise" RADIX="${RADIX}" PLATFORM="${PLATFORM}" sw-clean sw-build
      mv ${REPO_HOME}/build/intmul/intmul-rv64_ise.elf $(name ise ${RADIX} elf)
    done
    ;;

  execute)
    for RADIX in ${RADIXES} ; do
      if   [ "${PLATFORM}" == "spike" ] ; then
        # execute ISA-based benchmark
        header isa ${RADIX} ${PLATFORM}
        ${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk $(name isa ${RADIX} elf) | tee --append $(name isa ${RADIX} log_${PLATFORM})
        footer isa ${RADIX} ${PLATFORM}
        # execute ISE-based benchmark
        header ise ${RADIX} ${PLATFORM}
        ${RISCV}/bin/spike --isa='rv64imafdc_zicsr_zifencei_zicntr' ${RISCV}/riscv64-unknown-elf/bin/pk $(name ise ${RADIX} elf) | tee --append $(name ise ${RADIX} log_${PLATFORM})
        footer ise ${RADIX} ${PLATFORM}

      elif [ "${PLATFORM}" == "cva6"  ] ; then
        # execute ISA-based benchmark
        header isa ${RADIX} ${PLATFORM}
                                                                                                        $(name isa ${RADIX} elf) | tee --append $(name isa ${RADIX} log_${PLATFORM})
        footer isa ${RADIX} ${PLATFORM}
        # execute ISE-based benchmark
        header ise ${RADIX} ${PLATFORM}
                                                                                                        $(name ise ${RADIX} elf) | tee --append $(name ise ${RADIX} log_${PLATFORM})
        footer ise ${RADIX} ${PLATFORM}
      fi
    done
    ;;
esac

# =============================================================================
