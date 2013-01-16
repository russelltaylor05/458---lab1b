NVFLAGS=-g -arch=compute_20 -code=sm_20
# list .c and .cu source files here
# use -02 for optimization during timed runs


SRCFILES=main.cu 
TARGET = ./mm_cuda

all:	mm_cuda	

mm_cuda: $(SRCFILES) 
	nvcc $(NVFLAGS) -o mm_cuda $^

test: $(TARGET)
	$(TARGET) input/A.in input/A.in

test2: $(TARGET)
	$(TARGET) input/B.in input/B.in

test32: $(TARGET)
	$(TARGET) input/C.in input/C.in

test64: $(TARGET)
	$(TARGET) input/D.in input/D.in




clean: 
	rm -f *.o mm_cuda
