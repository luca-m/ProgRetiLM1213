CFLAGS+=-lm
LDFLAGS+=-lm
#EXTRA_CFLAGS+=-DDEBUG 

all: mm1prio md1prio

xx1prio.o: xx1prio.c 
	$(CC) -c $(EXTRA_CFLAGS) $(CFLAGS)  xx1prio.c 

mm1prio.o: mm1prio.c
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) mm1prio.c

md1prio.o: md1prio.c
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) md1prio.c

mm1prio: xx1prio.o mm1prio.o mt.o
	$(CC) xx1prio.o mm1prio.o mt.o $(LDFLAGS) $(EXTRA_CFLAGS) -o mm1prio

md1prio: xx1prio.o md1prio.o mt.o
	$(CC) xx1prio.o md1prio.o mt.o $(LDFLAGS) $(EXTRA_CFLAGS) -o md1prio

mt.o: mt.c
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) mt.c	

clean:
	rm -f xx1prio.o mm1prio.o mm1prio md1prio.o md1prio