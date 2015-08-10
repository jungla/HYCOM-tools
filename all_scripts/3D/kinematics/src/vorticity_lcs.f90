program vorticity
use modiof  ! hycom array i/o interface
use modkinem
use modfunctions

implicit none

      real*4,  allocatable :: tqscx(:,:),tqscy(:,:),qscx(:,:),qscy(:,:)
      real*4,  allocatable :: u(:,:),v(:,:),vort(:,:,:)

      real*4,  parameter   :: onem=1.0
      character*8 :: buffer

      character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      kdm,k,idm,jdm,i,j,ids,jds,X1,X2,Y1,Y2

      CALL GETARG(1,BUFFER)
      READ(BUFFER,*) kdm
      CALL GETARG(2,BUFFER)
      READ(BUFFER,*) X1
      CALL GETARG(3,BUFFER)
      READ(BUFFER,*) X2
      CALL GETARG(4,BUFFER)
      READ(BUFFER,*) Y1
      CALL GETARG(5,BUFFER)
      READ(BUFFER,*) Y2
  
      ids = X2-X1
      jds = Y2-Y1

      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(  tqscx(idm,jdm) )
      allocate(  tqscy(idm,jdm) )
      allocate(  qscx(ids,jds) )
      allocate(  qscy(ids,jds) )
      allocate(  vort(ids,jds,kdm) )
      allocate( u(ids,jds) )
      allocate( v(ids,jds) )

     call rhf(flnmr,idm,jdm,10,tqscx)
     call rhf(flnmr,idm,jdm,11,tqscy)

     qscx(:,:) = tqscx(X1:X2-1,Y1:Y2-1)
     qscy(:,:) = tqscy(X1:X2-1,Y1:Y2-1)
!

      do i= 1,ids
        do j= 1,jds
          qscx(i,j) = 1.0/max(onem,qscx(i,j)) !1/qscx
          qscy(i,j) = 1.0/max(onem,qscy(i,j)) !1/qscy
        enddo
      enddo


!     initialize hycom input and output.



do k=1,kdm
     write(*,*) k
     call rbf(flnmu,ids,jds,k,u)
     call rbf(flnmv,ids,jds,k,v)

     call vor(vort(:,:,k),qscx,qscy,ids,jds,u,v)
     !call smooth2(vort(:,:,k),1)

!write(*,*) 'vort(500,500,k)',vort(500,500,k)

enddo

write(*,*) 'writing...'
call wbf3d(flnmo,ids,jds,kdm,vort)
 
end
