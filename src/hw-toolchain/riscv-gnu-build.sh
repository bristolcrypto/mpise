#!/bin/bash

source ${REPO_HOME}/src/hw-toolchain/share.sh

# =============================================================================

mkdir --parents ${RISCV_ROCKET}

if [ -d ${ROCKET_GNU_BUILD} ] ; then
  rm --force --recursive ${ROCKET_GNU_BUILD}
fi

mkdir --parents ${ROCKET_GNU_BUILD}

cd ${ROCKET_GNU_BUILD}
${ROCKET_GNU_REPO}/configure --prefix="${RISCV_ROCKET}" --enable-multilib --with-cmodel=medany
make -j4

# =============================================================================
