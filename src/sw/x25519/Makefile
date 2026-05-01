export IMPL              ?= mpise

ifneq "${IMPL}" "mpise"
export TYPE=isa
ifeq "${ARCH}" "rv32"
  export RADIX=32
endif
ifeq "${ARCH}" "rv64"
  export RADIX=64
endif
endif

include ${REPO_HOME}/src/sw/share/Makefile.in

# =============================================================================

ifeq "${IMPL}" "mpise"
ifdef RADIX_REDUCED
  ifeq "${XLEN}" "64"
    ifneq "${RADIX}" "51"
      $(error "you set RADIX='${RADIX}', but can only support RADIX='51'")
    endif
  endif
  ifeq "${XLEN}" "32"
    ifneq "${RADIX}" "29"
      $(error "you set RADIX='${RADIX}', but can only support RADIX='29'")
    endif
  endif
endif
endif

# =============================================================================

ifeq "${IMPL}" "mpise"
ifdef RADIX_FULL
  export BASE = ${CURDIR}/full
endif
ifdef RADIX_REDUCED
  export BASE = ${CURDIR}/reduced
endif
else
export BASE = ${CURDIR}/${IMPL}
endif

# -----------------------------------------------------------------------------

export INCLUDES  +=            ${BASE}
export INCLUDES  +=            ${BASE}/asm
export  HEADERS  += $(wildcard ${BASE}/*.h)
export  SOURCES  += $(wildcard ${BASE}/*.c)
export  SOURCES  += $(wildcard ${BASE}/*.S)

ifeq "${IMPL}" "mpise"
export  HEADERS  += $(wildcard ${BASE}/asm/isa_${ARCH}/*.h)
export  HEADERS  += $(wildcard ${BASE}/asm/ise_${ARCH}/*.h)
export  SOURCES  += $(wildcard ${BASE}/asm/isa_${ARCH}/*.S)
export  SOURCES  += $(wildcard ${BASE}/asm/ise_${ARCH}/*.S)
endif

export GCC_FLAGS += -DX25519_DEBUG
export GCC_FLAGS += -DDEBUG

