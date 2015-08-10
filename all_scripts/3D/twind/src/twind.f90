program omega

use modiof
use modkinem

implicit none 

integer,parameter       :: nt=21                                                        ! # layers, # scans, projection factor
integer                 :: kl                                                           ! # layers, # scans, projection factor
character*8,parameter   :: flnmo = 'fort.00A', flnmu  = 'fort.01A', flnmv  = 'fort.02A'    ! output
character*8,parameter   :: flnmd = 'fort.12A', flnmug = 'fort.03A', flnmvg = 'fort.04A'    ! density
character*8,parameter   :: flnmr = 'fort.21A', flnmh  = 'fort.09A', flnmm  = 'fort.08A'   ! regional grid, ssh
real*4 , parameter      :: omg  = 7.2921150e-5, gf = 9.907
real*4 , parameter      :: pi   = 3.1415926535897932384626433832795

integer                 :: idm,       jdm,       i,         j,         k, t, s, im, jm, ni, nf
real*4                  :: depth(nt), dz(nt)
real*4                  :: A,         B,         C,         D,         X,         Y,        Z
real*4, allocatable     :: O(:,:,:),  u(:,:,:),  v(:,:,:)
real*4, allocatable     :: r(:,:,:)
real*4, allocatable     :: plon(:,:), plat(:,:), uscx(:,:), uscy(:,:), vscx(:,:), vscy(:,:)
real*4, allocatable     :: pscx(:,:), pscy(:,:)
real*4, allocatable     :: rx(:,:),   ry(:,:),   ux(:,:),   vy(:,:),   ug(:,:),   vg(:,:)
real*4, allocatable     :: f(:,:),    assh(:,:), ssh(:,:),  mssh(:,:)

call xcspmd(idm,jdm)  !define idm,jdm

! 3D fields
allocate (  O(idm,jdm,nt))
allocate (  u(idm,jdm,nt))
allocate (  v(idm,jdm,nt))
allocate (  r(idm,jdm,nt))

! 2D fields
allocate (     f(idm,jdm))
allocate (   ssh(idm,jdm))
allocate (  mssh(idm,jdm))
allocate (  assh(idm,jdm))
allocate (  pscx(idm,jdm))
allocate (  pscy(idm,jdm))
allocate (  plat(idm,jdm))
allocate (  plon(idm,jdm))
allocate (  uscx(idm,jdm))
allocate (  uscy(idm,jdm))
allocate (  vscx(idm,jdm))
allocate (  vscy(idm,jdm))

allocate (  ug(idm,jdm))
allocate (  vg(idm,jdm))
allocate (  ux(idm,jdm))
allocate (  vy(idm,jdm))
allocate (  rx(idm,jdm))
allocate (  ry(idm,jdm))

! 1D fields

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

do k = 1,nt
 call rbf(flnmd,idm,jdm,k,r(:,:,k))
enddo

r = r + 1000

! depths
 depth(1) = 0
 depth(2) = 10
 depth(3) = 20
 depth(4) = 30
 depth(5) = 40
 depth(6) = 50
 depth(7) = 60
 depth(8) = 70
 depth(9) = 80
 depth(10) = 90
 depth(11) = 100
 depth(12) = 200
 depth(13) = 300
 depth(14) = 400
 depth(15) = 500
 depth(16) = 700
 depth(17) = 1000
 depth(18) = 1500
 depth(19) = 2000
 depth(20) = 2500
 depth(21) = 3000

! build dz

do k=1,nt-1
 dz(k+1) = depth(k+1) - depth(k)
enddo

dz(1) = depth(1)
dz(nt) = dz(nt-1)

!!! compute f, GeoVel

!!! It is assumed that the interpolation in z-coord respects the position of the the quantities

!!! Geo Velocities

! initialize the fields
 u   = 10e30
 v   = 10e30
 ug  = 10e30
 vg  = 10e30
 ux  = 10e30
 vy  = 10e30
 O   = 10e30

assh(:,:) = ssh(:,:)/10 - mssh(:,:)/10

write(*,*) maxval(assh)
write(*,*) minval(assh)
write(*,*) maxval(mssh)
write(*,*) minval(mssh)
write(*,*) maxval(ssh,ssh.lt.10e10)
write(*,*) minval(ssh,ssh.lt.10e10)


101 format(A, I2)

! sanitaze r and assh

 do i = 1,idm
  do j = 1,jdm
  f(i,j) = 2*omg*sin(plat(i,j)*pi/90)
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

 ug(:,:) = -gf/f(:,:) * ug(:,:)
 vg(:,:) =  gf/f(:,:) * vg(:,:)

! from p to p

write(*,*) 'done with Ug and grad(Ug)'

!!!!!!!!!!!!!!! first compute forcings

u(:,:,1) = ug
v(:,:,1) = vg

do k = 2,nt
rx = 10e30
ry = 10e30

call ddc(rx,r(:,:,k),uscx,1)
call ddc(ry,r(:,:,k),vscy,2)

do i=1,idm
 do j=1,jdm
  if (u(i,j,k-1).lt.10e10 .and. v(i,j,k-1).lt.10e10 .and. rx(i,j) .lt. 10e10 .and. ry(i,j).lt.10e10 .and. &
             r(i,j,k) .lt. 100 .and. r(i,j,k-1) .lt. 100) then
   u(i,j,k) = u(i,j,k-1)-gf*(r(i,j,k)-r(i,j,k-1))/((r(i,j,k)*0.5+r(i,j,k-1)*0.5)* & 
                r(i,j,k)*f(i,j)) * ry(i,j) * dz(k)
   v(i,j,k) = v(i,j,k-1)+gf*(r(i,j,k)-r(i,j,k-1))/((r(i,j,k)*0.5+r(i,j,k-1)*0.5)* &
                r(i,j,k)*f(i,j)) * rx(i,j) * dz(k)
   if(u(i,j,k).gt.10e10) then
    write(*,*) u(i,j,k)
   endif

  endif
 enddo
enddo

! compute vertical velocities from divergence of thermal wind velocities

call ddc(ux,u(:,:,k),uscx,1)
call ddc(vy,v(:,:,k),vscy,2)

O(:,:,k) = ux(:,:) + vy(:,:)

! print diagnostics
!write(*,*) O(200,200,k)

enddo ! end loop in vertical

! write to file

call wbf3d(flnmo,idm,jdm,nt,O)
call wbf3d(flnmu,idm,jdm,nt,u)
call wbf3d(flnmv,idm,jdm,nt,v)
call wbf3d(flnmug,idm,jdm,1,ug)
call wbf3d(flnmvg,idm,jdm,1,vg)

end program
