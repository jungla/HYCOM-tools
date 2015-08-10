program density_z
use modiohf     ! HYCOM array I/O interface
use modts2sigma ! HYCOM array I/O interface
IMPLICIT NONE
!
!     WIND ARRAYS.
!
      INTEGER, ALLOCATABLE :: MSK(:,:)
      REAL*4,  ALLOCATABLE :: RSCX(:,:),RSCY(:,:),RSCXs(:,:), RSCYs(:,:)
      REAL*4,  ALLOCATABLE :: Bin(:), Q(:,:),R(:,:),H(:,:),T(:,:),S(:,:),Hs(:,:),Ts(:,:),Ss(:,:)

      INTEGER,  PARAMETER   :: nl=30

      CHARACTER PREAMBL(5)*79

      LOGICAL      PGRID,GLOBAL
      CHARACTER*80 CLINE
      CHARACTER*8,parameter :: FLNM='fort.10A', FLNMO='fort.12A'
      CHARACTER*8,parameter :: FLNMR='fort.21A'
      INTEGER      l,k,x1,x2,y1,y2,ids,jds,IDM,JDM,I,IOS,IM1,IP1,J,JM1,JP1,KREC,NREC,IREC,NPAD
      REAL*4       HMINA,HMINB,HMAXA,HMAXB
      REAL*4       Rt,Area,Volume,HT,XMIN,XMAX
      REAL*4       Rl(nl),Hl(nl)
!
! --- MODEL ARRAYS.
!
      CALL XCSPMD(idm,jdm)  !define idm,jdm

      ALLOCATE(   MSK(IDM,JDM) )
      ALLOCATE(   S(IDM,JDM) )
      ALLOCATE(   T(IDM,JDM) )
      ALLOCATE(   H(IDM,JDM) )
      ALLOCATE(   RSCX(IDM,JDM) )
      ALLOCATE(   RSCY(IDM,JDM) )
!

!     INITIALIZE HYCOM INPUT AND OUTPUT.


!! 1 - select geographical region
!! 2 - read the archives layer after layer until the last layer
!! 3 - read and average T e S and convert to R
!! 4 - read and average the layer thikness, H
!! for each region I produce values for R and values for H

! 1 - REGION selection
! allocate and read the archive

!! Region A
!X1 = 472;
!X2 = 839;
!Y1 = 77;
!Y2 = 267;

!! Region B
!X1 = 840;
!X2 = 1279;
!Y1 = 77;
!Y2 = 267;

!! Region C
!X1 = 619;
!X2 = 986;
!Y1 = 774;
!Y2 = 900;

!! region D
X1 = 472;
X2 = 766;
Y1 = 393;
Y2 = 584;


 jds = y2-y1+1
 ids = x2-x1+1

    ALLOCATE(   Q(ids,jds) )
    ALLOCATE(   Ss(ids,jds) )
    ALLOCATE(   Ts(ids,jds) )
    ALLOCATE(   Hs(ids,jds) )
    ALLOCATE(   RSCXs(ids,jds) )
    ALLOCATE(   RSCYs(ids,jds) )

! needed to normalize R in the volume.

     call RHF(FLNMR,IDM,JDM,10,rscx)
     call RHF(FLNMR,IDM,JDM,11,rscy)

   RSCXs = RSCX(x1:x2,y1:y2)
   RSCYs = RSCY(x1:x2,y1:y2)

! set the do loop for the layer

! go trough the layers... set nl equal to the last layer

Hl(:) = 0.0
Rl(:) = 0.0

do k=1,nl

Area = 0.0
Volume = 0.0

   call RHF(FLNM,idm,jdm,9+k*5,H)
   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)


   Hs = H(x1:x2,y1:y2)/9806
   Ts = T(x1:x2,y1:y2)
   Ss = S(x1:x2,y1:y2)

    do i=1,ids
    do j=1,jds
    call sigma0(Rt,Ts(i,j),Ss(i,j))
     if(Hs(i,j) < 10**8) then
!     write(*,*) Hs(i,j) 
     Q(i,j) = Hs(i,j) * RSCXs(i,j) * RSCYs(i,j) ! mass for grid point and layer
      Rl(k)   = Rl(k) + Rt * Q(i,j)
      Volume = Volume + Q(i,j)
      Hl(k)   = Hl(k) + Hs(i,j)
     endif 
    enddo
    enddo

 if (Volume > 0) then
  Rl(k) = Rl(k)/Volume ! from mass to density
  Hl(k) = Hl(k)/(ids*jds) ! average
  if (k > 1) then
   Hl(k) = Hl(k) + Hl(k-1)
  endif
 endif

enddo


do k=1,nl
write(*,*) 'Density:' ,k, Hl(k), Rl(k)
enddo

! save values in a file, and plot a in matlab
!call WHF(FLNMO,idm,jdm,1,sigma)

END
