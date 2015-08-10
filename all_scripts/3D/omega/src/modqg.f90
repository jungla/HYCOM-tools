module modqg
use modfd

contains

subroutine GeoVel(ug,vg,uscx,vscy,r,f,dz)

 implicit none

! flnmi is the archive containing the ssh
! mssh is the mean ssh computed as average over the entire period 

 integer             :: i,j,k,idm,jdm,nl
 real*4              :: r(:,:,:),  f(:,:), uscx(:,:), vscy(:,:)
 real*4              :: ug(:,:,:),   vg(:,:,:), dz(:)
 real*4,allocatable  :: p(:,:,:)
 real*4,allocatable  :: py(:,:),   px(:,:)
 real*4,parameter    :: gf = 9.907

 nl  = size(dz,1)
 idm = size(r,1)
 jdm = size(r,2)

allocate( px(idm,jdm))
allocate( py(idm,jdm))
allocate(  p(idm,jdm,nl))

! pressure field

p(:,:,1) = 0
ug(:,:,1) = 0
vg(:,:,1) = 0

do k = 1,nl
px = 0.0
py = 0.0

! build pressure field form hydrostatic equation

  do i = 1,idm
   do j = 1,jdm
   p(i,j,k) = dz(k)*gf*r(i,j,k) + p(i,j,k-1)
   enddo
  enddo

 ! u = -1/fr * dp/dy
 ! v =  1/fr * dp/dx

 call ddc(px,p(:,:,k),uscx,1)
 call ddc(py,p(:,:,k),vscy,2)

 do i=1,idm
  do j=1,jdm
  ug(i,j,k) = -1/(f(i,j)*r(i,j,k)) * py(i,j)
  vg(i,j,k) =  1/(f(i,j)*r(i,j,k)) * px(i,j)
  enddo
 enddo


enddo

end subroutine GeoVel


subroutine BVfreq(N2,r,r0,z)
! return a matrix for N^2 at each point in the horizontal and for the depth specified in z

 implicit none

 real*4              :: r(:,:,:),N2(:,:,:)
 real*4              :: rt,zt,dz,r0
 integer             :: i,j,l,idm,jdm,nl,z(:)

 nl = size(z,1)
 idm = size(r,1)
 jdm = size(r,2)

do  i=1,idm
 do  j=1,jdm

 do l=1,nl-1
  if(r(i,j,l+1) .lt. 10**8) then
   dz = z(l+1)-z(l)
   N2(i,j,l) = 9.807/r0 * (r(i,j,l+1) - r(i,j,l))/dz
  else
   N2(i,j,l) = 9.807/r0 * (r(i,j,l) - r(i,j,l-1))/(z(l)-z(l-1))
  endif
 enddo


 N2(i,j,nl) = 9.807/r0 * (r(i,j,nl) - r(i,j,nl-1))/(z(nl)-z(nl-1))

 enddo
enddo

end subroutine BVfreq

end module modqg
