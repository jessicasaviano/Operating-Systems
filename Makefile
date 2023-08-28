CC = gcc
CFLAGS = -Wall -g 

harness: harness.o list.o
	$(CC) -o list harness.o list.o

clean: 
		rm -f *.o

