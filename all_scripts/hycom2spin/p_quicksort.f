C notice that the size of the incoming array has to be given.
C the script p_bin.f produce a binary file from the ASCII file
C selecting a set of particles.
C It gives as standard output the size of that array.

      module qsort_c_module

      implicit none
      public :: QsortC
      private :: Partition

      contains

      recursive subroutine QsortC(A, w)
      real, intent(in out), dimension(:,:) :: A
      integer :: iq, w


      if(size(A,2) > 1) then
c      if(size(A,2) > 100000) write(*,*) size(A,2)
      call Partition(A, iq, w)
      call QsortC(A(:,:iq-1), w)
      call QsortC(A(:,iq:), w)
      endif
      end subroutine QsortC

      subroutine Partition(A, marker, w)
      real, intent(in out), dimension(:,:) :: A
      integer, intent(out) :: marker
      integer :: i, j, w
      real, dimension(10) :: temp
      real :: x      ! pivot point

      x = A(w,1)

      i = 0
      j = size(A,2) + 1 

      do  

      j = j-1 

      do
        if (A(w,j) <= x) exit
        j = j-1
      end do

      i = i+1 
      do  
        if (A(w,i) >= x) exit
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

      integer i,j,k,l,m,n,s,t,r,p,li,ls
      real u,v,lon0,lon1,lat0,lat1,dt,point
      parameter (t = 4986806,r = 10,p = 5944)

      real, dimension(r,t)   :: floats,ffloats
      integer, dimension(r)  :: ti,ts
      real, allocatable      :: f_temp(:,:)      

      open(1, file='./floats_subset',
     & form='unformatted')

      read (1) floats
      close(1)

      write(*,*) 'Sorting IDs'

      call QsortC(floats, 1)


c      do i=1,t,1000
c      write(*,*) floats(:,i)
c      enddo

c      open(3,file='./sorted_temp',form='unformatted',
c     & access='append')

      write(*,*) 'Sorting Time'

      do i=1,t
       do j=1,r
       ffloats(r,i) = 0.0
       enddo
      enddo

      point = 0



c     first value loop...
      
      ts = t
      ti = maxloc(floats(1,:),1,floats(1,:).le.p)
      li = ti(1)
      ls = ts(1)

       allocate(f_temp(10,li:ls))
       f_temp(:,:) = floats(:,li:ls)

       call QsortC(f_temp, 2)

       ffloats(:,li:ls) = f_temp(:,:)


       deallocate(f_temp)
       
      write(*,*) 'Particle:'

      do i=p,2,-1

      ti = maxloc(floats(1,:),1,floats(1,:).le.i-1)
      ts = maxloc(floats(1,:),1,floats(1,:).le.i)
c      point = ts(1)-ti(1)+point
      li = ti(1)
      ls = ts(1)-1

c       write(*,*) floats(1:4,ls:ls)
c       write(*,*) floats(1:4,li:li)
c       write(*,*) 'limits', ls,li
c
       allocate(f_temp(10,li:ls))
       f_temp(:,:) = floats(:,li:ls)

       call QsortC(f_temp, 2)

       ffloats(:,li:ls) = f_temp(:,:)

       deallocate(f_temp)
       
       enddo

        open(2, file='./floats_subset_quicksort',
     & form='unformatted')

       write(2) ffloats
       close(2)

      end program p_quicksort

