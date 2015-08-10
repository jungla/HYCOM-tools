program filter

use modfilter
use modiof
use modfunctions

implicit none 

integer                 :: nl
character*8,parameter   :: flnmr = 'fort.00A',  flnmu  = 'fort.01A',  flnmv  = 'fort.02A' 
character*8,parameter   :: flnmw  = 'fort.03A', flnmt  = 'fort.04A',  flnms  = 'fort.05A'
character*8,parameter   :: flnmrf = 'fort.30A', flnmuf  = 'fort.31A', flnmvf  = 'fort.32A' 
character*8,parameter   :: flnmwf  = 'fort.33A', flnmsf  = 'fort.34A', flnmtf  = 'fort.35A'
character*8,parameter   :: flnmd = 'fort.21A'
character*8             :: buffer
real*4, parameter       :: pi   = 3.1415926535897932384626433832795
real*4                  :: lambdac

integer                 :: depthid, ids,jds,idm,jdm,i,j,l,X1,X2,Y1,Y2
real*4, allocatable     :: depth(:),  dz(:)
real*4, allocatable     :: pscx(:,:), pscy(:,:)
real*4, allocatable     :: tpscx(:,:), tpscy(:,:)
real*4, allocatable     :: u(:,:),  v(:,:),  w(:,:),  r(:,:) ,  s(:,:),  t(:,:)
real*4, allocatable     :: uf(:,:), vf(:,:), wf(:,:), rf(:,:), sf(:,:), tf(:,:)

call getarg(1,buffer)
read(buffer,*) X1

call getarg(2,buffer)
read(buffer,*) X2

call getarg(3,buffer)
read(buffer,*) Y1

call getarg(4,buffer)
read(buffer,*) Y2

call getarg(5,buffer)
read(buffer,*) nl

call getarg(6,buffer)
read(buffer,*) lambdac

lambdac = lambdac*1000 ! in Km

call xcspmd(idm,jdm)  !define idm,jdm

ids = X2-X1+1
jds = Y2-Y1+1

! 3D fields
allocate (   s(ids,jds))
allocate (   t(ids,jds))
allocate (   r(ids,jds))
allocate (   u(ids,jds))
allocate (   v(ids,jds))
allocate (   w(ids,jds))
allocate (   sf(ids,jds))
allocate (   tf(ids,jds))
allocate (   rf(ids,jds))
allocate (   uf(ids,jds))
allocate (   vf(ids,jds))
allocate (   wf(ids,jds))

! 2D fields
allocate ( tpscx(idm,jdm))
allocate ( tpscy(idm,jdm))
allocate ( pscx(ids,jds))
allocate ( pscy(ids,jds))

! 1D fields

write(*,*) idm,jdm,nl
write(*,*) ids,jds,nl
write(*,*) 'reading archives'

call rbf(flnmr,ids,jds,nl,r(:,:))
call rbf(flnms,ids,jds,nl,s(:,:))
call rbf(flnmt,ids,jds,nl,t(:,:))
! call smooth2(r(:,:,l),2)
call rbf(flnmu,ids,jds,nl,u(:,:))
call rbf(flnmv,ids,jds,nl,v(:,:))
call rbf(flnmw,ids,jds,nl,w(:,:))

r = r + 1000

call rhf(flnmd,idm,jdm,10,tpscx(:,:)) 
call rhf(flnmd,idm,jdm,11,tpscy(:,:)) 

pscx = tpscx(X1:X2,Y1:Y2)
pscy = tpscy(X1:X2,Y1:Y2)

write(*,*) 'filter',nl
 call sinxx(u(:,:),uf(:,:),pscx,pscy,ids,jds,lambdac,1)
write(*,*) u(100,100)
write(*,*) uf(100,100)
 call sinxx(v(:,:),vf(:,:),pscx,pscy,ids,jds,lambdac,1)
write(*,*) v(100,100)
write(*,*) vf(100,100)
 call sinxx(w(:,:),wf(:,:),pscx,pscy,ids,jds,lambdac,1)
write(*,*) w(100,100)
write(*,*) wf(100,100)
 call sinxx(r(:,:),rf(:,:),pscx,pscy,ids,jds,lambdac,1)
write(*,*) r(100,100)
write(*,*) rf(100,100)
 call sinxx(s(:,:),sf(:,:),pscx,pscy,ids,jds,lambdac,1)
write(*,*) r(100,100)
write(*,*) rf(100,100)
 call sinxx(t(:,:),tf(:,:),pscx,pscy,ids,jds,lambdac,1)
write(*,*) r(100,100)
write(*,*) rf(100,100)

call wbf(flnmuf,ids,jds,1,uf)
call wbf(flnmvf,ids,jds,1,vf)
call wbf(flnmwf,ids,jds,1,wf)
call wbf(flnmrf,ids,jds,1,rf)
call wbf(flnmsf,ids,jds,1,sf)
call wbf(flnmtf,ids,jds,1,tf)

end program
