#!/bin/bash

# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

source ${PWD}/share.sh

# =============================================================================

cd ${PK_REPO}
git diff --cached > ${PK_PATCH}

# =============================================================================
