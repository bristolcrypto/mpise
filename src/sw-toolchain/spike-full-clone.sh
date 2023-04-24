#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

if [ ! -d ${SPIKE_FULL_REPO} ] ; then
  git clone https://github.com/riscv/riscv-isa-sim.git ${SPIKE_FULL_REPO}
fi

# =============================================================================

cd ${SPIKE_FULL_REPO}
git fetch origin ${SPIKE_COMMIT}:${BRANCH}
git checkout ${BRANCH}
cd ${REPO_HOME}

# =============================================================================
