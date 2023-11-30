C = gcc
CFLAGS = -Wall -Werror -pedantic -g -fsanitize=address -fsanitize=undefined 
OBJECTS = fs_skeleton.o

all: disk_image

disk_image: $(OBJECTS)
	$(C) $(CFLAGS) -o $@ $(OBJECTS)

SUBMIT_FILENAME=dragon-jrs5xrw-npj5kr.tar.gz

submit:
	tar -zcf $(SUBMIT_FILENAME) inode.h fs_skeleton.c Makefile README
	@echo "Created $(SUBMIT_FILENAME); please upload and submit this file."


clean:
	rm -f *.o disk_image

.PHONY: clean all