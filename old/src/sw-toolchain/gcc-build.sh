#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

if [ -d ${RISCV} ] ; then
  rm --force --recursive ${RISCV}
fi

# =============================================================================

mkdir --parents ${RISCV}

cd ${GCC_REPO}
make clean 
./configure --prefix="${RISCV}" --enable-multilib --disable-linux --with-arch=rv64gc --with-abi=lp64d
make -j$(nproc)
cd ${REPO_HOME}

# =============================================================================

