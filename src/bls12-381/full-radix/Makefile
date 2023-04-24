CC = gcc-9
FILES = $(wildcard src/*.c)
OUTPUT = bls12-381
FLAGS = -O3 -fomit-frame-pointer -mbmi2 -madx -mtune=native

all: 
	$(CC) $(FILES) -o $(OUTPUT) $(FLAGS)

clean:
	rm -f bls12-381
