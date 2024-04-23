#!/bin/bash

source ${REPO_HOME}/src/hw-toolchain/share.sh

# =============================================================================

if [ ! -d ${ROCKET_GNU_REPO} ] ; then
  git clone https://github.com/riscv/riscv-gnu-toolchain.git ${ROCKET_GNU_REPO}
fi

cd ${ROCKET_GNU_REPO}
git fetch origin ${ROCKET_GNU_COMMIT}:${BRANCH}
git checkout ${BRANCH}
git submodule update --init

# =============================================================================
