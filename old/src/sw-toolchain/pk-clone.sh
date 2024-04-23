#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

if [ ! -d ${PK_REPO} ] ; then
  git clone https://github.com/riscv/riscv-pk.git ${PK_REPO}
fi

# =============================================================================

cd ${PK_REPO}
git fetch origin ${PK_COMMIT}:${BRANCH}
git checkout ${BRANCH}
cd ${REPO_HOME}

# =============================================================================
