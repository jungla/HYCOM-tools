program geoVel
use modiohf  ! hycom array i/o interface
implicit none

      character*8, parameter :: flnmr='fort.21A',flnm='fort.10A', flnmo='fort.12A'
      character*8            :: buffer
      integer idm,jdm,i,j,k
      real*4, allocatable    ::  ssh(:,:), ug(:,:), vg(:,:)

!
! --- model arrays.
!
      call xcspmd(idm,jdm)  !define idm,jdm

      allocate( ssh(idm,jdm) )
      allocate( ug(idm,jdm) )
      allocate( vg(idm,jdm) )

     call rhf(flnm,idm,jdm,2,ssh)

! compute ug and vg from sea surface height...

call whf(flnmo,idm,jdm,1,ssh)
     
end
