
OBJS = XXX.o \

CC = gcc

XXX : $(OBJS)
	$(CC) -o $@ $^
