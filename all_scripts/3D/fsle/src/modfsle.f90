module modfsle

contains

subroutine seed(x0,y0,z0,x1,x2,y1,y2,z1,z2,np,mp,lp)
implicit none
integer :: x1,x2,y1,y2,z1,z2,i,j,k,np,mp,lp
real*4 :: x0(:),y0(:),z0(:)
real*4 :: dx,dy,dz
integer :: p


k = 0

dx = (x2-x1)/np/5.0
dy = (y2-y1)/mp/5.0
dz = (z2-z1)/lp/5.0

! write(*,*) 'dx,dy',dx,dy,x2,x1,np

do k=1,lp
 do i=1,np
  do j=1,mp*3,3
   do p=0,2
   if (p == 0) then
    x0((i-1)*mp*3 + j + p) = (i-1)*(x2-x1)/np
    y0((i-1)*mp*3 + j + p) = (j/3)*(y2-y1)/mp
   else if (p == 1) then
    x0((i-1)*mp*3 + j + p) = (i-1)*(x2-x1)/np 
    y0((i-1)*mp*3 + j + p) = (j/3)*(y2-y1)/mp + dy
   else
    x0((i-1)*mp*3 + j + p) = (i-1)*(x2-x1)/np + dx
    y0((i-1)*mp*3 + j + p) = (j/3)*(y2-y1)/mp
   endif
    z0((i-1)*mp*3 + j + p) = (k-1)*(z2-z1)/lp
   enddo
  enddo
 enddo
enddo

! id = (i-1)*mp*lp + (j-1)*lp + k
! write(*,*) x0

return 
end subroutine seed

subroutine seed_zx(x0,y0,z0,x1,x2,y1,y2,z1,z2,np,mp,lp)
implicit none
integer :: x1,x2,y1,y2,z1,z2,i,j,k,np,mp,lp
real*4 :: x0(:),y0(:),z0(:)
real*4 :: dx,dy,dz
integer :: p


k = 0

dx = (x2-x1)/np/5.0
dy = (y2-y1)/mp/5.0
dz = (z2-z1)/lp/5.0

write(*,*) 'dx,dy',dx,dy,x2,x1,np

do k=1,lp
 do i=1,np
  do j=1,mp*3,3
   do p=0,2
   if (p == 0) then
    x0((i-1)*mp*3 + j + p) = (i-1)*(x2-x1)/np
    y0((i-1)*mp*3 + j + p) = (j/3)*(y2-y1)/mp
   else if (p == 1) then
    x0((i-1)*mp*3 + j + p) = (i-1)*(x2-x1)/np
    y0((i-1)*mp*3 + j + p) = (j/3)*(y2-y1)/mp + dy
   else
    x0((i-1)*mp*3 + j + p) = (i-1)*(x2-x1)/np + dx
    y0((i-1)*mp*3 + j + p) = (j/3)*(y2-y1)/mp
   endif
    z0((i-1)*mp*3 + j + p) = (k-1)*(z2-z1)/lp
   enddo
  enddo
 enddo
enddo

! id = (i-1)*mp*lp + (j-1)*lp + k
! write(*,*) x0

return
end subroutine seed_zx



!*******************************************************************
subroutine euler2(n,m,x0,y0,u1,v1,u2,v2,it,iti,dt,dx,dy)
implicit none
!
integer n,m,it,iti,i,j
real*4 :: x0,y0,x0i,y0i,dt
real*4 u1(n,m),u2(n,m),v1(n,m),v2(n,m),dx(n,m),dy(n,m)
real*4 uhor(n,m),vhor(n,m)
real*4 x,psu,xout,xt
real*4 y,psv,yout,yt
real*4 :: at1,at2

! weight for the linear time interpolation
  at1=float(it-1)/float(iti)
  at2=float(iti-(it-1))/float(iti)
!  print*,'at1,at2  :',at1,at2

!  do j=1,m
!  do i=1,n
  do j=floor(y0)-4,floor(y0)+4
  do i=floor(x0)-4,floor(x0)+4
    uhor(i,j)=(u1(i,j)*at2+u2(i,j)*at1)/dx(i,j)
    vhor(i,j)=(v1(i,j)*at2+v2(i,j)*at1)/dy(i,j)
!    print*,'i,j,uhor(i,j)=',i,j,uhor(i,j)
  enddo
  enddo
!  write (21) uhor

call interp(x0,y0,uhor,psu,2)
call interp(x0,y0,vhor,psv,3)
! print*,'y0,floor(y0)=',y0,floor(y0)

!x1=x0+ u1 dt
x0=x0+dt*psu
y0=y0+dt*psv
! print*,'x0,y0= ',x0,y0
! print*,'psu,psv=',psu,psv

return
end subroutine euler2

subroutine euler3(n,m,lz,x0,y0,z0,u1,v1,w1,u2,v2,w2,it,iti,dt,dx,dy,dz)

implicit none
!
integer :: n,m,lz,x0i,y0i,it,iti,i,j,k
real*4 :: x0,y0,z0,u1(n,m,lz),u2(n,m,lz),w1(n,m,lz),v1(n,m,lz),v2(n,m,lz),w2(n,m,lz),dx(n),dy(m),dz,dt
real*4 :: uhor(n,m,lz),vhor(n,m,lz),whor(n,m,lz)
real*4 :: psu,psv,psw,at1,at2
integer :: kl

! weight for the linear time interpolation
at1=float(it-1)/float(iti)
at2=float(iti-(it-1))/float(iti)
! print*,'at1,at2  :',at1,at2

if (z0.ge.2.) then ! modified 5/16/12

 if (int(z0).le.4) then
  kl=int(z0)-1
 else
  kl=4
 endif

!    print*, kl

 do k=int(z0)-kl,int(z0)+4
  do j=int(y0)-4,int(y0)+4
   do i=int(x0)-4,int(x0)+4
!    print*, 'k,j,i=',k,j,i
!    print*, 'u', u1(i,j,k),u2(i,j,k),dx(i)
    uhor(i,j,k)=(u1(i,j,k)*at2+u2(i,j,k)*at1)/dx(i)
!    print*, 'uhor=', uhor(i,j,k)
!    print*, 'v', v1(i,j,k),v2(i,j,k),dy(j)
    vhor(i,j,k)=(v1(i,j,k)*at2+v2(i,j,k)*at1)/dy(j)
!    print*, 'vhor=', vhor(i,j,k)
!    print*, 'w=', w1(i,j,k),w2(i,j,k)
    whor(i,j,k)=(w1(i,j,k)*at2+w2(i,j,k)*at1)/dz
!    print*, 'whor',whor(i,j,k)
   enddo
  enddo
 enddo

!    write (21) uhor
!    print*, i,j,k

 call interp3(x0,y0,z0,uhor,psu,0)
 call interp3(x0,y0,z0,vhor,psv,0)
 call interp3(x0,y0,z0,whor,psw,0) ! u,v,w are all defined at the center & bottom of the grid 

!print*,'y0,int(y0)=',y0,int(y0)

else

do j=int(y0)-4,int(y0)+4
do i=int(x0)-4,int(x0)+4

uhor(i,j,1)=(u1(i,j,1)*at2+u2(i,j,1)*at1)/dx(j)
vhor(i,j,1)=(v1(i,j,1)*at2+v2(i,j,1)*at1)/dy(j)

enddo
enddo

do k=2,6! modified 5/16/12
uhor(i,j,k)=uhor(i,j,1)  ! modified 5/16/12
vhor(i,j,k)=vhor(i,j,1)  ! modified 5/16/12
enddo   ! modified 5/16/12

z0=1.0
call interp3(x0,y0,z0,uhor,psu,0)
call interp3(x0,y0,z0,vhor,psv,0)
psw=0.0

endif

!x1=x0+ u1 dt
x0=x0+dt*psu
y0=y0+dt*psv
z0=z0+dt*psw
!print*,'x0,y0= ',x0,y0
!print*,'psu,psv=',psu,psv

return
end subroutine

subroutine zerotheland(u,v,w)
implicit none

integer :: i,j,k,n,m,lz
real*4 :: u(:,:,:),v(:,:,:),w(:,:,:)

n = size(u,1)
m = size(u,2)
lz = size(u,3)

do i=1,n
 do j=1,m
  do k=1,lz
   if (u(i,j,k).gt.4.) then  !we are on land
    u(i,j,k)=0.
    v(i,j,k)=0.
    w(i,j,k)=0.
   endif
  enddo !k
 enddo !j
enddo !i
return
end subroutine

subroutine distance3(m,xm1,ym1,zm1,xm2,ym2,zm2,dist2,dx,dy,dz)
implicit none

real*4 :: dx(:),dy(:),dz
real*4 :: base1,base2,z2,deltaym,xt,yt,xm1,ym1,xm2,ym2,dist2
real*4 :: zm1,zm2 
integer :: m,j1,j2,i1,i2,jt,j

j1=int(ym1)
j2=int(ym2)

if (j2.lt.j1) then
 xt=xm2
 xm2=xm1
 xm1=xt
 yt=ym2
 ym2=ym1
 ym1=yt
endif

i1=int(xm1)
i2=int(xm2)
j1=int(ym1)
j2=int(ym2)
base1=(xm2-xm1)*dx(j1)
base2=(xm2-xm1)*dx(j2)

if (i1.eq.i2.and.j1.eq.j2) then
 dist2 = (dx(j1)*(xm2-xm1))**2 + (dy(j1)*(ym2-ym1))**2 + (dz*(zm2-zm1))**2
else if (j1.eq.j2) then
 dist2 = base1**2+(dy(j1)*(ym2-ym1))**2 + (dz*(zm2-zm1))**2
else
 deltaym=0.
 if (j1+1.lt.j2) then
  do j=j1+1,j2-1
   deltaym = deltaym + dy(j)
  enddo !j
 endif
 deltaym = deltaym + (j1+1-ym1)*dy(j1) + (ym2-j2)*dy(j2)
  dist2 = deltaym**2 + base1*base2 + (dz*(zm2-zm1))**2
endif

return
end subroutine

subroutine interp3(xp,yp,zp,u,uu,nu)

implicit none


integer,parameter :: ll=4
integer :: in,im,il,nu
real*4 :: nx,ny,nz,nfx,nfy,nfz,xp,yp,zp,uu,u(:,:,:)
real*4 :: ddx,ddy,ddz,x1(ll),y1(ll),z1(ll),ub(ll,ll,ll)
real*4 :: d1,d2,d3,err

!
!     first: find surrounding u,v points
!
nx = int(xp)
ny = int(yp)
nz = int(zp)
d1 = xp - real(nx)
d2 = yp - real(ny)
d3 = zp - real(nz)

! nu=0 for central
if (nu.eq.0) then
  nfx = nx
  nfy = ny
  nfz = nz
  ddx = d1
  ddy = d2
  ddz = d3
endif

! nu=2 for u
if (nu.eq.2) then
  if (d1.le.0.5) then
     nfx = nx
     ddx = d1 + 0.5
  else
     nfx = nx + 1
     ddx = d1 - 0.5
  endif
  nfy = ny
  ddy = d2
  nfz = nz
  ddz = d3
endif

! nu=3 for v
if (nu.eq.3) then
  if (d2.le.0.5) then
    nfy = ny
    ddy = d2 + 0.5
  else
    nfy = ny + 1
    ddy = d2 - 0.5
  endif
  nfx = nx
  ddx = d1
  nfz = nz
  ddz = d3
endif

! nu=4 for w
if (nu.eq.4) then
  if (d3.le.0.5) then
    nfz = nz
    ddz = d3 + 0.5
  else
    nfz = nz + 1
    ddz = d3 - 0.5
  endif
  nfx = nx
  ddx = d1
  nfy = ny
  ddy = d2
endif

if (nu.lt.5) then

 if (nfz.le.1) then
     nfz=2
 endif
 do in=1,ll
  x1(in) = nfx+(in-ll/2)
  y1(in) = nfy+(in-ll/2)
  z1(in) = nfz+(in-ll/2)
  do im=1,ll
    do il=1,ll
ub(in,im,il) = u(int(nfx+(in-ll/2)),int(nfy+(im-ll/2)),int(nfz+(il-ll/2)))
    enddo
  enddo
 enddo
endif
! polynomial interpolation (from numerical recipes)

  call polin3(x1,y1,z1,ub,ll,ll,ll,nfx+ddx,nfy+ddy,nfz+ddz,uu,err)

return
end subroutine

!***************************************************************************

subroutine polin3(x1a,x2a,x3a,ya,l,m,n,x,y,z,u,dy)
implicit none

integer :: n,m,l,i,j,k
integer,parameter :: nmax=20,mmax=20,lmax=20
real*4 :: x1a(l),x2a(m),x3a(n),ya(l,m,n),yntmp(nmax),ymtmp(mmax),yltmp(lmax),u
real*4 :: dy,y,z,x

do i=1,l
  do j=1,m
    do k=1,n
     yntmp(k)=ya(i,j,k)
    enddo
    call polint(x3a,yntmp,n,z,ymtmp(j),dy)
  enddo
 call polint(x2a,ymtmp,m,y,yltmp(i),dy)
enddo
call polint(x1a,yltmp,l,x,u,dy)
return
end subroutine



!*********************************************************************
subroutine rk4(n,m,x0,y0,u1,v1,u2,v2,it,iti,dt,dx,dy)
implicit none
!
integer :: n,m,it,iti,i,j
real*4 :: x0,y0,dt,u1(n,m),u2(n,m),v1(n,m),v2(n,m),dx(n,m),dy(n,m)
real*4 :: uhor1(n,m),vhor1(n,m),uhor2(n,m),vhor2(n,m)
real*4 :: uhor(n,m),vhor(n,m), uhop(n,m),vhop(n,m)
real*4 :: uhoi(n,m),vhoi(n,m)
real*4 :: x,psu,xout,xt,dxt,dxm,dxt1,dxt2,dyt1,dyt2
real*4 :: y,psv,yout,yt,dyt,dym,dxm1,dxm2,dym1,dym2
real*4 :: at1,at2,at3,at4,at5,at6,m2deg,pi,rayt,h2,h6
logical :: vert_oui

  h2=dt/2.
  h6=dt/6.

! *******
! compute the weight for the linear time interpolation
! *******
  at1=float(it-1)/float(iti)
  at2=float(iti-(it-1))/float(iti)
! *******
! time+dt
! *******
  at3=at1+1./float(iti)
  at4=at2-1./float(iti)
! *******
! time+dt/2
! *******
  at5=at1+0.5/float(iti)
  at6=at2-0.5/float(iti)

!  write(*,*) 'time coef=', at1,at2,at3,at4,at5,at6

!  do j=1,m
!  do i=1,n
  do j=floor(y0)-4,floor(y0)+4
  do i=floor(x0)-4,floor(x0)+4
    uhor(i,j)=(u1(i,j)*at2+u2(i,j)*at1)/dx(i,j)
    vhor(i,j)=(v1(i,j)*at2+v2(i,j)*at1)/dy(i,j)
    uhop(i,j)=(u1(i,j)*at4+u2(i,j)*at3)/dx(i,j)
    vhop(i,j)=(v1(i,j)*at4+v2(i,j)*at3)/dy(i,j)
    uhoi(i,j)=(u1(i,j)*at6+u2(i,j)*at5)/dx(i,j)
    vhoi(i,j)=(v1(i,j)*at6+v2(i,j)*at5)/dy(i,j)
  enddo
  enddo
!
! interpolation horizontale
! -------------------------
! u1=u(x0,t0)
call interp(x0,y0,uhor,psu,2)
call interp(x0,y0,vhor,psv,3)

! x1=x0+0.5 u1 dt
xt=x0+h2*psu
yt=y0+h2*psv

! u2=u(x1,t0+dt/2)
call interp(xt,yt,uhoi,dxt,2)
call interp(xt,yt,vhoi,dyt,3)

! x2=x0+0.5 u2 dt
xt=x0+h2*dxt
yt=y0+h2*dyt

! u3=u(x2,t0+dt/2)
call interp(xt,yt,uhoi,dxm,2)
call interp(xt,yt,vhoi,dym,3)

! x3=x0+ u3 dt
xt=x0+dxm*dt
yt=y0+dym*dt
dxm=dxt+dxm
dym=dyt+dym

! u4=u(x3,t1)
call interp(xt,yt,uhop,dxt,2)
call interp(xt,yt,vhop,dyt,3)

!x4=x0+ (u1+2u2+2u3+u4) dt
x0=x0+(psu+2.*dxm+dxt)*h6
y0=y0+(psv+2.*dym+dyt)*h6
! print*,'x0,y0=',x0,y0
! print*,'psv,dym,dyt=',psv,dym,dyt
return
end subroutine


! ===========================================================================
subroutine interp(xp,yp,u,uu,nu)
implicit none
!
!
integer,parameter :: ll=4 ! number of points around each point

real*4 :: xp,yp,uu,u(:,:)
real*4 :: x1(ll),y1(ll),ub(ll,ll)
real*4 :: err,ddx,ddy,d1,d2
integer :: nfx,nfy,in,im,nx,ny,at1,at2,i,j,nu

!
!     first: find surrounding u,v points
!
nx = floor(xp)
ny = floor(yp)
d1 = xp - nx
d2 = yp - ny

! nu=0 for central
if (nu.eq.0) then
  nfx = nx
  nfy = ny
  ddx = d1
  ddy = d2
endif


! nu=2 for u
if (nu.eq.2) then
  if (d1.le.0.5) then
     nfx = nx
     ddx = d1 + 0.5
  else
     nfx = nx + 1
     ddx = d1 - 0.5
  endif
  nfy = ny
  ddy = d2
endif
! nu=3 for v
if (nu.eq.3) then
  if (d2.le.0.5) then
    nfy = ny
    ddy = d2 + 0.5
  else
    nfy = ny + 1
    ddy = d2 - 0.5
  endif
  nfx = nx
  ddx = d1
endif

if (nu.lt.4) then
 do in=1,ll
  x1(in) = (nfx+(in-ll/2))
  y1(in) = (nfy+(in-ll/2))
  do im=1,ll
    ub(in,im) = u((nfx+(in-ll/2)),(nfy+(im-ll/2)))
  enddo
 enddo
endif

! polynomial interpolation (from numerical recipes)
  call polin2(x1,y1,ub,ll,ll,nfx+ddx,nfy+ddy,uu,err)

return
end subroutine

!
subroutine polin2(x1a,x2a,ya,m,n,x1,x2,y,dy)

implicit none
integer,parameter :: nmax=20,mmax=20
integer :: n,m,i,j,k
real*4 :: y,dy,x1,x2,x1a(m),x2a(n),ya(m,n),yntmp(nmax),ymtmp(mmax)

do j=1,m
  do k=1,n
    yntmp(k)=ya(j,k)
  enddo
  call polint(x2a,yntmp,n,x2,ymtmp(j),dy)
enddo
call polint(x1a,ymtmp,m,x1,y,dy)
return
end subroutine
! ________________________________________________________________________
! ________________________________________________________________________
!
subroutine polint(xa,ya,n,x,y,dy)

implicit none
integer,parameter :: nmax=10
integer :: n,m,i,j,ns
real*4 :: xa(n),ya(n),c(nmax),d(nmax),x,y,dy,w
real*4 :: den,dif,ho,hp
real*4 :: dift

ns=1
dif=abs(x-xa(1))
do i=1,n
  dift=abs(x-xa(i))
  if (dift.lt.dif) then
    ns=i
    dif=dift
  endif
  c(i)=ya(i)
  d(i)=ya(i)
enddo
y=ya(ns)
ns=ns-1
do m=1,n-1
  do i=1,n-m
    ho=xa(i)-x
    hp=xa(i+m)-x
    w=c(i+1)-d(i)
    den=ho-hp
    den=w/den
    d(i)=hp*den
    c(i)=ho*den
enddo
  if (2*ns.lt.n-m)then
    dy=c(ns+1)
  else
    dy=d(ns)
    ns=ns-1
  endif
  y=y+dy
enddo
return
end subroutine

! ___________________________________________________________________________
subroutine distance(m,xm1,ym1,xm2,ym2,dist2,dx,dy)

implicit none

real*4 dx(m),dy(m),xm1,ym1,xm2,ym2,dist2
real*4 base1,base2,z2,deltaym,xt,yt !,xm1,ym1,xm2,ym2,dist
integer :: i,j,m,j1,j2,i1,i2,jt

j1=floor(ym1)
j2=floor(ym2)
if (j2.lt.j1) then
 xt=xm2
 xm2=xm1
 xm1=xt
 yt=ym2
 ym2=ym1
 ym1=yt
endif
i1=floor(xm1)
i2=floor(xm2)
j1=floor(ym1)
j2=floor(ym2)
base1=(xm2-xm1)*dx(j1)
base2=(xm2-xm1)*dx(j2)


if (i1.eq.i2.and.j1.eq.j2) then
 dist2 = (dx(j1)*(xm2-xm1))**2 + (dy(j1)*(ym2-ym1))**2
else if (j1.eq.j2) then
 dist2 = base1**2+(dy(j1)*(ym2-ym1))**2
else
 deltaym=0.
 if (j1+1.lt.j2) then
  do j=j1+1,j2-1
   deltaym = deltaym + dy(j)
  enddo !j
 endif
 deltaym = deltaym + (j1+1-ym1)*dy(j1) + (ym2-j2)*dy(j2)
  dist2 = deltaym**2+base1*base2
endif

return
end subroutine distance

end module modfsle
