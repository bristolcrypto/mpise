#!/bin/bash

source ${REPO_HOME}/src/hw-toolchain/share.sh

# =============================================================================

mkdir --parents ${RISCV_ROCKET}

if [ -d ${ROCKET_FESVR_BUILD} ] ; then
  rm --force --recursive ${ROCKET_FESVR_BUILD}
fi

mkdir --parents ${ROCKET_FESVR_BUILD}

export PATH="${RISCV_ROCKET}/bin:${PATH}"

cd ${ROCKET_FESVR_BUILD}
${ROCKET_FESVR_REPO}/configure --prefix="${RISCV_ROCKET}"
make
make install

# =============================================================================

