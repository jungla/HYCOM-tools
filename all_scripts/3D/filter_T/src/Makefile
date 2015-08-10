FC = gfortran
FFLAGS = -O3 -funroll-loops -g -C -fdefault-real-8 -fconvert=big-endian

%.o:%.f90
	$(FC) -c ${FFLAGS} $<

filter = modfunctions.f90 modiof.f90 modfilter.f90 filter.f90

filter:$(filter)
	$(FC) $(FFLAGS) $(filter) -o filter

clean:
	rm *.mod *.o

# DO NOT DELETE THIS LINE - used by make depend

filter.o: modfunctions.o modiof.o modfilter.o
