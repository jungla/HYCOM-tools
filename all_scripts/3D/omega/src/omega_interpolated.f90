program omega

use modiof
use modfd
use modrelax
use modqg
use modfunctions

implicit none 

integer,parameter       :: n=1,ni=30,nf=32                                                   ! # layers, # scans, projection factor
integer                 :: nt,ntt,ns,kl
character*8,parameter   :: flnmo = 'fort.00A', flnmg = 'fort.01A', flnmb = 'fort.02A'  ! output
character*8,parameter   :: flnmu = 'fort.03A', flnmv = 'fort.04A', flnmd = 'fort.12A'   ! u,v,density
character*8,parameter   :: flnmr = 'fort.21A', flnmm = 'fort.08A'   ! regional grid, ssh
real*4 , parameter      :: omg  = 7.2921150*10e-5, gf = 9.907
real*4 , parameter      :: pi   = 2*asin(1.0)

real*4, allocatable     :: aa(:),    bb(:),    cc(:),    dz(:),  dzt(:)
integer, allocatable    :: depth(:)

real*4                  :: A,          B,         C,         D,         X,         Y,        Z
real*4, allocatable     :: G(:,:,:),   Gt(:,:,:), Bf(:,:,:), Bft(:,:,:)
real*4, allocatable     :: r(:,:,:),   rt(:,:,:), O(:,:,:) 
real*4, allocatable     :: Qx(:,:),    Qy(:,:)   

integer                 :: ids,        jds,       idm,       jdm,       i,         j,             k,    s
integer                 :: X1,         X2,         Y1,        Y2
real*4                  :: r0,         dz1,       dz2,        idz1,      idz2,      idz12
real*4, allocatable     :: N2(:,:,:)
real*4, allocatable     :: plont(:,:), platt(:,:),  uscxt(:,:), uscyt(:,:), vscxt(:,:), vscyt(:,:)
real*4, allocatable     :: pscxt(:,:), pscyt(:,:),  qscxt(:,:), qscyt(:,:)
real*4, allocatable     :: plon(:,:),  plat(:,:),   uscx(:,:),  uscy(:,:),  vscx(:,:),  vscy(:,:)  
real*4, allocatable     :: pscx(:,:),  pscy(:,:),   qscx(:,:),  qscy(:,:)
real*4, allocatable     :: ug(:,:,:),  vg(:,:,:),   f(:,:),     ft(:,:)
real*4, allocatable     :: ugx(:,:),   ugy(:,:),    vgx(:,:),   vgy(:,:),   rx(:,:),    ry(:,:)
real*4, allocatable     :: temp(:,:) 

character*8 :: buffer
character*1 :: flag

CALL GETARG(1,BUFFER)
READ(BUFFER,*) flag
CALL GETARG(2,BUFFER)
READ(BUFFER,*) ns
CALL GETARG(3,BUFFER)
READ(BUFFER,*) X1
CALL GETARG(4,BUFFER)
READ(BUFFER,*) X2
CALL GETARG(5,BUFFER)
READ(BUFFER,*) Y1
CALL GETARG(6,BUFFER)
READ(BUFFER,*) Y2

write(*,*) 'flag:',flag
write(*,*) 'ns:',ns
write(*,*) 'X1',X1
write(*,*) 'X2',X2
write(*,*) 'Y1',Y1
write(*,*) 'Y2',Y2


call xcspmd(idm,jdm)  !define idm,jdm

ids = X2-X1+1
jds = Y2-Y1+1

nt = nf-ni+1

ntt = nt*n+1

write(*,*) ids, jds

! 3D fields
allocate ( rt(idm,jdm,nt))
allocate (  r(ids,jds,nt))
allocate (  O(ids,jds,ntt))
allocate (Bft(ids,jds,ntt))
allocate ( Gt(ids,jds,ntt))
allocate ( Bf(ids,jds,nt))
allocate (  G(ids,jds,nt))
allocate ( ug(ids,jds,nt))
allocate ( vg(ids,jds,nt))
allocate ( N2(ids,jds,nt))

! 2D fields
allocate ( temp(idm,jdm))
allocate ( ugx(ids,jds))
allocate ( ugy(ids,jds))
allocate ( vgx(ids,jds))
allocate ( vgy(ids,jds))
allocate (    ft(idm,jdm))
allocate ( uscxt(idm,jdm))
allocate ( vscxt(idm,jdm))
allocate ( uscyt(idm,jdm))
allocate ( vscyt(idm,jdm))
allocate ( pscxt(idm,jdm))
allocate ( pscyt(idm,jdm))
allocate ( qscxt(idm,jdm))
allocate ( qscyt(idm,jdm))
allocate ( platt(idm,jdm))
allocate ( plont(idm,jdm))

allocate ( uscx(ids,jds))
allocate ( vscx(ids,jds))
allocate ( uscy(ids,jds))
allocate ( vscy(ids,jds))
allocate ( pscx(ids,jds))
allocate ( pscy(ids,jds))
allocate ( qscx(ids,jds))
allocate ( qscy(ids,jds))
allocate ( plat(ids,jds))
allocate ( plon(ids,jds))
allocate (    f(ids,jds))
allocate (   Qx(ids,jds))
allocate (   Qy(ids,jds))

allocate (   rx(ids,jds))
allocate (   ry(ids,jds))


!1D field
allocate ( aa(ntt))
allocate ( bb(ntt))
allocate ( cc(ntt))
allocate ( depth(nt))
allocate ( dz(nt))
allocate (dzt(ntt))

call rhf(flnmr,idm,jdm,1, plont(:,:)) 
call rhf(flnmr,idm,jdm,2, platt(:,:)) 
call rhf(flnmr,idm,jdm,10,pscxt(:,:)) 
call rhf(flnmr,idm,jdm,11,pscyt(:,:)) 
call rhf(flnmr,idm,jdm,12,qscxt(:,:)) 
call rhf(flnmr,idm,jdm,13,qscyt(:,:)) 
call rhf(flnmr,idm,jdm,14,uscxt(:,:))
call rhf(flnmr,idm,jdm,15,uscyt(:,:))
call rhf(flnmr,idm,jdm,16,vscxt(:,:))
call rhf(flnmr,idm,jdm,17,vscyt(:,:))
call rhf(flnmr,idm,jdm,18,ft(:,:))


plat = platt(X1:X2,Y1:Y2)
plon = plont(X1:X2,Y1:Y2)
pscx = pscyt(X1:X2,Y1:Y2)
pscy = pscxt(X1:X2,Y1:Y2)
qscx = qscyt(X1:X2,Y1:Y2)
qscy = qscxt(X1:X2,Y1:Y2)
uscx = uscxt(X1:X2,Y1:Y2)
uscy = uscyt(X1:X2,Y1:Y2)
vscx = vscxt(X1:X2,Y1:Y2)
vscy = vscyt(X1:X2,Y1:Y2)


 !write(*,*) sum(ft)/size(ft)
 !write(*,*) f(1,:) 
 !f = ft(X1:X2,Y1:Y2)
 f = sum(ft)/size(ft)

write(*,*) 'read fields'

do k = ni,nf
 call rbf(flnmd,idm,jdm,k,rt(:,:,k-ni+1))
 r(:,:,k-ni+1) = rt(X1:X2,Y1:Y2,k-ni+1)
 call smooth2(r(:,:,k-ni+1),2)
enddo

write(*,*) 'compute pressure'

! 1D fields

r = r + 1000

! depths

! depth(1) = 55
! depth(2) = 56
! depth(3) = 57
! depth(1) = 58
 depth(1) = 59
 depth(2) = 60
 depth(3) = 61
! depth(5) = 62
! depth(9) = 63
! depth(10) = 64
! depth(11) = 65

! depth(12) = 200
! depth(13) = 300
! depth(14) = 400
! depth(15) = 500
! depth(16) = 700
! depth(17) = 1000
! depth(18) = 1500
! depth(19) = 2000
! depth(20) = 2500
! depth(21) = 3000
! depth(22) = 4000

! build dz

do k=1,nt-1
 dz(k) = depth(k+1) - depth(k)
enddo

dz(nt) = dz(nt-1)

!!! compute f, GeoVel and BVfreq
! NOTICE cannot compute GeoVel without the depth from the surface.

if(flag == 'g') then
! call GeoVel(ug,vg,uscx,vscy,r,f,dz)
! write(*,*) 'Geostrophic Velocities'
else
 do k = ni,nf
  call rbf(flnmu,idm,jdm,k,temp)
  ug(:,:,k-ni+1) = temp(X1:X2,Y1:Y2)
  call rbf(flnmv,idm,jdm,k,temp)
  vg(:,:,k-ni+1) = temp(X1:X2,Y1:Y2)
 enddo
 write(*,*) 'Full Velocities'
endif

call BVfreq(N2,r,depth)

write(*,*) 'done with N2'

!!!!!!!!!!!!!!! first compute forcings

do k = 1,nt

 call ddc(ugx,ug(:,:,k),uscx,1) ! p-point
 call ddc(vgy,vg(:,:,k),vscy,2) ! p-point
 call ddc(ugy,ug(:,:,k),vscy,2) ! q-point
 call ddc(vgx,vg(:,:,k),uscx,1) ! q-point
 call ddc(rx,r(:,:,k),uscx,1) ! p-point
 call ddc(ry,r(:,:,k),vscy,2) ! p-point

 r0 = sum(r(:,:,k))/size(r(:,:,k))
 
 Qx(:,:) = 2*gf/r0 * (ugx * rx + vgx * ry)
 Qy(:,:) = 2*gf/r0 * (ugy * rx + vgy * ry)
 
 ! reuse rx,ry
 call ddc(rx,Qx,uscx,1)
 call ddc(ry,Qy,vscy,2)
 
 G(:,:,k) = (rx + ry)/(f(:,:)**2)
 Bf(:,:,k) = N2(:,:,k)/(f(:,:)**2)
 
enddo


!G is defined between two z points, while B and O are defined in the z points (p-points)
!interpolata of G in p-points with halo points. size(G,3) = nt

do k=2,nt
 G(:,:,k) = (G(:,:,k-1)*dz(k-1) + G(:,:,k)*dz(k))/(dz(k)+dz(k-1))
enddo

write(*,*) 'done with forcing'

!!! reinterpolate to half the depth for stability

write(*,*) 'interpolation'
write(*,*) 'ntt: ',ntt

Bft(:,:,ntt) = Bf(:,:,nt)
Gt(:,:,ntt)  = G(:,:,nt)
dzt(ntt)     = dz(nt)

do k = 1,nt
 Bft(:,:,(k-1)*n+1) = Bf(:,:,k)
 Gt(:,:,(k-1)*n+1) = G(:,:,k)
 dzt((k-1)*n+1) = dz(k)
 write(*,*) 'first: ',k,nt,(k-1)*n+1
enddo

!Bft=0.0

do k = 1,nt-1
 do i = 1,n-1
 Bft(:,:,(k-1)*n+i+1) = (Bf(:,:,k)*(n-i) + Bf(:,:,k+1)*i)/n
  Gt(:,:,(k-1)*n+i+1) =  (G(:,:,k)*(n-i) +  G(:,:,k+1)*i)/n
     dzt((k-1)*n+i+1) =     (dz(k)*(n-i) +     dz(k+1)*i)/n
 enddo
 write(*,*) 'second: ',k,k/n+1,(k+1)
enddo

!!! not the best option... another loop for the last values

do i = 1,n-1
 Bft(:,:,(nt-1)*n+i+1) = (Bf(:,:,nt-1)*(n-i) + Bf(:,:,nt)*i)/n
  Gt(:,:,(nt-1)*n+i+1) =  (G(:,:,nt-1)*(n-i) +  G(:,:,nt)*i)/n
     dzt((nt-1)*n+i+1) =     (dz(nt-1)*(n-i) +     dz(nt)*i)/n
enddo

write(*,*) 'second: ',k,k/n+1,(k+1)
  

write(*,*) Bft(10,10,:),Bf(10,10,:)

do k = 1,ntt
 call smooth2(Bft(:,:,k),2)
 call smooth2(Gt(:,:,k),2)
enddo

dzt = dzt/n
write(*,*) dzt,dz
write(*,*) 'done with interpolation'


!!!!!!!!!!!!! second iterative solver

O(:,:,:) = 0.0

do s = 1,ns !ns number of scans

! for each scan i compute the RHS with the O I have at time n
! the tridiag solver works for each poin using for each point values

call rhs(O,uscx,vscy,dzt,Bft,Gt)  ! can compute RHS all at once

write(*,*) O(10,10,1)
write(*,*) s, sum(O), O(10,10,(ntt-1)/2+1)

do k=1,ntt
 call smooth2(O(:,:,k),1)
enddo

! tridiag for each point
do i=1,ids-1
 do j=1,jds-1

 X = 1.0/(uscx(i,j)*uscx(i+1,j))
 Y = 1.0/(vscy(i,j)*vscy(i,j+1))
 aa = 0.0
 bb = 0.0
 cc = 0.0

 do k = 1,ntt ! fills the diagonals
  if(k > 1) then
   Z = dzt(k)*dzt(k-1)
  else
   Z = dzt(k)*dzt(k)
  endif
  aa(k) = -1 
  bb(k) = -2*Bft(i,j,k)*Z*(X+Y)+2
  cc(k) = -1
 enddo 

 call tridiag(ntt,aa,bb,cc,O(i,j,:),Bft(i,j,:))

 enddo
enddo

! BCs
O(:,jds,:) = O(:,jds-1,:)
O(ids,:,:) = O(ids-1,:,:)

!write(*,*) s,O(10,10,ntt),Bft(10,10,ntt),Gt(10,10,ntt)
!write(*,*) ntt,size(O,3),size(Bft,3),size(Gt,3)

enddo ! end scans

write(*,*) 'done with scans'

call wbf3d(flnmg,ids,jds,ntt,Gt)
call wbf3d(flnmb,ids,jds,ntt,Bft)
call wbf3d(flnmo,ids,jds,ntt,O)

write(*,*) 'done with writing'

end program
