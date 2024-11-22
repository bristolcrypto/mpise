export  SOURCES   = $(wildcard ./${RADIX}/*.c) 
export  SOURCES  += $(wildcard ./${RADIX}/asm/isa/*.S)
export  SOURCES  += $(wildcard ./${RADIX}/asm/ise/*.S) 

export  HEADERS   = $(wildcard ./${RADIX}/*.h)
export  HEADERS  += $(wildcard ./${RADIX}/asm/isa/*.h)
export  HEADERS  += $(wildcard ./${RADIX}/asm/ise/*.h)

export INCLUDES   =            ./${RADIX} 
export INCLUDES  +=            ./${RADIX}/asm

export GCC_FLAGS  =
export GCC_LIBS   = 

include ${REPO_HOME}/src/sw/share/Makefile.in
