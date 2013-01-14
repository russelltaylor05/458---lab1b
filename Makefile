NVFLAGS=-g -arch=compute_20 -code=sm_20
# list .c and .cu source files here
# use -02 for optimization during timed runs
SRCFILES=main.cu 

all:	mm_cuda	

mm_cuda: $(SRCFILES) 
	nvcc $(NVFLAGS) -o mm_cuda $^

clean: 
	rm -f *.o mm_cuda
