program omega

use modiof
use modkinem
use modqg

implicit none 

integer,parameter       :: nl = 21                                                      ! # layers, # scans, projection factor
!integer,parameter       :: ns = 240                                                     ! # layers, # scans, projection factor
integer                 :: ns                                                           ! # layers, # scans, projection factor
character*8,parameter   :: flnmo = 'fort.00A', flnmg = 'fort.01A', flnmgn = 'fort.02A'  ! output
character*8,parameter   :: flnmu = 'fort.10A', flnmv = 'fort.11A', flnmd = 'fort.12A'   ! u,v,density
character*8,parameter   :: flnmr = 'fort.21A', flnmh = 'fort.09A', flnmm = 'fort.08A'   ! regional grid, ssh
!real*4 , parameter      :: alpha  = 0.01, eps = 10e-9                                   ! relaxation parameter
real*4                  :: alpha, eps                                                   ! relaxation parameter
real*4 , parameter      :: omg  = 7.2921150e-5, gf = 9.907
real*4 , parameter      :: pi   = 3.1415926535897932384626433832795

integer                 :: z(nl),     dz,        idm,       jdm,       i,         j,       l, t, s
real*4                  :: sumg,      dz1,       dz2,       idz1,      idz2,      idz12
real*4, allocatable     :: O(:,:,:),  ON(:,:,:), G(:,:,:),  GN(:,:,:), B(:,:,:),  ER(:,:,:)
real*4, allocatable     :: Ox(:,:),   Oy(:,:),   Qx(:,:),   Qy(:,:)
real*4, allocatable     :: r(:,:,:),  N2(:,:,:)
real*4, allocatable     :: plon(:,:), plat(:,:), uscx(:,:), uscy(:,:), vscx(:,:), vscy(:,:)
real*4, allocatable     :: pscx(:,:), pscy(:,:), ipscx(:,:), ipscy(:,:)
real*4, allocatable     :: ug(:,:),   vg(:,:),   f(:,:),    assh(:,:), ssh(:,:),  mssh(:,:)
real*4, allocatable     :: ugx(:,:),  vgy(:,:),  rx(:,:),   ry(:,:)
real*4, allocatable     :: slog(:)
character*8 :: buffer

CALL GETARG(1,BUFFER)
READ(BUFFER,*) ns
CALL GETARG(2,BUFFER)
READ(BUFFER,*) alpha
CALL GETARG(3,BUFFER)
READ(BUFFER,*) eps

write(*,*) 'ns:',ns,'alpha:',alpha,'eps:',eps

call xcspmd(idm,jdm)  !define idm,jdm

! 3D fields
allocate (  O(idm,jdm,nl))
allocate ( ON(idm,jdm,nl))
allocate (  G(idm,jdm,nl))
allocate ( GN(idm,jdm,nl))
allocate ( ER(idm,jdm,nl))
allocate (  r(idm,jdm,nl))
allocate ( N2(idm,jdm,nl))
allocate (  B(idm,jdm,nl))

! 2D fields
allocate (    Qx(idm,jdm))
allocate (    Qy(idm,jdm))
allocate (    Ox(idm,jdm))
allocate (    Oy(idm,jdm))
allocate (     f(idm,jdm))
allocate (   ssh(idm,jdm))
allocate (  mssh(idm,jdm))
allocate (  assh(idm,jdm))
allocate (  pscx(idm,jdm))
allocate (  pscy(idm,jdm))
allocate ( ipscx(idm,jdm))
allocate ( ipscy(idm,jdm))
allocate (  plat(idm,jdm))
allocate (  plon(idm,jdm))
allocate (  uscx(idm,jdm))
allocate (  uscy(idm,jdm))
allocate (  vscx(idm,jdm))
allocate (  vscy(idm,jdm))

allocate (  ug(idm,jdm))
allocate ( ugx(idm,jdm))
allocate (  vg(idm,jdm))
allocate ( vgy(idm,jdm))
allocate (  rx(idm,jdm))
allocate (  ry(idm,jdm))

! 1D fields
allocate (  slog(ns))

call rbf(flnmm,idm,jdm,1, mssh(:,:))
call rhf(flnmh,idm,jdm,2,  ssh(:,:))
call rhf(flnmr,idm,jdm,1, plat(:,:)) 
call rhf(flnmr,idm,jdm,2, plon(:,:)) 
call rhf(flnmr,idm,jdm,10,pscx(:,:)) 
call rhf(flnmr,idm,jdm,11,pscy(:,:)) 
call rhf(flnmr,idm,jdm,14,uscx(:,:)) 
call rhf(flnmr,idm,jdm,15,uscy(:,:)) 
call rhf(flnmr,idm,jdm,16,vscx(:,:)) 
call rhf(flnmr,idm,jdm,17,vscy(:,:)) 

ipscx(:,:) = 1/pscx(:,:)**2
ipscy(:,:) = 1/pscy(:,:)**2

do l = 2,nl+1
 call rbf(flnmd,idm,jdm,l,r(:,:,l-1))
enddo

! depths
! z(1) = 0
 z(1) = 10
 z(2) = 20
 z(3) = 30
 z(4) = 40
 z(5) = 50
 z(6) = 60
 z(7) = 70
 z(8) = 80
 z(9) = 90
 z(10) = 100
 z(11) = 200
 z(12) = 300
 z(13) = 400
 z(14) = 500
 z(15) = 700
 z(16) = 1000
 z(17) = 1500
 z(18) = 2000
 z(19) = 2500
 z(20) = 3000
 z(21) = 4000

!!! compute f, GeoVel and BVfreq

do i = 1,idm
 do j = 1,jdm
  f(i,j) = 2*omg*sin(plat(i,j)*pi/90)
 enddo
enddo

!!! NOTICE all quantities have to be in p-points !!!
!!! It is assumed that the interpolation in z-coord respects the position of the the quantities

!!! Geo Velocities

! initialize the fields
 ug  = 10e30
 vg  = 10e30
 vgy = 10e30
 ugx = 10e30
 rx  = 10e30
 ry  = 10e30
 Qx  = 10e30
 Qy  = 10e30
 O   = 0.0
 N2  = 10e30
 GN = 0
 G  = 0

 assh(:,:) = ssh(:,:) - mssh(:,:)

! visualize the content of ssh and r
101 format(A, I2)

! do j = 1,5
!  do i = idm-5,idm
!   if(r(i,j,1) .lt. 10e10) then
!    write(*,101,advance='no') 'o'
!   else
!    write(*,101,advance='no') 'x'
!   endif
!  enddo
!  write(*,*) j
! enddo

! do j = 1,5
!  do i = idm-5,idm
!   if(ssh(i,j) .lt. 10e10) then
!    write(*,101,advance='no') 'o'
!   else
!    write(*,101,advance='no') 'x'
!   endif
!  enddo
!  write(*,*) j
! enddo

! for some reason, in r there are more NaNs that ssh...
! in particular near the boundaries

! r
! xxxxxx           
! oooooo           
! oooooo           
! oooooo           
! oooooo           

! ssh
! xxxxxx           
! ooooox           
! ooooox           
! ooooox           
! ooooox           

! sanitaze r and assh

 do i = 1,idm
  do j = 1,jdm
   if(abs(assh(i,j)) .gt. 10e10 .or. abs(r(i,j,1)) .gt. 10e10) then
    assh(i,j) = 10e30
     r(i,j,:) = 10e30
   else if (assh(i,j) .ne. assh(i,j)) then
    assh(i,j) = 10e30
   endif
  enddo
 enddo

 

! from p to p (ssh is in p-points)

call ddc(ug,assh,vscy,2)
call ddc(vg,assh,uscx,1)

 ug(:,:) = -gf/f(:,:) * ug(:,:) / 10
 vg(:,:) =  gf/f(:,:) * vg(:,:) / 10

! from p to p
call ddc(ugx,ug,uscx,1)
call ddc(vgy,vg,vscy,2)
write(*,*) 'done with Ug and grad(Ug)'


call BVfreq(N2,r,z)
write(*,*) 'done with N2'

!+++++ loops +++++!

!!!!!!!!!!!!!!! first compute RHS

do l = 1,nl

rx = 10e30
ry = 10e30
Qx = 10e30
Qy = 10e30

call ddc(rx,r(:,:,l),uscx,1)
call ddc(ry,r(:,:,l),vscy,2)

do i=1,idm
 do j=1,jdm
  if (r(i,j,l) .lt. 100 .and. rx(i,j) .lt. 10e10 .and. ry(i,j) .lt. 10e10) then
   Qx(i,j) = 2*gf/r(i,j,l) * ugx(i,j) * rx(i,j)
   Qy(i,j) = 2*gf/r(i,j,l) * vgy(i,j) * ry(i,j)
  endif
 enddo
enddo

! div() goes from u to p points
! call div(G(:,:,l),pscx,pscy,idm,jdm,Qx,Qy) 
! centered dirrences are needed!
! save some space and reuse Qx,Qy

!i = 400
!j = 400

call ddc(Qx,Qx,uscx,1)
call ddc(Qy,Qy,vscy,2)

G(:,:,l) = (Qx + Qy)/f(:,:)**2

!write(*,*) l,G(i,j,l), Qx(i,j), Qy(i,j), rx(i,j), r(i,j,l)
!write(*,101,advance='no') ' ', l

! sanitize boundaries and land

B(:,:,l) = N2(:,:,l)/f(:,:)**2

do i=1,idm
 do j=1,jdm
  if(abs(G(i,j,l)) .gt. 100) then
    G(i,j,l) = 0.0
    B(i,j,l) = 10e30
  endif
 enddo
enddo

!write(*,*) G(i,j,l), Qx(i,j), Qy(i,j), rx(i,j), r(i,j,l)

enddo

write(*,*) 'done with G'

!!!!!!!!!!!!! second relaxation

do s = 1,ns ! number of scans

sumg = 0 ! rms each scan
t    = 0 ! rms each scan

do l = 1,nl

Ox(:,:) = 0
Oy(:,:) = 0

! using two halo points. the first one is at depth 0m the last one is at depth 5000m

if (l .eq. 1) then
 dz1 = z(l+1)-z(l)
 dz2 = z(l)
else if (l .eq. nl) then
 dz1 = 5000-z(l)
 dz2 = z(l)-z(l-1)
else
 dz1 = z(l+1)-z(l)
 dz2 = z(l)-z(l-1)
endif

idz1 = 1/dz1
idz2 = 1/dz2

idz12 = 1/(dz1+dz2)

call dd2c(Ox(:,:),O(:,:,l),B(:,:,l),uscx,pscx,1)
call dd2c(Oy(:,:),O(:,:,l),B(:,:,l),vscy,pscy,2)

 do i=1,idm
  do j=1,jdm
   if (abs(B(i,j,l)) .gt. 10e10) then
     GN(i,j,l) = 0 !10e30
   else if(abs(ER(i,j,l)) .gt. eps) then
    if (l .eq. 1) then
     GN(i,j,1) = B(i,j,l) * (Ox(i,j) + Oy(i,j)) - &
               ((O(i,j,2) - O(i,j,1)) * dz2 - O(i,j,1) * dz1)*idz1*idz2*idz12
    else if (l .eq. nl) then
     GN(i,j,nl) = B(i,j,l) * (Ox(i,j) + Oy(i,j)) - &
              ((-O(i,j,nl)) * dz2 - (O(i,j,nl) - O(i,j,nl-1)) * dz1)*idz1*idz2*idz12
    else

!     if (abs(G(i,j,l+1)) .lt. 10e10 .and. abs(G(i,j,l-1)) .lt. 10e10) then
      GN(i,j,l) = B(i,j,l) * (Ox(i,j) + Oy(i,j)) - &
              ((O(i,j,l+1) - O(i,j,l)) * dz2 + (O(i,j,l-1) - O(i,j,l)) * dz1)*idz1*idz2*idz12
!     else if (abs(G(i,j,l-1)) .lt. 10e10) then  ! use halo points...
!      GN(i,j,l) = B(i,j) * (Ox(i,j) + Oy(i,j)) - &
!              (( - O(i,j,l)) * dz2 + (O(i,j,l-1) - O(i,j,l)) * dz1)*idz1*idz2*idz12
!     else if (abs(G(i,j,l+1)) .lt. 10e10) then  ! fd
!      GN(i,j,l) = B(i,j) * (Ox(i,j) + Oy(i,j)) - &
!              ((O(i,j,l+1) - O(i,j,l)) * dz2 + ( - O(i,j,l)) * dz1)*idz1*idz2*idz12
!     endif


    endif

    O(i,j,l)  = O(i,j,l) + alpha*ER(i,j,l)

   endif

!+++ diagnostic
!if (i.eq.40 .and. j.eq.164 .and. l.eq.2) then
! write(*,*) s,l, 'G',G(i,j,l), 'GN',GN(i,j,l)
! write(*,*) 'Ox(i-1,j+2)',Ox(i-1,j+2), 'Ox(i,j+2)',Ox(i,j+2),'Ox(i+1,j+2)',Ox(i+1,j+2)
! write(*,*) 'Ox(i-1,j+1)',Ox(i-1,j+1), 'Ox(i,j+1)',Ox(i,j+1),'Ox(i+1,j+1)',Ox(i+1,j+1) 
! write(*,*) 'Ox(i-1,j)  ',Ox(i-1,j),   'Ox(i,j)  ',Ox(i,j),  'Ox(i+1,j)  ',Ox(i+1,j) 
! write(*,*) 'Ox(i-1,j-1)',Ox(i-1,j-1), 'Ox(i,j-1)',Ox(i,j-1),'Ox(i+1,j+1)',Ox(i+1,j+1) 
! write(*,*) 'Ox(i-1,j-2)',Ox(i-1,j-2), 'Ox(i,j-2)',Ox(i,j-2),'Ox(i+1,j-1)',Ox(i+1,j-1) 
! write(*,*) 'B(i-1,j+2,l)',B(i-1,j+2,l), 'B(i,j+2,l)',B(i,j+2,l),  'B(i+1,j+2,l)',B(i+1,j+2,l)
! write(*,*) 'B(i-1,j+1,l)',B(i-1,j+1,l), 'B(i,j+1,l)',B(i,j+1,l),  'B(i+1,j+1,l)',B(i+1,j+1,l) 
! write(*,*) 'B(i-1,j,l)  ',B(i-1,j,l),   'B(i,j,l)  ',B(i,j,l),    'B(i+1,j,l,l)',B(i+1,j,l) 
! write(*,*) 'B(i-1,j-1,l)',B(i-1,j-1,l), 'B(i,j-1,l)',B(i,j-1,l),  'B(i+1,j+1,l)',B(i+1,j+1,l) 
! write(*,*) 'B(i-1,j-2,l)',B(i-1,j-2,l), 'B(i,j-2,l)',B(i,j-2,l),  'B(i+1,j-1,l)',B(i+1,j-1,l) 
! write(*,*) 'O(i-1,j+2,l)',O(i-1,j+2,l), 'O(i,j+2,l)',O(i,j+2,l),  'O(i+1,j+2,l)',O(i+1,j+2,l)
! write(*,*) 'O(i-1,j+1,l)',O(i-1,j+1,l), 'O(i,j+1,l)',O(i,j+1,l),'O(i+1,j+1,l)',O(i+1,j+1,l) 
! write(*,*) 'O(i-1,j,l)  ',O(i-1,j,l),   'O(i,j,l)  ',O(i,j,l),  'O(i+1,j,l)  ',O(i+1,j,l) 
! write(*,*) 'O(i-1,j-1,l)',O(i-1,j-1,l), 'O(i,j-1,l)',O(i,j-1,l),'O(i+1,j+1,l)',O(i+1,j+1,l) 
! write(*,*) 'O(i-1,j-2,l)',O(i-1,j-2,l), 'O(i,j-2,l)',O(i,j-2,l),'O(i+1,j-1,l)',O(i+1,j-1,l) 
! write(*,*) 'G(i-1,j+2,l)',G(i-1,j+2,l), 'G(i,j+2,l)',G(i,j+2,l),'G(i+1,j+2,l)',G(i+1,j+2,l)
! write(*,*) 'G(i-1,j+1,l)',G(i-1,j+1,l), 'G(i,j+1,l)',G(i,j+1,l),'G(i+1,j+1,l)',G(i+1,j+1,l) 
! write(*,*) 'G(i-1,j,l)  ',G(i-1,j,l),   'G(i,j,l)  ',G(i,j,l),  'G(i+1,j,l)  ',G(i+1,j,l) 
! write(*,*) 'G(i-1,j-1,l)',G(i-1,j-1,l), 'G(i,j-1,l)',G(i,j-1,l),'G(i+1,j+1,l)',G(i+1,j+1,l) 
! write(*,*) 'G(i-1,j-2,l)',G(i-1,j-2,l), 'G(i,j-2,l)',G(i,j-2,l),'G(i+1,j-1,l)',G(i+1,j-1,l) 
! write(*,*) 'GN(i-1,j+2,l)',GN(i-1,j+2,l), 'GN(i,j+2,l)',GN(i,j+2,l),'GN(i+1,j+2,l)',GN(i+1,j+2,l)
! write(*,*) 'GN(i-1,j+1,l)',GN(i-1,j+1,l), 'GN(i,j+1,l)',GN(i,j+1,l),'GN(i+1,j+1,l)',GN(i+1,j+1,l) 
! write(*,*) 'GN(i-1,j,l)  ',GN(i-1,j,l),   'GN(i,j,l)  ',GN(i,j,l),  'GN(i+1,j,l)  ',GN(i+1,j,l) 
! write(*,*) 'GN(i-1,j-1,l)',GN(i-1,j-1,l), 'GN(i,j-1,l)',GN(i,j-1,l),'GN(i+1,j+1,l)',GN(i+1,j+1,l) 
! write(*,*) 'GN(i-1,j-2,l)',GN(i-1,j-2,l), 'GN(i,j-2,l)',GN(i,j-2,l),'GN(i+1,j-1,l)',GN(i+1,j-1,l) 
! write(*,*) 'ER(i-1,j+2,l)',ER(i-1,j+2,l), 'ER(i,j+2,l)',ER(i,j+2,l),'ER(i+1,j+2,l)',ER(i+1,j+2,l)
! write(*,*) 'ER(i-1,j+1,l)',ER(i-1,j+1,l), 'ER(i,j+1,l)',ER(i,j+1,l),'ER(i+1,j+1,l)',ER(i+1,j+1,l) 
! write(*,*) 'ER(i-1,j,l)  ',ER(i-1,j,l),   'ER(i,j,l)  ',ER(i,j,l),  'ER(i+1,j,l)  ',ER(i+1,j,l) 
! write(*,*) 'ER(i-1,j-1,l)',ER(i-1,j-1,l), 'ER(i,j-1,l)',ER(i,j-1,l),'ER(i+1,j+1,l)',ER(i+1,j+1,l) 
! write(*,*) 'ER(i-1,j-2,l)',ER(i-1,j-2,l), 'ER(i,j-2,l)',ER(i,j-2,l),'ER(i+1,j-1,l)',ER(i+1,j-1,l) 
!endif


! if (abs(GN(i,j,l)) .lt. 10e10 .and. abs(G(i,j,l)) .lt. 10e10) then
!  if (abs((GN(i,j,l) - G(i,j,l))) .gt. 1) then
! write(*,*) s,l, 'G',G(i,j,l), 'GN',GN(i,j,l), 'Ox(i,j)',Ox(i,j), 'Oy(i,j)',Oy(i,j),'O(i,j,l)',O(i,j,l),'O(i+1,j,l)',O(i+1,j,l) &
 ! write(*,*) i,j,s,l,'G:',G(i,j,l), 'GN:',GN(i,j,l), 'Ox(i,j):'   &
  !         ,Ox(i,j), 'Oy(i,j):',Oy(i,j),'B(i,j)',B(i,j),'O(i,j,l):',O(i,j,l)
!  endif
  sumg = sumg + GN(i,j,l) - G(i,j,l)
  t = t + 1
  ER(i,j,l) = GN(i,j,l) - G(i,j,l)
! endif


  enddo
 enddo

enddo ! end layer

!write(*,*) 'scan: ',s, 't: ',t, 'sum(GN-G)/t: ',sumg/t
write(*,*) s, sumg/t

slog(s) = sumg/t

!write(*,101,advance='no') ' ', s

open (unit=100, file='omega.log', status='old', access='append')
write (100,*) sumg/t
close(100)

enddo ! end scans
write(*,*) 'done with scans'

! write to file

call wbf3d(flnmg,idm,jdm,nl,G)
call wbf3d(flnmgn,idm,jdm,nl,GN)
call wbf3d(flnmo,idm,jdm,nl,O)

end program
