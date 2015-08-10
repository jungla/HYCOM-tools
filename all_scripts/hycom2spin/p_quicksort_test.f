C notice that the size of the incoming array has to be given.
C the script p_bin.f produce a binary file from the ASCII file
C selecting a set of particles.
C It gives as standard output the size of that array.

      module qsort_c_module

      implicit none
      public :: QsortC
      private :: Partition

      contains

      recursive subroutine QsortC(A)
      real, intent(in out), dimension(:,:) :: A
      integer :: iq

      if(size(A,2) > 1) then
      write(*,*) size(A,2)

      call Partition(A, iq) 
      call QsortC(A(:,:iq-1))
      call QsortC(A(:,iq:))
      endif
      end subroutine QsortC

      subroutine Partition(A, marker)
      real, intent(in out), dimension(:,:) :: A
      integer, intent(out) :: marker
      integer :: i, j
      real, dimension(10) :: temp
      real :: x      ! pivot point
      x = A(1,1)
      i = 0
      j = size(A,2) + 1 

      do  
      j = j-1 
      do  
        if (A(1,j) <= x) exit
        j = j-1 
      end do
      i = i+1 
      do  
        if (A(1,i) >= x) exit
        i = i+1 
      end do
      if (i < j) then
        ! exchange A(i) and A(j)
        temp = A(:,i)
        A(:,i) = A(:,j)
        A(:,j) = temp
      elseif (i == j) then
        marker = i+1
        return
      else
        marker = i
        return
      endif
       end do

      end subroutine Partition

      end module qsort_c_module
      
      program p_quicksort
      use qsort_c_module
      implicit none

      integer i,j,k,l,m,n,s,t,r
      real u,v,lon0,lon1,lat0,lat1,dt
      parameter (t = 4986806,r = 10)

      real, dimension(r,t) :: floats
      real, dimension(r)   :: temp

      
      open(1, file='./floats_subset',
     & form='unformatted')!,
c     & access='direct',
c     & recl=4*r*t)

      read (1) floats
      close(1)

      write(*,*) 'Sorting...'

      call QsortC(floats)

C whenever this will work it will still be missing a loop to order the date within a same id...

      do j = 1000,2000
      write(*,*) floats(:,j)
      enddo

        open(2, file='./floats_subset_quicksort',
     & form='unformatted')

       write(2) floats
       close(2)

      end program p_quicksort

