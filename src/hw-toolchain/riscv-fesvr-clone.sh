#!/bin/bash

source ${REPO_HOME}/src/hw-toolchain/share.sh

# =============================================================================

if [ ! -d ${ROCKET_FESVR_REPO} ] ; then
  git clone https://github.com/riscvarchive/riscv-fesvr.git ${ROCKET_FESVR_REPO}
fi

cd ${ROCKET_FESVR_REPO}
git fetch origin ${ROCKET_FESVR_COMMIT}:${BRANCH}
git checkout ${BRANCH}
git submodule update --init

# =============================================================================
