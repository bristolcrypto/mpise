include ${REPO_HOME}/src/sw/share/Makefile.in

ifdef RADIX_FULL
export BASE = ${CURDIR}/full
endif

ifdef RADIX_REDUCED
export BASE = ${CURDIR}/reduced
endif

export INCLUDES  +=            ${BASE}
export INCLUDES  +=            ${BASE}/asm

export  HEADERS  += $(wildcard ${BASE}/*.h)
export  HEADERS  += $(wildcard ${BASE}/asm/isa/*.h)
export  HEADERS  += $(wildcard ${BASE}/asm/ise/*.h)

export  SOURCES  += $(wildcard ${BASE}/*.c) 
export  SOURCES  += $(wildcard ${BASE}/asm/isa/*.S)
export  SOURCES  += $(wildcard ${BASE}/asm/ise/*.S) 
