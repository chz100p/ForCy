

all: fcy fcc.f

fcy: mykbhit.h mykbhit.c mygetch.h mygetch.c myputch.h myputch.c main.c compiler.c interprt.c lint.c forcy.h lint.h
	gcc -g -o fcy -include ./mykbhit.h mykbhit.c -D_kbhit=mykbhit -include ./mygetch.h mygetch.c -D_getch=mygetch -include myputch.h myputch.c -D_putch=myputch main.c compiler.c interprt.c lint.c

fcc.f: fcy fcc.fc
	./fcy -c -s fcc.fc

.PHONY: clean

clean:
	rm -f fcy fcc.f


