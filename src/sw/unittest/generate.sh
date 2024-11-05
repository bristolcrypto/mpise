#!/bin/bash

# =============================================================================

export RISCV="${REPO_HOME}/build/riscv"
export ARCH="rv64"
export COUNT="10"

run_one() {
  echo "==== CASE=${CASE} (MPISE_DESTRUCTIVE=${MPISE_DESTRUCTIVE}, MPISE_STATELESS=${MPISE_STATELESS}), INSN=${1}, COUNT=${COUNT}"
  make --quiet --directory="${REPO_HOME}/src/sw/unittest" ${REPO_HOME}/build/unittest/case-${CASE}_${1}.log INSN="${1}" COUNT="${COUNT}"
}

run_all() {
  rm --force --recursive ${REPO_HOME}/build/riscv-isa-sim ${REPO_HOME}/build/riscv-pk && make sw-toolchain-build 2>&1 | tee ${REPO_HOME}/build/unittest/case-${CASE}_toolchain.log
  run_one "sraiadd"
  run_one "cacc"
  run_one "macclu"
  run_one "macchu"
}

# -----------------------------------------------------------------------------

if   [[ "${1}" ==  "generate" ]] ; then
  # init
  make --quiet --directory="${REPO_HOME}/src/sw/unittest" build
  # case 0 = 00
  export MPISE_DESTRUCTIVE="0"
  export MPISE_STATELESS="0"
  export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
  run_all
  # case 1 = 01
  export MPISE_DESTRUCTIVE="0"
  export MPISE_STATELESS="1"
  export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
  run_all
  # case 2 = 10
  export MPISE_DESTRUCTIVE="1"
  export MPISE_STATELESS="0"
  export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
  run_all
  # case 3 = 11
  export MPISE_DESTRUCTIVE="1"
  export MPISE_STATELESS="1"
  export CASE="${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
  run_all
elif [[ "${1}" == "summarise" ]] ; then
  tail -v -n +1 ${REPO_HOME}/build/unittest/case-00_{sraiadd,cacc,macclu,macchu}.log
  tail -v -n +1 ${REPO_HOME}/build/unittest/case-01_{sraiadd,cacc,macclu,macchu}.log
  tail -v -n +1 ${REPO_HOME}/build/unittest/case-10_{sraiadd,cacc,macclu,macchu}.log
  tail -v -n +1 ${REPO_HOME}/build/unittest/case-11_{sraiadd,cacc,macclu,macchu}.log
elif [[ "${1}" ==   "archive" ]] ; then
  cp ${REPO_HOME}/build/unittest/case-00_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
  cp ${REPO_HOME}/build/unittest/case-01_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
  cp ${REPO_HOME}/build/unittest/case-10_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
  cp ${REPO_HOME}/build/unittest/case-11_{sraiadd,cacc,macclu,macchu}.{txt,S} ${REPO_HOME}/src/sw/unittest/generate
fi

# =============================================================================
