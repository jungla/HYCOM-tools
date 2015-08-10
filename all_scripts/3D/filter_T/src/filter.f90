program filter 

use modfilter
use modiof
use modfunctions

implicit none 

integer,parameter       :: nl = 22 
character*8,parameter   :: flnmr = 'fort.00A',  flnmu  = 'fort.01A',  flnmv  = 'fort.02A',  flnmw  = 'fort.03A'
character*8,parameter   :: flnmrf = 'fort.30A', flnmuf  = 'fort.31A', flnmvf  = 'fort.32A', flnmwf  = 'fort.33A'
character*8,parameter   :: flnmd = 'fort.21A'
character*8             :: buffer
real*4, parameter       :: pi   = 3.1415926535897932384626433832795
real*4, parameter       :: lambdac = 40000.0

integer                 :: depthid, ids,jds,idm,jdm,i,j,l,X1,X2,Y1,Y2
real*4, allocatable     :: depth(:),  dz(:)
real*4, allocatable     :: pscx(:,:), pscy(:,:)
real*4, allocatable     :: tpscx(:,:), tpscy(:,:)
real*4, allocatable     :: u(:,:,:),  v(:,:,:),  w(:,:,:),  r(:,:,:)
real*4, allocatable     :: uf(:,:,:), vf(:,:,:), wf(:,:,:), rf(:,:,:)

call getarg(1,buffer)
read(buffer,*) X1

call getarg(2,buffer)
read(buffer,*) X2

call getarg(3,buffer)
read(buffer,*) Y1

call getarg(4,buffer)
read(buffer,*) Y2

call xcspmd(idm,jdm)  !define idm,jdm

ids = X2-X1+1
jds = Y2-Y1+1

! 3D fields
allocate (   r(ids,jds,nl))
allocate (   u(ids,jds,nl))
allocate (   v(ids,jds,nl))
allocate (   w(ids,jds,nl))
allocate (   rf(ids,jds,nl))
allocate (   uf(ids,jds,nl))
allocate (   vf(ids,jds,nl))
allocate (   wf(ids,jds,nl))

! 2D fields
allocate ( tpscx(idm,jdm))
allocate ( tpscy(idm,jdm))
allocate ( pscx(ids,jds))
allocate ( pscy(ids,jds))

! 1D fields

write(*,*) idm,jdm,nl
write(*,*) ids,jds,nl
write(*,*) 'reading archives'

do l = 1,nl
 write(*,*) l
 call rbf(flnmr,ids,jds,l,r(:,:,l))
! call smooth2(r(:,:,l),2)
 call rbf(flnmu,ids,jds,l,u(:,:,l))
 call rbf(flnmv,ids,jds,l,v(:,:,l))
 call rbf(flnmw,ids,jds,l,w(:,:,l))
enddo

r = r + 1000

call rhf(flnmd,idm,jdm,10,tpscx(:,:)) 
call rhf(flnmd,idm,jdm,11,tpscy(:,:)) 

pscx = tpscx(X1:X2,Y1:Y2)
pscy = tpscy(X1:X2,Y1:Y2)

do l = 1,nl
write(*,*) 'filter',l
 call sinxx(u(:,:,l),uf(:,:,l),pscx,pscy,ids,jds,lambdac,1)
write(*,*) u(100,100,l)
write(*,*) uf(100,100,l)
 call sinxx(v(:,:,l),vf(:,:,l),pscx,pscy,ids,jds,lambdac,1)
write(*,*) v(100,100,l)
write(*,*) vf(100,100,l)
 call sinxx(w(:,:,l),wf(:,:,l),pscx,pscy,ids,jds,lambdac,1)
write(*,*) w(100,100,l)
write(*,*) wf(100,100,l)
 call sinxx(r(:,:,l),rf(:,:,l),pscx,pscy,ids,jds,lambdac,1)
write(*,*) r(100,100,l)
write(*,*) rf(100,100,l)

enddo

call wbf3d(flnmuf,ids,jds,nl,uf)
call wbf3d(flnmvf,ids,jds,nl,vf)
call wbf3d(flnmwf,ids,jds,nl,wf)
call wbf3d(flnmrf,ids,jds,nl,rf)

end program
