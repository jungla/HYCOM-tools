program rmsz
 use modkinem     ! hycom array i/o interface
 use modiohf     ! hycom array i/o interface
 use modiobf     ! hycom array i/o interface
 implicit none

 real*4,  allocatable :: qscx(:,:),qscy(:,:),qscxs(:,:), qscys(:,:) ,plon(:,:),plat(:,:),lon(:),lat(:)
 real*4,  allocatable :: u(:,:),v(:,:),q(:,:)
 real*4,  allocatable :: us(:,:),vs(:,:)
 real*4,  allocatable :: rlx(:,:),rly(:,:),hlx(:,:),hly(:,:)
 integer, parameter  :: nl=30
 real*4,  parameter  :: onem=1.0

 character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmo='fort.12A'
 character*8,parameter :: flnmr='fort.21A'
 character*8           :: buffer
 integer      layer,n,id,i,ii,j,jj,k,l,x1,x2,y1,y2,ids,jds,idm,jdm
 real*4       rl,volume,tm,tv,th
 real*4       hl(nl)

 call xcspmd(idm,jdm)  !define idm,jdm

 allocate(   u(idm,jdm) )
 allocate(   v(idm,jdm) )
 allocate(   plon(idm,jdm) )
 allocate(   plat(idm,jdm) )
 allocate(   qscx(idm,jdm) )
 allocate(   qscy(idm,jdm) )

call getarg(1,buffer)
read(buffer,*) x1
call getarg(2,buffer)
read(buffer,*) x2
call getarg(3,buffer)
read(buffer,*) y1
call getarg(4,buffer)
read(buffer,*) y2
call getarg(5,buffer)
read(buffer,*) id
call getarg(6,buffer)
read(buffer,*) layer

 write(*,*) x1, x2, y1, y2, id, layer

 jds = abs(y2-y1+1)
 ids = abs(x2-x1+1)

 allocate(   rlx(ids,nl) )
 allocate(   rly(jds,nl) )
 allocate(   hlx(ids,nl) )
 allocate(   hly(jds,nl) )
 allocate(   q(ids,jds)  )
 allocate(   us(ids,jds)  )
 allocate(   vs(ids,jds)  )
 allocate(   qscxs(ids,jds)  )
 allocate(   qscys(ids,jds)  )
 allocate(   lon(ids) )
 allocate(   lat(jds) )

! needed to normalize r in the volume.

 call rhf(flnmr,idm,jdm,1,plon)
 call rhf(flnmr,idm,jdm,2,plat)

 lat   = plat(1,y1:y2)
 lon   = plon(x1:x2,1)

! set the do loop for the layer

! go trough the layers... set nl equal to the last layer

 hl(:) = 0.0
 rl = 0.0
 hlx(:,:) = 0.0
 rlx(:,:) = 0.0
 hly(:,:) = 0.0
 rly(:,:) = 0.0

     call rhf(flnmr,idm,jdm,10,qscx)
     call rhf(flnmr,idm,jdm,11,qscy)
!

call rbf(flnmu,idm,jdm,layer,u)
call rbf(flnmv,idm,jdm,layer,v)

us = u(x1:x2,y1:y2)
vs = v(x1:x2,y1:y2)
     
qscxs = qscx(x1:x2,y1:y2)
qscys = qscy(x1:x2,y1:y2)

      do i= 1,ids
        do j= 1,jds
          qscxs(i,j) = 1.0/max(onem,qscxs(i,j)) !1/qscx
          qscys(i,j) = 1.0/max(onem,qscys(i,j)) !1/qscy
        enddo
      enddo

!     initialize hycom input and output.

select case (id)
 case (0)    ! vertical section - average in x and y, 1d vector output


   call vor(q,qscxs,qscys,ids,jds,us,vs)
    
   do i=1,ids
    do j=i,jds 
     if(abs(q(i,j)) < 10**8) then
      rl = rl + q(i,j)**2
      n  = n + 1
     endif
    enddo
   enddo

    if (n > 0) then
     rl = sqrt(rl/n)                           ! from mass to density
    else
     rl = 10**9
    endif

 open (unit=21, file=flnmo, status='unknown')
  write (*,*) layer, rl
  write (21,*) layer, rl
!  9010 format( i2,2x,f10.5)
 close(21)

 case (1)   ! longitude section - average in y, 2d vector (depth and x)

!   call rbf(flnm,idm,jdm,n,r)

!   do i = x1,x2
!   ii = i-x1+1
!    do j=y1,y2
!    jj = j-y1+1
!     if(r(i,j) > 0) then
!      rlx(ii)  = rlx(ii) + r(i,j)  
!      n = n + 1
!     endif 
!    enddo
    
!    if (n > 0) then
!     rlx(ii) = rlx(ii)/n                             ! from mass to density
!    else
!     rlx(ii) = 10**9
!    endif

!   enddo   ! x-loop

! open (unit=21, file=flnmo, status='unknown')
!  do i=1,ids
!   if(rlx(i) > 10**8) then
!    rlx(i) = 10**9
!   endif
!   write (21,9011) n, rlx(i), lon(i)
!   9011 format(i2,2(2x,d16.9),2x,f7.3)
!  enddo
! close(21)
 
 case (2)   ! latitude section - average in x, 2d vector (depth and y)

!   volume = 0.0

!   call rhf(flnm,idm,jdm, 9+k*5,h)

!   do j = y1,y2
!   volume = 0  
!   n = 0
!   jj = j-y1+1

!    do i = x1,x2
!    ii = i-x1+1
!     if(h(i,j) > 0 .and. rt == rt) then
!      q(ii,jj) = h(i,j) * rscx(i,j) * rscy(i,j)          ! volume single cube
!      rly(jj,k)   = rly(jj,k) + rt * q(ii,jj)            ! mass   total  
!      volume = volume + q(ii,jj)                         ! volume total
!      hly(jj,k)   = hly(jj,k) + h(i,j)                   ! height total
!      n = n + 1
!     endif
!    enddo

!    if (n > 0) then
!     rly(jj,k) = rly(jj,k)/volume                             ! from mass to density
!     hly(jj,k) = hly(jj,k)/n
!    else
!     rly(jj,k) = 10**9
!     hly(jj,k) = 10**9  
!    endif

!   enddo   ! x-loop

! open (unit=21, file=flnmo, status='unknown')
! do k=1,nl
!  do j=1,jds
!   if(rly(j,k) > 10**8 .or. rly(j,k) .ne. rly(j,k)) then
!    hly(j,k) = 10**9
!    rly(j,k) = 10**9
!   endif
!   write (21,9011) k, hly(j,k), rly(j,k), lat(j)
!  enddo
! enddo
! close(21)

end select

end
