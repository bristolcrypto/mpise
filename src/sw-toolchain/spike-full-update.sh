#!/bin/bash

source ${REPO_HOME}/src/sw-toolchain/share.sh

# =============================================================================

cd ${SPIKE_FULL_REPO}
git diff --cached > ${SPIKE_FULL_PATCH}
cd ${REPO_HOME}

# =============================================================================
