program gwind

use modfunctions
use modiof
use modkinem

implicit none 

integer,parameter       :: nl = 23
character*8,parameter   :: flnmo = 'fort.00A', flnmu  = 'fort.01A', flnmv  = 'fort.02A' 
character*8,parameter   :: flnmoa = 'fort.30A', flnmob  = 'fort.31A', flnmoc  = 'fort.32A', flnmon  = 'fort.33A'
character*8,parameter   :: flnmd = 'fort.12A'
character*8,parameter   :: flnmr = 'fort.21A'
character*8,parameter   :: flnmh = 'fort.99A'
real*4 , parameter      :: omg  = 7.2921150e-5, gf = 9.807
real*4 , parameter      :: pi   = 3.1415926535897932384626433832795

integer                 :: idm,       jdm,       i,         j,         k
real*4                  :: depth(nl), dz(nl)
real*4, allocatable     :: E(:,:,:),  A(:,:,:),  B(:,:,:),  C(:,:,:),  u(:,:,:),  v(:,:,:),  p(:,:,:),  nu(:,:,:), ssh(:,:)
real*4, allocatable     :: Ax(:,:),   Ay(:,:),   Cx(:,:),   Cy(:,:)
real*4, allocatable     :: r(:,:,:)
real*4, allocatable     :: plon(:,:), plat(:,:), uscx(:,:), uscy(:,:), vscx(:,:), vscy(:,:)
real*4, allocatable     :: pscx(:,:), pscy(:,:)
real*4, allocatable     :: f(:,:)

call xcspmd(idm,jdm)  !define idm,jdm

! 3D fields
allocate (  A(idm,jdm,nl))
allocate (  B(idm,jdm,nl))
allocate (  C(idm,jdm,nl))
allocate (  E(idm,jdm,nl))
allocate (  u(idm,jdm,nl))
allocate (  v(idm,jdm,nl))
allocate (  r(idm,jdm,nl))
allocate (  p(idm,jdm,nl))
allocate (  nu(idm,jdm,nl))

! 2D fields
allocate (  pscx(idm,jdm))
allocate (  pscy(idm,jdm))
allocate (  plat(idm,jdm))
allocate (  plon(idm,jdm))
allocate (  uscx(idm,jdm))
allocate (  uscy(idm,jdm))
allocate (  vscx(idm,jdm))
allocate (  vscy(idm,jdm))
allocate (  ssh(idm,jdm))

allocate (     f(idm,jdm))
allocate (    Ax(idm,jdm))
allocate (    Ay(idm,jdm))
allocate (    Cx(idm,jdm))
allocate (    Cy(idm,jdm))

call rhf(flnmr,idm,jdm,1, plon(:,:)) 
call rhf(flnmr,idm,jdm,2, plat(:,:))
call rhf(flnmr,idm,jdm,10,pscx(:,:)) 
call rhf(flnmr,idm,jdm,11,pscy(:,:)) 
call rhf(flnmr,idm,jdm,14,uscx(:,:)) 
call rhf(flnmr,idm,jdm,15,uscy(:,:)) 
call rhf(flnmr,idm,jdm,16,vscx(:,:)) 
call rhf(flnmr,idm,jdm,17,vscy(:,:)) 

call rhf(flnmh,idm,jdm,2,  ssh(:,:)) 

do k = 1,nl
 call rbf(flnmd,idm,jdm,k,r(:,:,k))
 call smooth2(r(:,:,k),2)
 call rbf(flnmu,idm,jdm,k,u(:,:,k))
 call rbf(flnmv,idm,jdm,k,v(:,:,k))
enddo

r = r + 1000

write(*,*) 'read fields'

! depths
 depth(1) = 0
 depth(2) = 5
 depth(3) = 10
 depth(4) = 20
 depth(5) = 30
 depth(6) = 40
 depth(7) = 50
 depth(8) = 60
 depth(9) = 70
 depth(10) = 80
 depth(11) = 90
 depth(12) = 100
 depth(13) = 200
 depth(14) = 300
 depth(15) = 400
 depth(16) = 500
 depth(17) = 700
 depth(18) = 1000
 depth(19) = 1500
 depth(20) = 2000
 depth(21) = 2500
 depth(22) = 3000

! build dz

do k=1,nl-1
 dz(k+1) = depth(k+1) - depth(k)
enddo

dz(1) = depth(1)
dz(nl) = dz(nl-1)

! A: curvature
! B: vorticity
! C: pressure

! initialize the fields
 A   = 10e30
 Ax  = 10e30
 Ay  = 10e30
 B   = 10e30
 C   = 10e30
 Cx  = 10e30
 Cy  = 10e30
 nu  = 10e30

! f
 do i = 1,idm
  do j = 1,jdm
  f(i,j) = 2*omg*sin(plat(i,j)*pi/90)
  enddo
 enddo

! build pressure field, from hydrostatic balance

p(:,:,1) = 0

do i=1,idm
 do j=1,jdm
  p(i,j,1) = ssh(i,j)*gf*r(i,j,1)/100
!  p(i,j,k) = dz(k)*gf*(r(i,j,k)) + p(i,j,k-1)
 enddo
enddo

write(*,*) 'ssh in cm: ', ssh(500,500)

do i=1,idm
 do j=1,jdm
  do k=2,nl
  p(i,j,k) = dz(k)*gf*(r(i,j,k)+r(i,j,k-1))*0.5 + p(i,j,k-1)
!  p(i,j,k) = dz(k)*gf*(r(i,j,k)) + p(i,j,k-1)
  enddo
 enddo
enddo

write(*,*) 'depth', depth(:)

! compute A - curvature
! A = ddx(u*ddx(u)) + ddy(v*ddy(v))

do k = 1,nl
 call ddc(Ax,u(:,:,k),uscx,1)
 call ddc(Ay,v(:,:,k),vscy,2)

 Ax = u(:,:,k) * Ax
 Ay = v(:,:,k) * Ay

 call ddc(Ax,Ax,uscx,1)
 call ddc(Ay,Ay,vscy,2)

 A(:,:,k) = Ax+Ay
enddo

write(*,*) 'A - Curvature', A(500,500,3)

! compute B - vorticity

pscx = 1/pscx
pscy = 1/pscy

do k = 1,nl
 call vor(B(:,:,k),pscx,pscy,idm,jdm,u(:,:,k),v(:,:,k))


 B(:,:,k)  = f(:,:) * B(:,:,k)
 nu(:,:,k) = &
 sqrt(sum(B(:,:,k)**2,mask = abs(B(:,:,k)).lt.10e10)/count(abs(B(:,:,k)).lt.10e10))

write(*,*) 'nu', k, nu(500,500,k)
enddo

write(*,*) 'B - Vorticity', B(500,500,3)

! compute C - pressure gradienl
! 1/r * (ddx(ddx p) + ddy(ddy p))

do k = 1,nl
 call ddc(Cx,p(:,:,k),uscx,1)
 call ddc(Cx,Cx,uscx,1)
 call ddc(Cy,p(:,:,k),vscy,2)
 call ddc(Cy,Cy,vscy,2)

 C(:,:,k)  = Cy + Cx

 nu(:,:,k) = nu(:,:,k) + &
 sqrt(sum(C(:,:,k)**2,mask = abs(C(:,:,k)).lt.10e10)/count(abs(C(:,:,k)).lt.10e10))/r(:,:,k)

 write(*,*) 'nu', k, nu(500,500,k)

 C(:,:,k) = C(:,:,k) / r(:,:,k)
enddo

write(*,*) 'C - Pressure gradient', C(500,500,3)

!do i=1,idm
!do j=1,jdm
!do k=1,nl
!if(r(i,j,k) .gt. 10e10) then
!A(i,j,k)  = 10e30
!B(i,j,k)  = 10e30
!C(i,j,k)  = 10e30
!nu(i,j,k) = 10e30
!endif
!enddo
!enddo
!enddo

do k = 1,nl


!nu = sqrt(sum(B(:,:,k)**2,mask = abs(B(:,:,k)).lt.10e10)/count(abs(B(:,:,k)).lt.10e10)) &
!   + sqrt(sum(C(:,:,k)**2,mask = abs(C(:,:,k)).lt.10e10)/count(abs(C(:,:,k)).lt.10e10))


E(:,:,k) = abs(-A(:,:,k)+B(:,:,k)-C(:,:,k))/(nu(:,:,k) + abs(A(:,:,k))+abs(B(:,:,k))+abs(C(:,:,k)))

 do i=1,idm
  do j=1,jdm
   if(r(i,j,k) .gt. 10e10) then
    E(i,j,k) = 10e30
!   else
!    E(i,j,k) = abs(-A(i,j,k)+B(i,j,k)-C(i,j,k))/(nu(i,j,k) + abs(A(i,j,k))+abs(B(i,j,k))+abs(C(i,j,k)))
   endif
  enddo
 enddo

enddo

! write to file

call wbf3d(flnmo,idm,jdm,nl,E)
call wbf3d(flnmoa,idm,jdm,nl,A)
call wbf3d(flnmob,idm,jdm,nl,B)
call wbf3d(flnmoc,idm,jdm,nl,C)
call wbf3d(flnmon,idm,jdm,nl,nu)

end program
