program keenergy

use modiof  ! hycom array i/o interface

implicit none

      real*4,  allocatable :: u(:,:),v(:,:),ke(:,:,:)

      character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer,parameter     :: nl=31
      integer      n,idm,jdm,i,j
      character*8 :: buffer

      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(ke(idm,jdm,nl) )
      allocate( u(idm,jdm) )
      allocate( v(idm,jdm) )

!     initialize hycom input and output.

do n=1,nl

     call rbf(flnmu,idm,jdm,n,u)
     call rbf(flnmv,idm,jdm,n,v)

do i=1,idm
 do j=1,jdm
  if (u(i,j) < 10e10 .and. v(i,j) < 10e10) then
   ke(i,j,n) = 0.5*(u(i,j)**2 + v(i,j)**2)
  else
   ke(i,j,n) = 10e30
  endif
 enddo
enddo

write(*,*) n, ke(100,100,n), u(100,100), v(100,100)

enddo

call wbf3d(flnmo,idm,jdm,nl,ke)
     
end
