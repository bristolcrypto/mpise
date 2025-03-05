#!/bin/bash

export ARCH="rv64"
export COUNT="10"

# =============================================================================

generate() {
  # build tool-chain
  rm --force --recursive ${REPO_HOME}/build/riscv-isa-sim ${REPO_HOME}/build/riscv-pk && make sw-toolchain-build 2>&1 | tee ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_toolchain.log
  # run sraiadd
  export INSN="sraiadd"
  echo "==== ARCH=${ARCH} CASE=${CASE} (MPISE_DESTRUCTIVE=${MPISE_DESTRUCTIVE}, MPISE_STATELESS=${MPISE_STATELESS}), INSN=${INSN}, COUNT=${COUNT}"
  make --quiet --directory="${REPO_HOME}/src/sw/unittest" --file="${REPO_HOME}/src/sw/unittest/generate.mk" ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.log INSN="${INSN}" COUNT="${COUNT}"
  # run cacc
  export INSN="cacc"
  echo "==== ARCH=${ARCH} CASE=${CASE} (MPISE_DESTRUCTIVE=${MPISE_DESTRUCTIVE}, MPISE_STATELESS=${MPISE_STATELESS}), INSN=${INSN}, COUNT=${COUNT}"
  make --quiet --directory="${REPO_HOME}/src/sw/unittest" --file="${REPO_HOME}/src/sw/unittest/generate.mk" ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.log INSN="${INSN}" COUNT="${COUNT}"
  # run macclu
  export INSN="macclu"
  echo "==== ARCH=${ARCH} CASE=${CASE} (MPISE_DESTRUCTIVE=${MPISE_DESTRUCTIVE}, MPISE_STATELESS=${MPISE_STATELESS}), INSN=${INSN}, COUNT=${COUNT}"
  make --quiet --directory="${REPO_HOME}/src/sw/unittest" --file="${REPO_HOME}/src/sw/unittest/generate.mk" ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.log INSN="${INSN}" COUNT="${COUNT}"
  # run macchu
  export INSN="macchu"
  echo "==== ARCH=${ARCH} CASE=${CASE} (MPISE_DESTRUCTIVE=${MPISE_DESTRUCTIVE}, MPISE_STATELESS=${MPISE_STATELESS}), INSN=${INSN}, COUNT=${COUNT}"
  make --quiet --directory="${REPO_HOME}/src/sw/unittest" --file="${REPO_HOME}/src/sw/unittest/generate.mk" ${REPO_HOME}/build/unittest/unittest-${ARCH}_${CASE}_${INSN}.log INSN="${INSN}" COUNT="${COUNT}"
}

# -----------------------------------------------------------------------------

case ${1} in
  build)
    make --quiet --directory="${REPO_HOME}/src/sw/unittest" --file="${REPO_HOME}/src/sw/unittest/generate.mk" build
    ;;
  clean)
    make --quiet --directory="${REPO_HOME}/src/sw/unittest" --file="${REPO_HOME}/src/sw/unittest/generate.mk" clean
    ;;

  generate)
    # case 0 = 00
    export MPISE_DESTRUCTIVE="0"
    export MPISE_STATELESS="0"
    export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
    generate
    # case 1 = 01
    export MPISE_DESTRUCTIVE="0"
    export MPISE_STATELESS="1"
    export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
    generate
    # case 2 = 10
    export MPISE_DESTRUCTIVE="1"
    export MPISE_STATELESS="0"
    export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
    generate
    # case 3 = 11
    export MPISE_DESTRUCTIVE="1"
    export MPISE_STATELESS="1"
    export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
    generate
    ;;

  summarise)
    tail -v -n +1 ${REPO_HOME}/build/unittest/unittest-${ARCH}_00_{sraiadd,cacc,macclu,macchu}.log
    tail -v -n +1 ${REPO_HOME}/build/unittest/unittest-${ARCH}_01_{sraiadd,cacc,macclu,macchu}.log
    tail -v -n +1 ${REPO_HOME}/build/unittest/unittest-${ARCH}_10_{sraiadd,cacc,macclu,macchu}.log
    tail -v -n +1 ${REPO_HOME}/build/unittest/unittest-${ARCH}_11_{sraiadd,cacc,macclu,macchu}.log
    ;;

  archive)
    cp ${REPO_HOME}/build/unittest/unittest-${ARCH}_00_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
    cp ${REPO_HOME}/build/unittest/unittest-${ARCH}_01_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
    cp ${REPO_HOME}/build/unittest/unittest-${ARCH}_10_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
    cp ${REPO_HOME}/build/unittest/unittest-${ARCH}_11_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
    ;;
esac

# =============================================================================
