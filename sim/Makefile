CFLAGS+=-lm
LDFLAGS+=-lm
#EXTRA_CFLAGS+=-DDEBUG 

all: mm1prio

xx1prio.o: xx1prio.c 
	$(CC) -c $(EXTRA_CFLAGS) $(CFLAGS)  xx1prio.c 

mm1prio.o: mm1prio.c
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) mm1prio.c

mm1prio: xx1prio.o mm1prio.o
	$(CC) xx1prio.o mm1prio.o $(LDFLAGS) $(EXTRA_CFLAGS) -o mm1prio


clean:
	rm -f xx1prio.o mm1prio.o mm1prio