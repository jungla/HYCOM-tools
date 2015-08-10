program layerN_TSR
use modts2sigma ! HYCOM array I/O interface
use modiof     ! HYCOM array I/O interface
IMPLICIT NONE

      REAL*4,  ALLOCATABLE :: R(:,:),T(:,:),S(:,:)

      character*8 :: buffer

      CHARACTER*8,parameter :: FLNM='fort.10A', FLNMT='fort.11A'
      CHARACTER*8,parameter :: FLNMR='fort.12A', FLNMS='fort.13A'
      INTEGER      k,idm,jdm,i,j

      CALL GETARG(1,BUFFER)
      READ(BUFFER,*) k

      CALL XCSPMD(idm,jdm)  !define idm,jdm

      ALLOCATE(   R(IDM,JDM) )
      ALLOCATE(   T(idm,jdm) )
      ALLOCATE(   S(idm,jdm) )


   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)

   do i=1,idm
    do j=1,jdm
    call sigma2(R(i,j),T(i,j),S(i,j))
    enddo
   enddo

   write(*,*) 'T(500,500):',T(500,500)
   write(*,*) 'S(500,500):',S(500,500)
   write(*,*) 'R(500,500):',R(500,500)

! save values in a file, and plot a in matlab
call WHF(FLNMT,idm,jdm,1,T)
call WHF(FLNMR,idm,jdm,1,R)
call WHF(FLNMS,idm,jdm,1,S)
END
