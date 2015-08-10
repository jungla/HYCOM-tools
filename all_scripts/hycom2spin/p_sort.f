C notice that the size of the incoming array has to be given.
C the script p_bin.f produce a binary file from the ASCII file
C selecting a set of particles.
C It gives as standard output the size of that array.
      
      program p_sort
      implicit none

      integer i,j,k,l,m,n,s,t,r
      real u,v,lon0,lon1,lat0,lat1,dt
      parameter (t = 4986806,r = 10)

      real, dimension(r,t) :: floats
      real, dimension(r)   :: temp

      
      open(1, file='./floats_subset',
     & form='unformatted',
     & access='direct',
     & recl=4*r*t)

      read (1,rec=1) floats
      close(1)

      write(*,*) 'Sorting...'

      do j=2,t

       i = 0

       if(MOD(j,1000).eq.0) then
        write(*,*) j
       endif

       do while(floats(1,j-i).lt.floats(1,j-i-1))
         temp(:) = floats(:,j-i)
         floats(:,j-i)   = floats(:,j-i-1)
         floats(:,j-i-1) = temp(:)
         i = i + 1
       enddo
      enddo
      
      do j = 1000,2000
      write(*,*) floats(:,j)
      enddo

        open(2, file='./floats_subset_sort',
     & form='unformatted',
     & access='direct',
     & recl=4*t*r)

       write(2,rec=1) floats
       close(2)
      close(1)
      end

