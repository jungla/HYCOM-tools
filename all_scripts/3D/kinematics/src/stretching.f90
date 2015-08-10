program stretching
use modiof
use modkinem
use modfunctions

implicit none
!
!     wind arrays.
!
      real*4,  allocatable :: pscx(:,:),pscy(:,:)
      real*4,  allocatable :: u(:,:),v(:,:),stret(:,:,:)

      real*4,  parameter   :: onem=1.0
      character*8 :: buffer

      character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      k,idm,jdm,i,j
      integer :: kdm

      CALL GETARG(1,BUFFER)
      READ(BUFFER,*) kdm


      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(  pscx(idm,jdm) )
      allocate(  pscy(idm,jdm) )
      allocate(  stret(idm,jdm,kdm) )
      allocate( u(idm,jdm) )
      allocate( v(idm,jdm) )

     call rhf(flnmr,idm,jdm,10,pscx)
     call rhf(flnmr,idm,jdm,11,pscy)
!

      do i= 1,idm
        do j= 1,jdm
          pscx(i,j) = 1.0/max(onem,pscx(i,j)) !1/pscx
          pscy(i,j) = 1.0/max(onem,pscy(i,j)) !1/pscy
        enddo
      enddo

!     initialize hycom input and output.
do k=1,kdm
     write(*,*) k
     call rbf(flnmu,idm,jdm,k,u)
     call rbf(flnmv,idm,jdm,k,v)

call str(stret(:,:,k),pscx,pscy,idm,jdm,u,v)
!call smooth2(stret(:,:,k),1)

write(*,*) stret(500,500,k)

enddo

call wbf3d(flnmo,idm,jdm,kdm,stret)
     
end
