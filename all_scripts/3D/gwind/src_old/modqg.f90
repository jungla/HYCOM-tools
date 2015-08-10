module modqg

contains

subroutine GeoVel(ug,vg,pscx,pscy,mssh,ssh,f)

 implicit none

! flnmi is the archive containing the ssh
! mssh is the mean ssh computed as average over the entire period 

 integer*4            :: i,j,idm,jdm
 integer*4, parameter :: g = 9.807
 real*4              :: f(:,:),    pscx(:,:), pscy(:,:)
 real*4              :: ug(:,:),   vg(:,:)
 real*4              :: ssh(:,:),  mssh(:,:)
 real*4, allocatable :: assh(:,:)

 idm = size(ssh,1)
 jdm = size(ssh,2)

 allocate ( assh(idm,jdm))

 assh(:,:) = ssh(:,:) - mssh(:,:)

 do i=2,idm-1
  do j=2,jdm-1
  ug(i,j) = -g/f(i,j) * (assh(i+1,j)-assh(i-1,j))/(pscy(i+1,j)+pscy(i-1,j))/10
  vg(i,j) =  g/f(i,j) * (assh(i,j+1)-assh(i,j-1))/(pscx(i,j+1)+pscx(i,j-1))/10
  enddo
 enddo

! BCs

 do j=1,jdm
  ug(1,j)   = -g/f(1,j)   * (assh(2,j)-assh(1,j))/pscy(1,j)/10
  ug(idm,j) = -g/f(idm,j) * (assh(idm,j)-assh(idm-1,j))/pscy(idm,j)/10
 enddo

 do i=1,idm
  vg(i,1)   =  g/f(i,1)   * (assh(i,2)-assh(i,1))/pscx(i,1)/10
  vg(i,jdm) =  g/f(i,jdm) * (assh(i,jdm)-assh(i,jdm-1))/pscx(i,jdm)/10
 enddo

! clean from NaN
 
 do i=1,idm
  do j=1,jdm
   if (ssh(i,j) .gt. 10e10) then
!   write(*,*) ug(i,j), vg(i,j)
    ug(i,j) = 10e10
    vg(i,j) = 10e10
   endif
  enddo
 enddo

end subroutine GeoVel


subroutine BVfreq(N2,r,z)
! return a matrix for N^2 at each point in the horizontal and for the depth specified in z

 implicit none

 real*4              :: r(:,:,:),N2(:,:,:)
 real*4              :: rt,zt,dz
 integer             :: i,j,l,idm,jdm,nl,z(:)

 nl = size(z)
 idm = size(r,1)
 jdm = size(r,2)

! 1 - compute brunt-vaisala freq

! 1   brunt-vaisala freq

do  i=1,idm
 do  j=1,jdm

  do l=2,nl-1
   if(r(i,j,l-1) .lt. 10e10) then
    if(abs(r(i,j,l+1)) .lt. 10e10) then
     dz = z(l+1)-z(l-1)
     N2(i,j,l) = 9.806/r(i,j,l)*(r(i,j,l+1) - r(i,j,l-1))/dz
    else
     N2(i,j,l) = 9.806/r(i,j,l)*(r(i,j,l) - r(i,j,l-1))/(z(l)-z(l-1))
    endif
   endif
  enddo

 if(r(i,j,1) .lt. 10e10) then
  N2(i,j,1) = 9.806/r(i,j,1)*(r(i,j,2) - r(i,j,1))/(z(2))
 endif
 
 if(r(i,j,nl) .lt. 10e10) then
  N2(i,j,nl) = 9.806/r(i,j,nl)*(r(i,j,nl) - r(i,j,nl-1))/(z(nl)-z(nl-1))
 endif

 enddo
enddo

end subroutine BVfreq

end module modqg
