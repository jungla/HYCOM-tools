! Recursive Fortran 95 quicksort routine
! sorts real numbers into ascending numerical order
! Author: Juli Rew, SCD Consulting (juliana@ucar.edu), 9/03
! Based on algorithm from Cormen et al., Introduction to Algorithms,
! 1997 printing

! Made F conformant by Walt Brainerd

      module qsort_c_module

      implicit none
      public :: QsortC
      private :: Partition

      contains

      recursive subroutine QsortC(A)
      real, intent(in out), dimension(:,:) :: A
      integer :: iq

      if(size(A,1) > 1) then
      call Partition(A, iq)
      call QsortC(A(:iq-1,:))
      call QsortC(A(iq:,:))
      endif
      end subroutine QsortC

      subroutine Partition(A, marker)
      real, intent(in out), dimension(:,:) :: A
      integer, intent(out) :: marker
      integer :: i, j
      real,dimension(10) :: temp
      real :: x      ! pivot point
      x = A(1,1)
      i= 0
      j= size(A,1) + 1

      do
      j = j-1
      do
        if (A(j,1) <= x) exit
        j = j-1
      end do
      i = i+1
      do
        if (A(i,1) >= x) exit
        i = i+1
      end do
      if (i < j) then
        ! exchange A(i) and A(j)
        temp(:) = A(i,:)
        A(i,:) = A(j,:)
        A(j,:) = temp(:)
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

      program sortdriver
      use qsort_c_module
      implicit none
      integer :: i,j
      integer, parameter :: r = 10
      real, dimension(r,2) :: myarray          ! (1:r)
      do j = 1,r
      myarray(j,1) = 100-j
      myarray(j,2) = j
      enddo
      print *, "myarray is ", myarray
      call QsortC(myarray)
      print *, "sorted array is ", myarray
      end program sortdriver
