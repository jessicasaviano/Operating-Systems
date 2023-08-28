CC = gcc
CFLAGS = -Wall -g 

list: list.o harness.o
	$(CC) -o list list.o harness.o

clean: 
		rm -f *.o

