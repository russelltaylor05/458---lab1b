# General test makefile for multi-target test
# General definitions

CPP = gcc
CPPFLAGS = -Wall -g #-O3 -g
MAIN = main.o

default: main
     
main: $(MAIN) 
	$(CPP) $(MAIN) -o mm_cpu

double: 
	$(CPP) $(CPPFLAGS) -DDOUBLE -o mm_cpu main.c  

single: 
	$(CPP) $(CPPFLAGS) -DSINGLE -o mm_cpu main.c

clean: 
	rm mm_cpu *.o

test: clean main
	@./mm_cpu


%.o: %.c
	$(CPP) $(CPPFLAGS) -c $< -o $@


# Header file interdependencies

%.c: %.h
	touch $@

