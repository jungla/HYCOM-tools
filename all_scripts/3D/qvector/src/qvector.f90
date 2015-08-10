program qvector

use modfunctions
use modiof
use modfd

implicit none 

integer,parameter       :: nl = 41 !nl = 23
character*8,parameter   :: flnmu = 'fort.10A', flnmv = 'fort.11A', flnmd = 'fort.12A'   ! u,v,density
character*8,parameter   :: flnmw = 'fort.13A'   
character*8,parameter   :: flnmr = 'fort.21A', flnmx = 'fort.31A', flnmy = 'fort.32A'                               
character*8,parameter   :: flnmf = 'fort.33A'                               
real*4 , parameter      :: pi   = 3.1415926535897932384626433832795

integer                 :: idm,       jdm,       i,         j,         l
real*4, allocatable     :: depth(:),  dz(:)
real*4, allocatable     :: r(:,:,:),  Qw(:,:,:), Qx(:,:,:), Qy(:,:,:), F(:,:,:)
real*4, allocatable     :: plon(:,:), plat(:,:), pscx(:,:), pscy(:,:), qscx(:,:), qscy(:,:)
real*4, allocatable     :: u(:,:,:),  v(:,:,:),  w(:,:,:)
real*4, allocatable     :: ux(:,:),   vy(:,:),   uy(:,:),   vx(:,:),   rx(:,:),   ry(:,:), rz(:,:), wx(:,:), wy(:,:)

call xcspmd(idm,jdm)  !define idm,jdm

! 3D fields
allocate (  Qw(idm,jdm,nl))
allocate (  Qx(idm,jdm,nl))
allocate (  Qy(idm,jdm,nl))
allocate (   F(idm,jdm,nl))
allocate (   r(idm,jdm,nl))
allocate (   u(idm,jdm,nl))
allocate (   v(idm,jdm,nl))
allocate (   w(idm,jdm,nl))

! 2D fields
allocate ( pscx(idm,jdm))
allocate ( pscy(idm,jdm))
allocate ( qscx(idm,jdm))
allocate ( qscy(idm,jdm))
allocate ( plat(idm,jdm))
allocate ( plon(idm,jdm))

allocate (  ux(idm,jdm))
allocate (  uy(idm,jdm))
allocate (  vx(idm,jdm))
allocate (  vy(idm,jdm))
allocate (  wx(idm,jdm))
allocate (  wy(idm,jdm))
allocate (  rx(idm,jdm))
allocate (  ry(idm,jdm))
allocate (  rz(idm,jdm))

! 1D fields
allocate (  depth(nl))
allocate (     dz(nl))

! depths
! depth(1) = 0
! depth(2) = 5
! depth(3) = 10
! depth(4) = 20
! depth(5) = 30
! depth(6) = 40
! depth(7) = 50
! depth(8) = 60
! depth(9) = 70
! depth(10) = 80
! depth(11) = 90
! depth(12) = 100
! depth(13) = 200
! depth(14) = 300
! depth(15) = 400
! depth(16) = 500
! depth(17) = 700
! depth(18) = 1000
! depth(19) = 1500
! depth(20) = 2000
! depth(21) = 2500
! depth(22) = 3000

 depth(1) =   0.00        
 depth(2) =   1.00        
 depth(3) =   2.00        
 depth(4) =   3.00        
 depth(5) =   4.00        
 depth(6) =   5.00        
 depth(7) =   6.00        
 depth(8) =   7.00        
 depth(9) =   8.00        
 depth(10) =   9.00        
 depth(11) =  10.00        
 depth(12) =  20.00        
 depth(13) =  30.00        
 depth(14) =  40.00        
 depth(15) =  50.00        
 depth(16) =  60.00        
 depth(17) =  70.00        
 depth(18) =  80.00        
 depth(19) =  90.00        
 depth(20) = 100.00        
 depth(21) = 200.00        
 depth(22) = 300.00        
 depth(23) = 400.00        
 depth(24) = 500.00        
 depth(25) = 700.00        
 depth(26) =1000.00        
 depth(27) =1500.00        
 depth(28) =2000.00        
 depth(29) =2500.00        
 depth(30) =3000.00        
 depth(31) =4000.00

write(*,*) idm,jdm,nl
write(*,*) 'reading archives'

do l = 1,nl
 call rbf(flnmd,idm,jdm,l,r(:,:,l))
 call smooth2(r(:,:,l),2)
 call rbf(flnmu,idm,jdm,l,u(:,:,l))
 call rbf(flnmv,idm,jdm,l,v(:,:,l))
 call rbf(flnmw,idm,jdm,l,w(:,:,l))
enddo

r = r + 1000

call rhf(flnmr,idm,jdm,10,pscx(:,:)) 
call rhf(flnmr,idm,jdm,11,pscy(:,:)) 
call rhf(flnmr,idm,jdm,12,qscx(:,:)) 
call rhf(flnmr,idm,jdm,13,qscy(:,:)) 

! build dz

do l=1,nl-1
 dz(l+1) = depth(l+1) - depth(l)
enddo

dz(1) = depth(1)
dz(nl) = dz(nl-1)

write(*,*) 'done'

write(*,*) 'Compute Qx and Qy and Qw'

! I want for each value in x and y a value of rho_z.

do l = 1,nl

! in the p-points
! correct pscx!

 call ddc(wx,w(:,:,l),pscx,1)! p-point 
 call ddc(wy,w(:,:,l),pscy,2)! p-point
 call dd(ux,u(:,:,l),pscx,1) ! p-point
 call dd(vy,v(:,:,l),pscy,2) ! p-point
 call dd(uy,u(:,:,l),qscy,2) ! q-point
 call q2p(uy)                ! p-point
 call dd(vx,v(:,:,l),qscx,1) ! q-point
 call q2p(vx)                ! p-point
 call ddc(rx,r(:,:,l),pscx,1)! p-point
 call ddc(ry,r(:,:,l),pscy,2)! p-point

write(*,*) l
! rho_z.  
if (l .lt. nl) then
 do i=1,idm
  do j=1,jdm
  rz(i,j) = (r(i,j,l+1)-r(i,j,l))/dz(l+1)
  enddo
 enddo
else
 do i=1,idm
  do j=1,jdm
  rz(i,j) = (r(i,j,l)-r(i,j,l-1))/dz(l)
  enddo
 enddo
endif 

Qx(:,:,l) = -(ux * rx + vx * ry + wx * rz)
Qy(:,:,l) = -(uy * rx + vy * ry + wy * rz)

F(:,:,l) = Qx(:,:,l) * rx + Qy(:,:,l) * ry

do i=1,idm
 do j=1,jdm
   if (r(i,j,l).gt.10e10 .or. r(i+1,j,l).gt.10e10 .or. r(i,j+1,l).gt.10e10) then 
    Qx(i,j,l) = 10e30
    Qy(i,j,l) = 10e30
     F(i,j,l) = 10e30
   endif
 enddo
enddo

enddo ! end layer

call wbf3d(flnmx,idm,jdm,nl,Qx)
call wbf3d(flnmy,idm,jdm,nl,Qy)
call wbf3d(flnmf,idm,jdm,nl,F)

end program
