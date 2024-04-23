#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

cd ${SPIKE_REDUCED_REPO}
if [ -s ${SPIKE_REDUCED_PATCH} ] ; then
  git apply ${SPIKE_REDUCED_PATCH}
  git add --all
fi
cd ${REPO_HOME}

# =============================================================================
