#!/bin/bash

# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

source ${PWD}/share.sh

# =============================================================================

if [ -d ${PK_BUILD} ] ; then
    rm --force --recursive ${PK_BUILD}
fi

mkdir --parents ${PK_INSTALL}
mkdir --parents ${PK_BUILD}

export PATH="${RISCV_SPIKE}/bin:${PATH}"

cd ${PK_BUILD}
../configure --prefix="${PK_INSTALL}" --host="riscv64-unknown-elf" --with-arch="rv32gc" --with-abi="ilp32"
make clean
make
make install

cd ${PK_BUILD}
../configure --prefix="${PK_INSTALL}" --host="riscv64-unknown-elf" --with-arch="rv64gc" --with-abi="lp64"
make clean
make
make install

# =============================================================================
