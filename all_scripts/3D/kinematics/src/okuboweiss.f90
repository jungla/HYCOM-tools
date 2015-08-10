program okuboweiss
use modiof  ! hycom array i/o interface
use modkinem
use modfunctions

implicit none

      integer, allocatable :: msk(:,:)
      real*4,  allocatable :: qscx(:,:),qscy(:,:),pscx(:,:),pscy(:,:)
      real*4,  allocatable :: stret(:,:),u(:,:),v(:,:),vort(:,:),shear(:,:),okbwss(:,:,:)

      real*4,  parameter   :: onem=1.0
      character*8 :: buffer

      character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      idm,jdm,i,j,k,kdm

      CALL GETARG(1,BUFFER)
      READ(BUFFER,*) kdm

!     initialize hycom input and output.

      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(  qscx(idm,jdm) )
      allocate(  qscy(idm,jdm) )
      allocate(  vort(idm,jdm) )
      allocate(     u(idm,jdm) )
      allocate(     v(idm,jdm) )
      allocate(  pscx(idm,jdm) )
      allocate(  pscy(idm,jdm) )
      allocate(  stret(idm,jdm) )
      allocate(  shear(idm,jdm) )
      allocate( okbwss(idm,jdm,kdm) )

     call rhf(flnmr,idm,jdm,10,pscx)
     call rhf(flnmr,idm,jdm,11,pscy)
     call rhf(flnmr,idm,jdm,12,qscx)
     call rhf(flnmr,idm,jdm,13,qscy)

      do i= 1,idm
        do j= 1,jdm
          qscx(i,j) = 1.0/max(onem,qscx(i,j)) !1/qscx
          qscy(i,j) = 1.0/max(onem,qscy(i,j)) !1/qscy
          pscx(i,j) = 1.0/max(onem,pscx(i,j)) !1/pscx
          pscy(i,j) = 1.0/max(onem,pscy(i,j)) !1/pscy
        enddo
      enddo

!     initialize hycom input and output.

    do k=1,kdm
     write(*,*) k
     call rbf(flnmu,idm,jdm,k,u)
     call rbf(flnmv,idm,jdm,k,v)
     call vor(vort,qscx,qscy,idm,jdm,u,v)
     call shr(shear,qscx,qscy,idm,jdm,u,v)
     call str(stret,pscx,pscy,idm,jdm,u,v)
     call okw(okbwss(:,:,k),idm,jdm,stret,shear,vort,u,v)
     write(*,*) okbwss(500,500,k)
    enddo

call wbf3d(flnmo,idm,jdm,kdm,okbwss)
     
end
