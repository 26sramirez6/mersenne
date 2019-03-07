CC=gcc
DEBUG=-g3 -pedantic -Wall -Wextra -Werror
OPT=-pedantic -O3 -Wall -Werror -Wextra

ifneq (,$(filter $(MAKECMDGOALS),debug valgrind))
CFLAGS=$(DEBUG)
else
CFLAGS=$(OPT)
endif

all: clean mersenne

debug: clean all
	
valgrind: clean tests
	valgrind --leak-check=full --log-file="valgrind.out" --show-reachable=yes -v ./tests

mersenne : mersenne.o
	$(CC) $(CFLAGS) -o $@ $<

mersenne.o : mersenne.c
	$(CC) $(CFLAGS) -c $< -o $@
	
clean:
	rm -rf *.o *.exe

.PHONY: clean