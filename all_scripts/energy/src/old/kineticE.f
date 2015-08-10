      PROGRAM kineticE
      USE MOD_ZA  ! HYCOM array I/O interface
      IMPLICIT NONE
C
C     WIND ARRAYS.
C
      INTEGER, ALLOCATABLE :: MSK(:,:)
      REAL*4,  ALLOCATABLE :: pscx(:,:),pscy(:,:),
     & RSCX(:,:),RSCY(:,:)

      REAL*4,  ALLOCATABLE :: TXM(:,:),TYM(:,:),CURL(:,:),QCURL(:,:),
     &                  TXP(:),TYP(:),u(:,:),v(:,:),uhyc(:,:),vhyc(:,:)
      REAL*4,  PARAMETER   :: ONEM=1.0
      
C
      CHARACTER PREAMBL(5)*79
C
C**********
C
C *** Mean Kinetic Energy
C
C
C 1)  CALCULATE THE CURL OF EXISTING HYCOM WIND STRESS FILES.
C
C 2)  INPUT
C        ON UNIT 10:    .a/.b FORMAT MODEL TAUEWD  FILE, SEE (3).
C        ON UNIT 11:    .a/.b FORMAT MODEL TAUNWD  FILE, SEE (3).
C        ON UNIT 21:    .a/.b FORMAT regional.grid FILE.
C     OUTPUT:
C        ON UNIT 12:    .a/.b FORMAT MODEL CURL    FILE, SEE (4).
C
C 3)  THE INPUT WIND STRESSES HAVE THEIR COMPONENTS ON EITHER
C      EVERY POINT OF THE MODEL'S 'U' AND 'V' GRIDS RESPECTIVELY,
C      OR BOTH ON EVERY POINT OF THE MODEL'S 'P' GRID.  IF ON THE
C      P-GRID, IT IS FIRST INTERPOLATED TO THE U AND V GRIDS AND
C      THEN THE CURL CALCULATED FROM THE STRESSES ON THESE GRIDS.
C
C 4)  THE CURL IS CALCULATED ON THE STREAMFUNCTION-GRID, AS IS
C      NATURAL FOR STRESSES ON THE U AND V GRIDS, AND INTERPOLATED
C      TO THE P-GRID FOR OUTPUT.  THIS MAY REDUCE ACCURACY.
C      ARRAY SIZE IS 'IDM' BY 'JDM', AND THE DATA IS OUTPUT .a/.b
C      FORMAT TOGETHER WITH EITHER (A) THE MONTH, OR (B) THE DAY THE
C      WIND REPRESENTS AND THE INCREMENT IN DAYS TO THE NEXT WIND
C      RECORD.  
C
C 5)  ALAN J. WALLCRAFT,  NRL,  NOVEMBER 2002.
C*
C**********
C
      LOGICAL      PGRID,GLOBAL
      CHARACTER*80 CLINE
      CHARACTER*10 FLNM
      INTEGER      I,IOS,IM1,IP1,J,JM1,JP1,KREC,NREC,IREC,NPAD
      REAL*4       HMINA,HMINB,HMAXA,HMAXB
      REAL*4       XMIN,XMAX,temp,area,ke
C
C --- MODEL ARRAYS.
C
      CALL XCSPMD  !define idm,jdm
      ALLOCATE(  MSK(IDM,JDM) )
      ALLOCATE(  RSCX(IDM,JDM) )
      ALLOCATE(  RSCY(IDM,JDM) )
      ALLOCATE(  pscx(IDM,JDM) )
      ALLOCATE(  pscy(IDM,JDM) )
      ALLOCATE(  TXM(IDM,JDM) )
      ALLOCATE(  TYM(IDM,JDM) )
      ALLOCATE(  CURL(IDM,JDM) )
      ALLOCATE( QCURL(IDM,JDM) )
      ALLOCATE( u(IDM,JDM) )
      ALLOCATE( uhyc(IDM,JDM) )
      ALLOCATE( v(IDM,JDM) )
      ALLOCATE( vhyc(IDM,JDM) )
      ALLOCATE(  TXP(0:IDM) )
      ALLOCATE(  TYP(0:JDM) )
C     GRID INPUT.
C
      CALL ZAIOST
C
      CALL ZHOPNC(21, 'regional.grid.b', 'FORMATTED', 'OLD', 0)
      CALL ZAIOPF('regional.grid.a', 'OLD', 21)
C
      READ(21,*) ! skip idm
      READ(21,*) ! skip jdm
      READ(21,*) ! skip mapflg
      READ(21,'(A)') CLINE  !read plon range
C      WRITE(6,'(A)') CLINE
      I = INDEX(CLINE,'=')
      READ(CLINE(I+1:),*) HMINB,HMAXB
      GLOBAL = HMAXB-HMINB .GT. 350.0
      CALL ZAIOSK(21)       ! skip plon
      READ(21,*) ! skip plat
      CALL ZAIOSK(21)
      READ(21,*) ! skip qlon
      CALL ZAIOSK(21)
      READ(21,*) ! skip qlat
      CALL ZAIOSK(21)
      READ(21,*) ! skip ulon
      CALL ZAIOSK(21)
      READ(21,*) ! skip ulat
      CALL ZAIOSK(21)
      READ(21,*) ! skip vlon
      CALL ZAIOSK(21)
      READ(21,*) ! skip vlat
      CALL ZAIOSK(21)
      READ(21,*) ! skip pang
      CALL ZAIOSK(21)
C      READ(21,*) ! skip pscx
C      CALL ZAIOSK(21)
C      READ(21,*) ! skip pscy
C      CALL ZAIOSK(21)
C
      READ(21,'(A)') CLINE
C      WRITE(6,'(A)') CLINE
      I = INDEX(CLINE,'=')
      READ(CLINE(I+1:),*) HMINB,HMAXB
      CALL ZAIORD(RSCX,MSK,.FALSE., HMINA,HMAXA, 21)
      IF     (ABS(HMINA-HMINB).GT.ABS(HMINB)*1.E-4 .OR.
     &        ABS(HMAXA-HMAXB).GT.ABS(HMAXB)*1.E-4     ) THEN
        WRITE(6,'(/ a / a,1p3e14.6 / a,1p3e14.6 /)')
     &    'error - .a and .b grid files not consistent (qscx):',
     &    '.a,.b min = ',HMINA,HMINB,HMINA-HMINB,
     &    '.a,.b max = ',HMAXA,HMAXB,HMAXA-HMAXB
        CALL ZHFLSH(6)
        STOP
      ENDIF
C
      READ(21,'(A)') CLINE
c      WRITE(6,'(A)') CLINE
      I = INDEX(CLINE,'=')
      READ(CLINE(I+1:),*) HMINB,HMAXB
      CALL ZAIORD(RSCY,MSK,.FALSE., HMINA,HMAXA, 21)
      IF     (ABS(HMINA-HMINB).GT.ABS(HMINB)*1.E-4 .OR.
     &        ABS(HMAXA-HMAXB).GT.ABS(HMAXB)*1.E-4     ) THEN
        WRITE(6,'(/ a / a,1p3e14.6 / a,1p3e14.6 /)')
     &    'error - .a and .b grid files not consistent (qscy):',
     &    '.a,.b min = ',HMINA,HMINB,HMINA-HMINB,
     &    '.a,.b max = ',HMAXA,HMAXB,HMAXA-HMAXB
        CALL ZHFLSH(6)
        STOP
      ENDIF
C
      CLOSE(UNIT=21)
      CALL ZAIOCL(21)
C

      DO I= 1,IDM
        DO J= 1,JDM
          pscx(i,j) = rscx(i,j) 
          pscy(i,j) = rscy(i,j) 
          RSCX(I,J) = 1.0/MAX(ONEM,RSCX(I,J)) !1/qscx
          RSCY(I,J) = 1.0/MAX(ONEM,RSCY(I,J)) !1/qscy
        ENDDO
      ENDDO
C
C     INITIALIZE HYCOM INPUT AND OUTPUT.
C
c      CALL ZAIOPN('OLD', 10)
c      CALL ZAIOPN('OLD', 11)
      CALL ZAIOPN('NEW', 12)
c      CALL ZHOPEN(10, 'FORMATTED', 'OLD', 0)
c      CALL ZHOPEN(11, 'FORMATTED', 'OLD', 0)
      CALL ZHOPEN(12, 'FORMATTED', 'NEW', 0)


      NPAD=4096-mod(IDM*JDM,4096)

      FLNM='fort.10A'

      NREC=4*(IDM*JDM+NPAD)
      open(100,file=FLNM,form='unformatted',access='direct',
     .     recl=NREC,status='old')


      IREC=10
      read(100,rec=IREC)uHyc

      IREC=11
      read(100,rec=IREC)vHyc

c     uclinic first layer
      IREC=27
      read(100,rec=IREC) u
c     vclinic first layer
      IREC=28
      read(100,rec=IREC) v

      do i=1,IDM
      do j=1,JDM
      TXM(i,j)=uHyc(i,j)+u(i,j)
      TYM(i,j)=vHyc(i,j)+v(i,j)
      enddo
      enddo


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
            TYM(I,J) = 0.25*(TYM(I,  J)   +
     &                        TYM(IP1,J)   +
     &                        TYM(I,  JP1) +
     &                        TYM(IP1,JP1)  )

            TXM(I,J) = 0.25*(TXM(I,  J)   +
     &                        TXM(IP1,J)   +
     &                        TXM(I,  JP1) +
     &                        TXM(IP1,JP1)  )
        if(abs(tym(i,j)).gt.10.0**10) tym(i,j) = 0
        if(abs(txm(i,j)).gt.10.0**10) txm(i,j) = 0
         ENDDO
        ENDDO

C total kinetic energy

       do i=1,idm
       do j=1,jdm

       if(txm(i,j).ne.0.and.tym(i,j).ne.0) then
       temp = pscx(i,j)*pscy(i,j)
       ke = ke + (txm(i,j)**2 + tym(i,j)**2)*temp
       area = area + pscx(i,j)*pscy(i,j)    
       endif

       enddo
       enddo
       ke = ke/area
C       write(6,*) 'area', area
       write(6,*) 'kinetic energy', ke
C 
        CALL ZAIOWR(CURL,MSK,.FALSE., XMIN,XMAX, 12, .FALSE.)
        CALL ZHFLSH(12)
        CALL ZHFLSH( 6)
  810 CONTINUE
C
C      CALL ZAIOCL(10)
C      CLOSE( UNIT=10)
C      CALL ZAIOCL(11)
C      CLOSE( UNIT=11)
      CALL ZAIOCL(12)
      CLOSE( UNIT=12)
      STOP
C
C     END OF PROGRAM WNDCUR.
      END
