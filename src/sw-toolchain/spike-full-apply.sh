#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

cd ${SPIKE_FULL_REPO}
if [ -s ${SPIKE_FULL_PATCH} ] ; then
  git apply ${SPIKE_FULL_PATCH}
  git add --all
fi
cd ${REPO_HOME}

# =============================================================================
