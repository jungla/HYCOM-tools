module modfd

contains

! ++++++++++++++++++++++++++
! +     1D derivatives     +
! ++++++++++++++++++++++++++

subroutine ddc(ua,u,psca,id)
! centered difference

integer             :: i,id,idm,jdm
real*4              :: ua(:,:), u(:,:), psca(:,:)

idm = size(u,1)
jdm = size(u,2)

if (id == 1) then ! x-dir

 do i = 2,idm-1
  ua(i,:) = (u(i+1,:)-u(i-1,:))/(psca(i+1,:)+psca(i,:))
 enddo

! BCs
 ua(1,:)   = (u(2,:)-u(1,:))/psca(1,:)
 ua(idm,:) = (u(idm,:)-u(idm-1,:))/psca(idm,:)

else              ! y-dir

 do j = 2,jdm-1
  ua(:,j) = (u(:,j+1)-u(:,j-1))/(psca(:,j+1)+psca(:,j))
 enddo

! BCs
 ua(:,1)   = (u(:,2)-u(:,1))/psca(:,1)
 ua(:,jdm) = (u(:,jdm)-u(:,jdm-1))/psca(:,jdm)

endif

end subroutine ddc

subroutine dd(ua,u,psca,id)
! centered difference

integer             :: i,j,id,idm,jdm
real*4              :: ua(:,:), u(:,:), psca(:,:)

idm = size(u,1)
jdm = size(u,2)

if (id == 1) then ! x-dir

 do i = 1,idm-1
    ua(i,:) = (u(i+1,:)-u(i,:))/psca(i,:)
 enddo

! BCs
   ua(idm,:) = (u(idm,:)-u(idm-1,:))/psca(idm,:)

else              ! y-dir

 do j = 2,jdm
    ua(:,j) = (u(:,j)-u(:,j-1))/psca(:,j)
 enddo

! BCs

   ua(:,1)   = (u(:,2)-u(:,1))/psca(:,1)
endif

end subroutine dd

subroutine q2p(uq)
integer             :: i,j,idm,jdm,jm1,ip1
real*4              :: uq(:,:)
real*4,allocatable  :: up(:,:)

idm = size(uq,1)
jdm = size(uq,2)

allocate ( up(idm,jdm))

do j= 1,jdm
 if (j.ne.1) then
  jm1 = j-1
 else
  jm1 = 1
 endif
do i= 1,idm
 if (i.ne.idm) then
  ip1 = i+1
 else
  ip1 = idm
 endif

 up(i,j) = 0.25*(uq(i,j) + uq(ip1,j) + uq(i,jm1) + uq(ip1,jm1))
enddo
enddo

 uq = up

end subroutine q2p

end module modfd

