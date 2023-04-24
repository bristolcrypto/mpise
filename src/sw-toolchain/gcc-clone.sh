#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

if [ ! -d ${GCC_REPO} ] ; then
  git clone https://github.com/riscv/riscv-gnu-toolchain.git ${GCC_REPO}
fi

# =============================================================================

cd ${GCC_REPO}
git fetch origin ${GCC_COMMIT}:${BRANCH}
git checkout ${BRANCH}
git submodule update --init --recursive
cd ${REPO_HOME}

# =============================================================================
