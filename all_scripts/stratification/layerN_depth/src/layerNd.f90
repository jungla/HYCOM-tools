program layernd
use modiof     ! hycom array i/o interface
implicit none
!
!     wind arrays.
!
      real*4,  allocatable :: rscx(:,:),rscy(:,:)
      real*4,  allocatable :: h(:,:,:)

      character*8,parameter :: flnm='fort.10A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      l,k,idm,jdm,i

      integer, parameter :: nl = 30

      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(   h(idm,jdm,nl) )

   h(:,:,:) = 0

   call rhf(flnm,idm,jdm,9+5,h(:,:,1))
   h(:,:,1) = h(:,:,1)/9806

do k=2,nl
   call rhf(flnm,idm,jdm,9+k*5,h(:,:,k))
   h(:,:,k) = h(:,:,k-1) + h(:,:,k)/9806
   write(*,*) 'h(500,500,',k,'):',h(500,500,k)
enddo

! save values in a file, and plot a in matlab
call wbf3d(flnmo,idm,jdm,nl,h)
end
