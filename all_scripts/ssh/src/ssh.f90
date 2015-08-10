program ssd
use modiohf  ! HYCOM array I/O interface
IMPLICIT NONE

      CHARACTER*8,parameter :: FLNMR='fort.21A',FLNM='fort.10A', FLNMO='fort.12A'
      CHARACTER*8           :: BUFFER
      INTEGER      IDM,JDM,I,J,k
      REAL*4,allocatable    ::  ssh(:,:)

!
! --- MODEL ARRAYS.
!
      CALL XCSPMD(idm,jdm)  !define idm,jdm

      ALLOCATE( ssh(IDM,JDM) )

     call RHF(FLNM,idm,jdm,2,ssh)

     write(6,*) ssh(5,5)

!     PROCESS ALL THE WIND RECORDS.

call WHF(FLNMO,idm,jdm,1,ssh)
     
END
