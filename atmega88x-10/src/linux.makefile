

all:
	gcc -g -o fcy -include ./mykbhit.h mykbhit.c -D_kbhit=mykbhit -include ./mygetch.h mygetch.c -D_getch=mygetch -include myputch.h myputch.c -D_putch=myputch main.c compiler.c interprt.c lint.c
