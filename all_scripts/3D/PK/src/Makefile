FC = gfortran
FFLAGS = -O3 -funroll-loops -g -C -fdefault-real-8 -fconvert=big-endian

%.o:%.f90
	$(FC) -c ${FFLAGS} $<

filter =  modiof.f90 modfunctions.f90 PK.f90

filter:$(filter)
	$(FC) $(FFLAGS) $(filter) -o PK

clean:
	rm *.mod *.o

# DO NOT DELETE THIS LINE - used by make depend

filter.o: modiof.o modfunctions.o PK.o
