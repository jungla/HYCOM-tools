program density_s
 use modiohf     ! HYCOM array I/O interface
 use modts2sigma ! HYCOM array I/O interface
 IMPLICIT NONE

 REAL*4,  ALLOCATABLE :: RSCX(:,:),RSCY(:,:),RSCXs(:,:), RSCYs(:,:) ,plon(:,:),plat(:,:),lon(:),lat(:)
 REAL*4,  ALLOCATABLE :: Q(:,:),R(:,:),H(:,:),T(:,:),S(:,:)!,Hs(:,:),Ts(:,:),Ss(:,:)
 REAL*4,  ALLOCATABLE :: Rlx(:,:),Rly(:,:),Hlx(:,:),Hly(:,:)
 INTEGER, PARAMETER   :: nl=30
 REAL*4,  parameter   :: g=0.000101978

 CHARACTER*8,parameter :: FLNM='fort.10A', FLNMO='fort.12A'
 CHARACTER*8,parameter :: FLNMR='fort.21A'
 CHARACTER*8           :: Buffer
 INTEGER      n,id,i,ii,j,jj,k,l,x1,x2,y1,y2,ids,jds,idm,jdm
 REAL*4       Rt,Volume,TM,TV,TH,V
 REAL*4       Rl(nl),Hl(nl)

 CALL XCSPMD(idm,jdm)  !define idm,jdm

 ALLOCATE(   S(IDM,JDM) )
 ALLOCATE(   T(IDM,JDM) )
 ALLOCATE(   H(IDM,JDM) )
 ALLOCATE(   RSCX(IDM,JDM) )
 ALLOCATE(   RSCY(IDM,JDM) )
 ALLOCATE(   plon(IDM,JDM) )
 ALLOCATE(   plat(IDM,JDM) )

!! 1 - select geographical region (from user input)
!! 2 - according to the script produces averaged sections in x (id = 1),y (id = 2) or both (profiles, id = 0)
!! 3 - read the archive layer after layer
!! 4 - read and average T e S and convert to R
!! 5 - read and average the layer thikness, H
!! 6 - for each region I produce values for R and values for H saved in a binary file

CALL GETARG(1,BUFFER)
READ(BUFFER,*) X1
CALL GETARG(2,BUFFER)
READ(BUFFER,*) X2
CALL GETARG(3,BUFFER)
READ(BUFFER,*) Y1
CALL GETARG(4,BUFFER)
READ(BUFFER,*) Y2
CALL GETARG(5,BUFFER)
READ(BUFFER,*) id

 write(*,*) X1, X2, Y1, Y2, id

 jds = abs(y2-y1+1)
 ids = abs(x2-x1+1)

 ALLOCATE(   Rlx(ids,nl) )
 ALLOCATE(   Rly(jds,nl) )
 ALLOCATE(   Hlx(ids,nl) )
 ALLOCATE(   Hly(jds,nl) )
 ALLOCATE(   Q(ids,jds)  )
 ALLOCATE(   lon(ids) )
 ALLOCATE(   lat(jds) )

! needed to normalize R in the volume.

 call RHF(FLNMR,IDM,JDM,1,plon)
 call RHF(FLNMR,IDM,JDM,2,plat)
 call RHF(FLNMR,IDM,JDM,10,rscx)
 call RHF(FLNMR,IDM,JDM,11,rscy)

 lat   = plat(1,y1:y2)
 lon   = plon(x1:x2,1)

! set the do loop for the layer

! go trough the layers... set nl equal to the last layer

 Hl(:) = 0.0
 Rl(:) = 0.0
 Hlx(:,:) = 0.0
 Rlx(:,:) = 0.0
 Hly(:,:) = 0.0
 Rly(:,:) = 0.0

select case (id)
 case (0)    ! vertical section - average in x and y, 1D vector output

  do k=1,nl
   TM = 0.0 
   TV = 0.0 
   TH = 0.0 
   n = 0

   call RHF(FLNM,idm,jdm,9+k*5,H)
   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)
 
   H(:,:) = H(:,:)*g
    
   do i=x1,x2
    do j=y1,y2 
    call sigma2(Rt,T(i,j),S(i,j))
     if(H(i,j) < 10**5) then
      V        = H(i,j) * RSCX(i,j) * RSCY(i,j)  ! volume single cube
      TM       = TM + Rt * V                     ! mass   total  
      TV       = TV + V                          ! volume total
      TH       = TH + H(i,j)                     ! height total
      n = n + 1
     endif
    enddo
   enddo

    if (n > 0) then
      Rl(k) = TM/TV                             ! from mass to density
      if (k > 1) then
       Hl(k) = TH/n + Hl(k-1)
      else 
       Hl(k) = TH/n
      endif
    else
     Rl(k) = 10**9
     Hl(k) = 10**9
    endif

  enddo

 open (unit=21, file=flnmo, status='unknown')
 do k=1,nl
  write (21,9010) k, Hl(k), Rl(k)
  9010 format( i2,2X,f10.5,2X,f10.5)
 enddo
 close(21)

 case (1)   ! longitude section - average in y, 2D vector (depth and x)

  do k=1,nl

   Volume = 0.0
 
   call RHF(FLNM,idm,jdm, 9+k*5,H)
   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)

   H(:,:) = H(:,:)*g

   do i = x1,x2
   Volume = 0
   n = 0
   ii = i-x1+1

    do j=y1,y2
    jj = j-y1+1
    call sigma2(Rt,T(i,j),S(i,j))
     if(H(i,j) > 0 .and. Rt == Rt) then
      Q(ii,jj) = H(i,j) * RSCX(i,j) * RSCY(i,j)        ! volume single cube
      Rlx(ii,k)   = Rlx(ii,k) + Rt * Q(ii,jj)              ! mass   total  
      Volume = Volume + Q(ii,jj)                         ! volume total
      Hlx(ii,k)   = Hlx(ii,k) + H(i,j)                   ! height total 
      n = n + 1
     endif 
    enddo
    
    if (n > 0) then
     Rlx(ii,k) = Rlx(ii,k)/Volume                             ! from mass to density
     Hlx(ii,k) = Hlx(ii,k)/n
    else
     Rlx(ii,k) = 10**9
     Hlx(ii,k) = 10**9 
    endif

   enddo   ! x-loop

  enddo    ! layers



   do k=2,nl
    Hlx(:,k) = Hlx(:,k) + Hlx(:,k-1)                    ! average layer height
   enddo

 open (unit=21, file=flnmo, status='unknown')
 do k=1,nl
  do i=1,ids
   if(Rlx(i,k) > 10**8 .or. Rlx(i,k) .ne. Rlx(i,k)) then
    Hlx(i,k) = 10**9
    Rlx(i,k) = 10**9
   endif
   write (21,9011) k, Hlx(i,k), Rlx(i,k), lon(i)
   9011 format(I2,2(2X,d16.9),2X,f7.3)
  enddo
 enddo
 close(21)
 
 case (2)   ! latitude section - average in x, 2D vector (depth and y)

  do k=1,nl

   Volume = 0.0

   call RHF(FLNM,idm,jdm, 9+k*5,H)
   call RHF(FLNM,idm,jdm,10+k*5,T)
   call RHF(FLNM,idm,jdm,11+k*5,S)

   H(:,:) = H(:,:)*g 

   do j = y1,y2
   Volume = 0  
   n = 0
   jj = j-y1+1

    do i = x1,x2
    ii = i-x1+1
    call sigma2(Rt,T(i,j),S(i,j))
     if(H(i,j) > 0 .and. Rt == Rt) then
      Q(ii,jj) = H(i,j) * RSCX(i,j) * RSCY(i,j)          ! volume single cube
      Rly(jj,k)   = Rly(jj,k) + Rt * Q(ii,jj)            ! mass   total  
      Volume = Volume + Q(ii,jj)                         ! volume total
      Hly(jj,k)   = Hly(jj,k) + H(i,j)                   ! height total
      n = n + 1
     endif
    enddo

    if (n > 0) then
     Rly(jj,k) = Rly(jj,k)/Volume                             ! from mass to density
     Hly(jj,k) = Hly(jj,k)/n
    else
     Rly(jj,k) = 10**9
     Hly(jj,k) = 10**9  
    endif

   enddo   ! x-loop

  enddo    ! layers

 
   do k=2,nl
    Hly(:,k) = Hly(:,k) + Hly(:,k-1)                    ! average layer height
   enddo

 open (unit=21, file=flnmo, status='unknown')
 do k=1,nl
  do j=1,jds
   if(Rly(j,k) > 10**8 .or. Rly(j,k) .ne. Rly(j,k)) then
    Hly(j,k) = 10**9
    Rly(j,k) = 10**9
   endif
   write (21,9011) k, Hly(j,k), Rly(j,k), lat(j)
  enddo
 enddo
 close(21)

end select

END
