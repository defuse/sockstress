sockstress: sockstress.c
	gcc -Wall -c sockstress.c
	gcc -pthread -o sockstress sockstress.o

clean:
	rm *.o sockstress
