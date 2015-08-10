program bpe
use modiohf     ! HYCOM array I/O interface
use modts2sigma ! HYCOM array I/O interface
IMPLICIT NONE
!
!     WIND ARRAYS.
!
      INTEGER, ALLOCATABLE :: MSK(:,:)
      REAL*4,  ALLOCATABLE :: RSCX(:,:),RSCY(:,:),RSCXs(:,:), RSCYs(:,:)
      REAL*4,  ALLOCATABLE :: Bin(:), Q(:,:),R(:,:),H(:,:),T(:,:),S(:,:),Hs(:,:),Ts(:,:),Ss(:,:)

      INTEGER,  PARAMETER   :: nl=4,step=100

      CHARACTER PREAMBL(5)*79

      LOGICAL      PGRID,GLOBAL
      CHARACTER*80 CLINE
      CHARACTER*8,parameter :: FLNM='fort.10A', FLNMO='fort.12A'
      CHARACTER*8,parameter :: FLNMR='fort.21A'
      INTEGER      l,k,x1,x2,y1,y2,ids,jds,IDM,JDM,I,IOS,IM1,IP1,J,JM1,JP1,KREC,NREC,IREC,NPAD
      REAL*4       HMINA,HMINB,HMAXA,HMAXB
      REAL*4       Rt,dR,Area,HT,Rmax,Rmin,XMIN,XMAX
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
!! 2 - read the archives layer after layer
!! 3 - read T e S and convert to R
!! 4 - normalize R with layer thikness
!! I can now make a pdf for each day in the specific region
!! ...compute BPE and APE in some way.

! 1 - REGION selection
! allocate and read the archive

!! Region A
! x1 = 3.0/8.0*idm
! x2 = 5.0/8.0*idm
! y1 = 3.0/8.0*jdm
! y2 = 5.0/8.0*jdm

!! Region B
 x1 = 3.0/4.0*idm -10
 x2 = idm -10
 y1 = 3.0/4.0*jdm -10
 y2 = jdm -10

 ids = x2-x1+1
 jds = y2-y1+1

    ALLOCATE(   R(ids,jds) )
    ALLOCATE(   Q(ids,jds) )
    ALLOCATE(   Ss(ids,jds) )
    ALLOCATE(   Ts(ids,jds) )
    ALLOCATE(   Hs(ids,jds) )
    ALLOCATE(   RSCXs(ids,jds) )
    ALLOCATE(   RSCYs(ids,jds) )
    allocate(   Bin(step))

! needed to normalize R in the volume.

     call RHF(FLNMR,IDM,JDM,10,rscx)
     call RHF(FLNMR,IDM,JDM,11,rscy)

   RSCXs = RSCX(x1:x2,y1:y2)
   RSCYs = RSCY(x1:x2,y1:y2)


! set the do loop for the layer

Rmax = 0.0
Rmin = 100
Bin(:) = 0.0

! first I have to find the lowest and highest value of density,
do k = 1,nl
   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)
   
   Ts = T(x1:x2,y1:y2)
   Ss = S(x1:x2,y1:y2)

! sublayer

   do i=1,ids
    do j=1,jds
     if (Ts(i,j) < 100 .and. Ss(i,j) < 100) then
     call sigma0(Rt,Ts(i,j),Ss(i,j))
     Rmax = max(Rmax,Rt)
     Rmin = min(Rmin,Rt)
     endif
    enddo
   enddo

enddo

!write(*,*) Rmax, Rmin
! define pdf...

dR = (Rmax-Rmin)/step

do k=1,nl
Area = 0.0
   call RHF(FLNM,idm,jdm,9+k*5,H)
   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)


   Hs = H(x1:x2,y1:y2)
   Ts = T(x1:x2,y1:y2)
   Ss = S(x1:x2,y1:y2)

  do l=1,step
    do i=1,ids
    do j=1,jds
    call sigma0(Rt,Ts(i,j),Ss(i,j))
     if(Rt < (Rmin+l*dR) .and. Rt >= (Rmin+(l-1)*dR) .and. Hs(i,j) > 0) then
      Q(i,j) = Hs(i,j)*RSCXs(i,j)*RSCYs(i,j) ! mass for grid point and layer
      Area = RSCXs(i,j)*RSCYs(i,j) + Area ! for normalization
      Bin(l) = Bin(l) + Rt*Q(i,j)
     endif 
    enddo
    enddo
  enddo

Bin = Bin/Area
enddo


do l=1,step
write(*,*) 'Bin:', Bin(l), (Rmin+l*dR)
enddo

! save values in a file, and plot a in matlab
!call WHF(FLNMO,idm,jdm,1,sigma)

END
