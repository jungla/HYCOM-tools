FC = gfortran
FFLAGS = -O3 -mcmodel=medium -funroll-loops -g -C -fdefault-real-8 -fconvert=big-endian

%.o:%.f90
	$(FC) -c ${FFLAGS} $<


fsle = modiof.f90 modfsle.f90 advecForwardFSLE.f90

all: advecForwardFSLE

advecForwardFSLE:$(fsle)
	$(FC) $(FFLAGS) $(fsle) -o advecForwardFSLE

clean:
	rm *.mod *.o

# DO NOT DELETE THIS LINE - used by make depend

advecForwardFSLE.o: modiof.o modfsle.o
