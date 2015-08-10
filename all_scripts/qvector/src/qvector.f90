program qvector

use modfunctions
use modiof
use modkinem
use modts2sigma ! HYCOM array I/O interface


implicit none 

integer,parameter       :: nl = 30 
character*8,parameter   :: flnm  = 'fort.10A'
character*8,parameter   :: flnmr = 'fort.21A', flnmx = 'fort.31A', flnmy = 'fort.32A'                               
real*4 , parameter      :: pi   = 3.1415926535897932384626433832795

integer                 :: idm,       jdm,       i,         j,         l
real*4, allocatable     :: r(:,:,:),  Qx(:,:,:), Qy(:,:,:)
real*4, allocatable     :: plon(:,:), plat(:,:), pscx(:,:), pscy(:,:), ubar(:,:), vbar(:,:), t(:,:), s(:,:)
real*4, allocatable     :: u(:,:,:),  v(:,:,:)
real*4, allocatable     :: ux(:,:),   vy(:,:),   uy(:,:),   vx(:,:),   rx(:,:),   ry(:,:)

call xcspmd(idm,jdm)  !define idm,jdm

! 3D fields
allocate (  Qx(idm,jdm,nl))
allocate (  Qy(idm,jdm,nl))
allocate (   r(idm,jdm,nl))
allocate (   u(idm,jdm,nl))
allocate (   v(idm,jdm,nl))

! 2D fields
allocate ( pscx(idm,jdm))
allocate ( pscy(idm,jdm))
allocate ( plat(idm,jdm))
allocate ( plon(idm,jdm))
allocate ( ubar(idm,jdm))
allocate ( vbar(idm,jdm))
allocate (    t(idm,jdm))
allocate (    s(idm,jdm))

allocate (  ux(idm,jdm))
allocate (  uy(idm,jdm))
allocate (  vx(idm,jdm))
allocate (  vy(idm,jdm))
allocate (  rx(idm,jdm))
allocate (  ry(idm,jdm))

write(*,*) idm,jdm,nl
write(*,*) 'reading archives'

! add barotropic velocities

 call rhf(flnm,idm,jdm,10,ubar)
 call rhf(flnm,idm,jdm,11,vbar)

do l = 1,nl

   call rhf(flnm,idm,jdm,10+l*5,t)
   call rhf(flnm,idm,jdm,11+l*5,s)

   do i=1,idm
    do j=1,jdm
    call sigma0(r(i,j,l),t(i,j),s(i,j))
    enddo
   enddo

 call smooth2(r(:,:,l),2)

 call rhf(flnm,idm,jdm,7+l*5,u(:,:,l))
 call rhf(flnm,idm,jdm,8+l*5,v(:,:,l))

 u(:,:,l) = u(:,:,l) + ubar
 v(:,:,l) = v(:,:,l) + vbar
 
enddo

r = r + 1000

call rhf(flnmr,idm,jdm,12,pscx(:,:)) 
call rhf(flnmr,idm,jdm,13,pscy(:,:)) 

write(*,*) 'done'
write(*,*) 'Computing Qx and Qy'

do l = 1,nl

write(*,*) l

 call dd(ux,u(:,:,l),pscx,1)
 call dd(vy,v(:,:,l),pscy,2)
 call dd(uy,u(:,:,l),pscy,2)
 call dd(vx,v(:,:,l),pscx,1)
 call dd(rx,r(:,:,l),pscx,1)
 call dd(ry,r(:,:,l),pscy,2)

 Qx(:,:,l) = -(ux * rx + vx * ry)
 Qy(:,:,l) = -(uy * rx + vy * ry)

do i=1,idm
 do j=1,jdm
   if (r(i,j,l).gt.10e10) then 
    Qx(i,j,l) = 10e30
    Qy(i,j,l) = 10e30
   endif
 enddo
enddo

write(*,*) Qx(100,100,l), Qy(100,100,l)

enddo ! end layer

call wbf3d(flnmx,idm,jdm,nl,Qx)
call wbf3d(flnmy,idm,jdm,nl,Qy)

end program
