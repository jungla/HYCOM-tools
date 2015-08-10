program vorticity
use modiof  ! hycom array i/o interface
use modkinem
use modfunctions

implicit none

      real*4,  allocatable :: qscx(:,:),qscy(:,:)
      real*4,  allocatable :: u(:,:),v(:,:),vort(:,:,:)

      real*4,  parameter   :: onem=1.0
      character*8 :: buffer

      character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      kdm,k,idm,jdm,i,j

      CALL GETARG(1,BUFFER)
      READ(BUFFER,*) kdm

      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(  qscx(idm,jdm) )
      allocate(  qscy(idm,jdm) )
      allocate(  vort(idm,jdm,kdm) )
      allocate( u(idm,jdm) )
      allocate( v(idm,jdm) )

     call rhf(flnmr,idm,jdm,10,qscx)
     call rhf(flnmr,idm,jdm,11,qscy)
!

      do i= 1,idm
        do j= 1,jdm
          qscx(i,j) = 1.0/max(onem,qscx(i,j)) !1/qscx
          qscy(i,j) = 1.0/max(onem,qscy(i,j)) !1/qscy
        enddo
      enddo

!     initialize hycom input and output.



do k=1,kdm
     write(*,*) k
     call rbf(flnmu,idm,jdm,k,u)
     call rbf(flnmv,idm,jdm,k,v)

call vor(vort(:,:,k),qscx,qscy,idm,jdm,u,v)
!call smooth2(vort(:,:,k),1)

!write(*,*) 'vort(500,500,k)',vort(500,500,k)

enddo

call wbf3d(flnmo,idm,jdm,kdm,vort)
     
end
