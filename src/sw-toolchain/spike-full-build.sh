#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

if [ -d ${SPIKE_FULL_BUILD} ] ; then
  rm --force --recursive ${SPIKE_FULL_BUILD}
fi

# =============================================================================

mkdir --parents ${SPIKE_FULL_BUILD}

export PATH="${RISCV}/bin:${PATH}"

cd ${SPIKE_FULL_BUILD}
${SPIKE_FULL_REPO}/configure --prefix="${SPIKE_FULL_INSTALL}" --target="riscv64-unknown-elf" --with-isa="rv64gc"
make
make install
cd ${REPO_HOME}

# =============================================================================
