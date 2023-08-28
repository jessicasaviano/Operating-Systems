CC = gcc
CFLAGS = -Wall -g 

list_harness: list.o harness.o
	$(CC) -o list_harness list.o harness.o

clean: 
		rm -f *.o

