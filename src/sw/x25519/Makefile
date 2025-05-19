include ${REPO_HOME}/src/sw/share/Makefile.in

ifdef RADIX_FULL
export BASE = ${CURDIR}/full
endif

ifdef RADIX_REDUCED
export BASE = ${CURDIR}/reduced

ifeq "${XLEN}" "64"
  ifneq "${RADIX}" "51"
    $(error "you set RADIX='${RADIX}', but can only support RADIX='51'")
  endif
endif
endif

export INCLUDES  +=            ${BASE}
export INCLUDES  +=            ${BASE}/asm

export  HEADERS  += $(wildcard ${BASE}/*.h)
export  HEADERS  += $(wildcard ${BASE}/asm/isa_${ARCH}/*.h)
export  HEADERS  += $(wildcard ${BASE}/asm/ise_${ARCH}/*.h)

export  SOURCES  += $(wildcard ${BASE}/*.c) 
export  SOURCES  += $(wildcard ${BASE}/asm/isa_${ARCH}/*.S)
export  SOURCES  += $(wildcard ${BASE}/asm/ise_${ARCH}/*.S) 
