program omega

use modiof
use modfd
use modrelax
use modqg
use modfunctions

implicit none 

integer,parameter       :: ni=1,nf=40                                                  ! # layers, # scans, projection factor
integer                 :: nt,ns,kl
character*8,parameter   :: flnmo = 'fort.00A', flnmg = 'fort.01A', flnmb = 'fort.02A'  ! output
character*8,parameter   :: flnmu = 'fort.03A', flnmv = 'fort.04A', flnmd = 'fort.12A'   ! u,v,density
character*8,parameter   :: flnmr = 'fort.21A', flnmm = 'fort.08A'   ! regional grid, ssh
real*4 , parameter      :: gf = 9.807

real*4, allocatable     :: aa(:),    bb(:),    cc(:),    dz(:),  dzt(:)
integer, allocatable    :: depth(:)

real*4                  :: A,          B,         C,         D,         X,         Y,        Z
real*4, allocatable     :: G(:,:,:),   Bf(:,:,:)
real*4, allocatable     :: r(:,:,:),   rt(:,:,:), O(:,:,:) 
real*4, allocatable     :: Qx(:,:),    Qy(:,:)   

integer                 :: ids,        jds,       idm,       jdm,       i,         j,             k,    s
integer                 :: X1,         X2,         Y1,        Y2
real*4                  :: r0,         dz1,       dz2,        idz1,      idz2,      idz12
real*4, allocatable     :: N2(:,:,:)
real*4, allocatable     :: uscxt(:,:), uscyt(:,:), vscxt(:,:), vscyt(:,:)
real*4, allocatable     :: pscxt(:,:), pscyt(:,:),  qscxt(:,:), qscyt(:,:)
real*4, allocatable     :: uscx(:,:),  uscy(:,:),  vscx(:,:),  vscy(:,:)  
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


write(*,*) ids, jds

! 3D fields
allocate ( rt(idm,jdm,nt))
allocate (  r(ids,jds,nt))
allocate (  O(ids,jds,nt))
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

allocate ( uscx(ids,jds))
allocate ( vscx(ids,jds))
allocate ( uscy(ids,jds))
allocate ( vscy(ids,jds))
allocate ( pscx(ids,jds))
allocate ( pscy(ids,jds))
allocate ( qscx(ids,jds))
allocate ( qscy(ids,jds))
allocate (    f(ids,jds))
allocate (   Qx(ids,jds))
allocate (   Qy(ids,jds))

allocate (   rx(ids,jds))
allocate (   ry(ids,jds))


!1D field
allocate ( aa(nt))
allocate ( bb(nt))
allocate ( cc(nt))
allocate ( depth(nt))
allocate ( dz(nt))

call rhf(flnmr,idm,jdm,10,pscxt(:,:)) 
call rhf(flnmr,idm,jdm,11,pscyt(:,:)) 
call rhf(flnmr,idm,jdm,12,qscxt(:,:)) 
call rhf(flnmr,idm,jdm,13,qscyt(:,:)) 
call rhf(flnmr,idm,jdm,14,uscxt(:,:))
call rhf(flnmr,idm,jdm,15,uscyt(:,:))
call rhf(flnmr,idm,jdm,16,vscxt(:,:))
call rhf(flnmr,idm,jdm,17,vscyt(:,:))
call rhf(flnmr,idm,jdm,18,ft(:,:))


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
 f = ft(X1:X2,Y1:Y2)
 f = sum(f)/size(f)

write(*,*) f(10,10)

write(*,*) 'read fields'

do k = ni,nf
 call rbf(flnmd,idm,jdm,k,rt(:,:,k-ni+1))
 r(:,:,k-ni+1) = rt(X1:X2,Y1:Y2,k-ni+1)
 call smooth2(r(:,:,k-ni+1),2)
enddo


r = r + 1000
! correct ref base density

write(*,*) 'compute pressure'

! 1D fields


! depths
 depth(1) = 0
 depth(2) = 2
 depth(3) = 4
 depth(4) = 6
 depth(5) = 8
 depth(6) = 10
 depth(7) = 12
 depth(8) = 14
 depth(9) = 16
 depth(10) = 18
 depth(11) = 20
 depth(12) = 22
 depth(13) = 24
 depth(14) = 26
 depth(15) = 28
 depth(16) = 30
 depth(17) = 32
 depth(18) = 34
 depth(19) = 36
 depth(20) = 38
 depth(21) = 40
 depth(22) = 42
 depth(23) = 44
 depth(24) = 46
 depth(25) = 48
 depth(26) = 50
 depth(27) = 52
 depth(28) = 54
 depth(29) = 56
 depth(30) = 58
 depth(31) = 60
 depth(32) = 62
 depth(33) = 64
 depth(34) = 66
 depth(35) = 68
 depth(36) = 70
 depth(37) = 72
 depth(38) = 74
 depth(39) = 76
 depth(40) = 78
 depth(41) = 80

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

r0 = sum(r(:,:,:))/size(r(:,:,:))

call BVfreq(N2,r,r0,depth)

write(*,*) 'done with N2'

!!!!!!!!!!!!!!! first compute forcings

do k = 1,nt
 !N2(:,:,k) = sum(N2(:,:,k))/size(N2(:,:,k))

 call ddc(ugx,ug(:,:,k),uscx,1) ! p-point
 call ddc(vgy,vg(:,:,k),vscy,2) ! p-point
 call ddc(ugy,ug(:,:,k),vscy,2) ! q-point
 call ddc(vgx,vg(:,:,k),uscx,1) ! q-point
 call ddc(rx,r(:,:,k),uscx,1) ! p-point
 call ddc(ry,r(:,:,k),vscy,2) ! p-point

 
 Qx(:,:) = (ugx * rx + vgx * ry)
 Qy(:,:) = (ugy * rx + vgy * ry)
 
 ! reuse rx,ry
 call ddc(rx,Qx,uscx,1)
 call ddc(ry,Qy,vscy,2)
 
 G(:,:,k)  = 2*gf/r0 * (rx + ry)/(f(:,:)**2)
 Bf(:,:,k) = N2(:,:,k)/(f(:,:)**2)
enddo

!Bf is defined on the p-point since N2 is computed with a centered difference
!G is defined in the p-points since it is computed from horizontal velocities on the p-points.

!do k=2,nt
! G(:,:,k) = (G(:,:,k-1)*dz(k-1) + G(:,:,k)*dz(k))/(dz(k)+dz(k-1))
!enddo

write(*,*) 'done with forcing'


!!!!!!!!!!!!! second iterative solver
! O is on the p-points.

O(:,:,:) = 0.0

do s = 1,ns !ns number of scans

! for each scan i compute the RHS with the O I have at time n
! the tridiag solver works for each poin using for each point values

call rhs(O,uscx,vscy,dz,Bf,G)  ! can compute RHS all at once


write(*,*) s

do k=1,nt
! call smooth2(O(:,:,k),1)
 write(*,*) sum(G(:,:,k)),sum(O(:,:,k)),depth(k)
enddo

! tridiag for each point
do i=1,ids-1
 do j=1,jds-1

 X = 1.0/(uscx(i,j)*uscx(i+1,j))
 Y = 1.0/(vscy(i,j)*vscy(i,j+1))
 aa = 1.0
 bb = 0.0
 cc = 1.0

 do k = 1,nt ! fills the diagonals
  if(k > 1) then
   Z = dz(k)*dz(k-1)
  else
   Z = dz(k)*dz(k)
  endif
  bb(k) = -2*Bf(i,j,k)*Z*(X+Y)-2
 enddo 

 call tridiag(nt,aa,bb,cc,O(i,j,:))

 enddo
enddo

! BCs
O(:,jds,:) = O(:,jds-1,:)
O(ids,:,:) = O(ids-1,:,:)

!write(*,*) s,O(10,10,ntt),Bft(10,10,ntt),Gt(10,10,ntt)
!write(*,*) ntt,size(O,3),size(Bft,3),size(Gt,3)

enddo ! end scans

write(*,*) 'done with scans'

call wbf3d(flnmg,ids,jds,nt,G)
call wbf3d(flnmb,ids,jds,nt,Bf)
call wbf3d(flnmo,ids,jds,nt,O)

write(*,*) 'done with writing'

end program
