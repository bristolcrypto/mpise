#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

if [ -d ${SPIKE_REDUCED_BUILD} ] ; then
  rm --force --recursive ${SPIKE_REDUCED_BUILD}
fi

# =============================================================================

mkdir --parents ${SPIKE_REDUCED_BUILD}

export PATH="${RISCV}/bin:${PATH}"

cd ${SPIKE_REDUCED_BUILD}
${SPIKE_REDUCED_REPO}/configure --prefix="${SPIKE_REDUCED_INSTALL}" --target="riscv64-unknown-elf" --with-isa="rv64gc"
make
make install
cd ${REPO_HOME}

# =============================================================================
