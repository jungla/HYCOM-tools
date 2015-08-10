program keenergy
use modiohf  ! HYCOM array I/O interface
IMPLICIT NONE
!
!     WIND ARRAYS.
!
      INTEGER, ALLOCATABLE :: MSK(:,:)
      REAL*4,  ALLOCATABLE :: pscx(:,:),pscy(:,:),RSCX(:,:),RSCY(:,:)
      REAL*4,  ALLOCATABLE :: TXM(:,:),TYM(:,:),ke(:,:), TXP(:),TYP(:),u(:,:),v(:,:),uhyc(:,:),vhyc(:,:)

      REAL*4,  PARAMETER   :: ONEM=1.0

      CHARACTER PREAMBL(5)*79

      LOGICAL      PGRID,GLOBAL
      CHARACTER*80 CLINE,buffer
      CHARACTER*8,parameter :: FLNM='fort.10A', FLNMO='fort.12A'
      CHARACTER*8,parameter :: FLNMR='fort.21A'
      INTEGER      k,IDM,JDM,I,IOS,IM1,IP1,J,JM1,JP1,KREC,NREC,IREC,NPAD
      REAL*4       HMINA,HMINB,HMAXA,HMAXB,temp,area
      REAL*4       XMIN,XMAX
!
! --- MODEL ARRAYS.
!
      CALL XCSPMD(idm,jdm)  !define idm,jdm

      ALLOCATE(   MSK(IDM,JDM) )
      ALLOCATE(  RSCX(IDM,JDM) )
      ALLOCATE(  RSCY(IDM,JDM) )
      ALLOCATE(  pscx(IDM,JDM) )
      ALLOCATE(  pscy(IDM,JDM) )
      ALLOCATE(   TXM(IDM,JDM) )
      ALLOCATE(   TYM(IDM,JDM) )
      ALLOCATE(  ke(IDM,JDM) )
      ALLOCATE( u(IDM,JDM) )
      ALLOCATE( uhyc(IDM,JDM) )
      ALLOCATE( v(IDM,JDM) )
      ALLOCATE( vhyc(IDM,JDM) )
      ALLOCATE(   TXP(0:IDM) )
      ALLOCATE(   TYP(0:JDM) )

     call RHF(FLNMR,IDM,JDM,10,rscx)
     call RHF(FLNMR,IDM,JDM,11,rscy)

! read layer number from scripts

     CALL GETARG(1,buffer)
     READ(BUFFER,*) k

     k = k*5 + 7

      DO I= 1,IDM
        DO J= 1,JDM
          RSCX(I,J) = 1.0/MAX(ONEM,RSCX(I,J)) !1/qscx
          RSCY(I,J) = 1.0/MAX(ONEM,RSCY(I,J)) !1/qscy
        ENDDO
      ENDDO

!     INITIALIZE HYCOM INPUT AND OUTPUT.


     call RHF(FLNM,idm,jdm,10,uHyc)
     call RHF(FLNM,idm,jdm,11,vHyc)
     call RHF(FLNM,idm,jdm,k,u)
     call RHF(FLNM,idm,jdm,k+1,v)

      do i=1,IDM
      do j=1,JDM
      TXM(i,j)=uHyc(i,j)+u(i,j)
      TYM(i,j)=vHyc(i,j)+v(i,j)
      enddo
      enddo


!     PROCESS ALL THE WIND RECORDS.

        DO J= 1,JDM
          IF     (J.NE.JDM) THEN
            JP1 = J+1
          ELSE
            JP1 = JDM  ! assume no change across northern boundary
          ENDIF
          DO I= 1,IDM
            IF     (I.NE.IDM) THEN
              IP1 = I+1
            ELSEIF (GLOBAL) THEN
              IP1 =   1  ! assume     periodic boundary
            ELSE
              IP1 = IDM  ! assume non-periodic boundary
            ENDIF
            TYM(I,J) = 0.25*(TYM(I,  J)   + &
                        TYM(IP1,J)   +     &
                        TYM(I,  JP1) +     &
                        TYM(IP1,JP1)  )

            TXM(I,J) = 0.25*(TXM(I,  J)   +     &
                        TXM(IP1,J)   +     &
                        TXM(I,  JP1) +     &
                        TXM(IP1,JP1)  )
        if(abs(tym(i,j)).gt.10.0**10) tym(i,j) = 0
        if(abs(txm(i,j)).gt.10.0**10) txm(i,j) = 0
         ENDDO
        ENDDO

! total kinetic energy

       do i=1,idm
       do j=1,jdm

       if(txm(i,j).ne.0.and.tym(i,j).ne.0) then
!       temp = pscx(i,j)*pscy(i,j)
       ke(i,j) = (txm(i,j)**2 + tym(i,j)**2)!*temp
!       area = area + pscx(i,j)*pscy(i,j)
       endif

       enddo
       enddo
!       ke = ke/area
!       write(6,*) 'area', area
!       write(6,*) 'kinetic energy', ke

!       WRITE OUT HYCOM CURL.

call WHF(FLNMO,idm,jdm,1,ke)
     
END
