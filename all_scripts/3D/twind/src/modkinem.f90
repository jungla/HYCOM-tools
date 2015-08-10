module modkinem

implicit none

!! contains subroutines to compute vorticity, shearing, stretching in the
!! p-points.

contains

! ++++++++++++++++++++++++++
! +     1D derivatives     +
! ++++++++++++++++++++++++++

subroutine ddf(ua,u,psca,id)
! FORWARD difference
! from p points to u points and viceversa

integer*4             :: j,i,id,idm,jdm,t
real*4                :: ua(:,:), u(:,:), psca(:,:)

idm = size(u,1)
jdm = size(u,2)


if (u(i,j) .lt. 10e10) then

 if (id == 1) then ! x-dir

  if (u(i+1,j) .lt. 10e10) then
   do i = 1,idm
    ua(i,:) = (u(i+1,:)-u(i,:))/psca(i+1,:)
   enddo
  else if (u(i-1,j) .lt. 10e10) then
   do i = 1,idm
    ua(i,:) = (u(i,:)-u(i-1,:))/psca(i,:)
   enddo
  else
   ua(:,:) = 0 ! if both the value before and the value after are land
  endif

 else              ! y-dir

  if (u(i,j+1) .lt. 10e10) then
   do j = 1,jdm
    ua(:,j) = (u(:,j+1)-u(:,j))/psca(:,j+1)
   enddo
  else if (u(i,j-1) .lt. 10e10) then
   do j = 1,jdm
    ua(:,j) = (u(:,j)-u(:,j-1))/psca(:,j)
   enddo
  else
   ua(:,:) = 0 ! if both the value before and the value after are land
  endif

 endif

endif

end subroutine ddf

subroutine dd2c(ua,u,g,usca,psca,id)
! CENTERED DIFFERENCE
! in the point

integer*4             :: j,i,id,idm,jdm,t
real*4                :: ua(:,:), u(:,:), g(:,:), usca(:,:),psca(:,:)

idm = size(u,1)
jdm = size(u,2)

if (id == 1) then ! x-dir

 do i = 2,idm-1
  do j = 1,jdm
   if (abs(g(i,j)) .lt. 10e10) then
!    if (abs(g(i+1,j)) .lt. 10e10 .and. abs(g(i-1,j)) .lt. 10e10) then
     ua(i,j) = (usca(i,j)*(u(i+1,j)-u(i,j))-usca(i+1,j)*(u(i,j)-u(i-1,j)))/(usca(i,j)*usca(i+1,j)*psca(i,j))   ! OK
!    else if (abs(g(i-1,j)) .lt. 10e10) then  ! use halo points...
!     ua(i,j) = (usca(i,j)*(-u(i,j))-usca(i+1,j)*(u(i,j)-u(i-1,j)))/(usca(i,j)*usca(i+1,j)*psca(i,j))   ! OK
!    else if (abs(g(i+1,j)) .lt. 10e10) then  ! fd
!     ua(i,j) = (usca(i,j)*(u(i+1,j)-u(i,j))-usca(i+1,j)*(u(i,j)))/(usca(i,j)*usca(i+1,j)*psca(i,j))   ! OK
!    else
!     ua(i,j) = 10e30
!    endif
   endif
  enddo
 enddo

 ! BCs
  do j = 1,jdm
   if (abs(g(1,j)) .lt. 10e10 .and. abs(g(2,j)) .lt. 10e10) then
    ua(1,j) = ua(2,j)
!    ua(1,j) = (usca(1,j)*(u(2,j)-u(1,j))-usca(2,j)*(u(1,j)))/(usca(1,j)*usca(2,j)*psca(1,j))   ! OK
!   else if (abs(g(idm,j)) .lt. 10e10 .and. abs(g(idm-1,j)) .lt. 10e10) then
!    ua(idm,j) = (usca(idm,j)*(-u(idm,j))-usca(idm,j)*(u(idm,j)))/(usca(idm,j)*usca(idm,j)*psca(idm,j))   ! OK
!    ua(idm,j) = ua(idm-1,j)
   endif
  enddo

else              ! y-dir

 do i = 1,idm
  do j = 2,jdm-1
   if (abs(g(i,j)) .lt. 10e10) then
!   if (abs(g(i,j)) .lt. 10e10) then
!    if (abs(g(i,j+1)) .lt. 10e10 .and. abs(g(i,j-1)) .lt. 10e10) then
     ua(i,j) = (usca(i,j)*(u(i,j+1)-u(i,j))-usca(i,j+1)*(u(i,j)-u(i,j-1)))/(usca(i,j)*usca(i,j+1)*psca(i,j))   ! OK
!    else if (abs(g(i,j-1)) .lt. 10e10) then
!     ua(i,j) = (usca(i,j)*(-u(i,j))-usca(i,j+1)*(u(i,j)-u(i,j-1)))/(usca(i,j)*usca(i,j+1)*psca(i,j))   ! OK
!    else if (abs(g(i,j+1)) .lt. 10e10) then
!     ua(i,j) = (usca(i,j)*(u(i,j+1)-u(i,j))-usca(i,j+1)*(u(i,j)))/(usca(i,j)*usca(i,j+1)*psca(i,j))   ! OK
!    else
!     ua(i,j) = 10e30
!    endif
   endif
  enddo
 enddo

 ! BCs
  do i = 1,idm
   if (abs(g(i,1)) .lt. 10e10 .and. abs(g(i,2)) .lt. 10e10) then
!    ua(i,1) = (usca(i,1)*(u(i,2)-u(i,1))-usca(i,2)*(u(i,1)))/(usca(i,1)*usca(i,2)*psca(i,1))   ! OK
    ua(i,1) = ua(i,2)
!   else if (abs(g(i,jdm)) .lt. 10e10 .and. abs(g(i,jdm-1)) .lt. 10e10) then
!    ua(i,jdm) = (usca(i,jdm)*(-u(i,jdm))-usca(i,jdm)*(u(i,jdm)))/(usca(i,jdm)*usca(i,jdm)*psca(i,jdm))   ! OK
!    ua(i,jdm) = ua(i,jdm-1)
   endif
  enddo

endif

end subroutine dd2c


subroutine ddc(ua,u,psca,id)
! CENTERED DIFFERENCE
! in the p point

integer*4             :: i,j,id,idm,jdm,t
real*4                :: ua(:,:), u(:,:), psca(:,:)

idm = size(u,1)
jdm = size(u,2)

if (id == 1) then ! x-dir

 do i = 2,idm-1
  do j = 1,jdm
   if (abs(u(i,j)) .lt. 10e10) then
    if (abs(u(i+1,j)) .lt. 10e10 .and. abs(u(i-1,j)) .lt. 10e10) then
     ua(i,j) = (u(i+1,j)-u(i-1,j))/(psca(i+1,j)+psca(i,j))
    else if (abs(u(i-1,j)) .lt. 10e10) then
     ua(i,j) = (u(i,j)-u(i-1,j))/psca(i,j)
    else if (abs(u(i+1,j)) .lt. 10e10) then
     ua(i,j) = (u(i+1,j)-u(i,j))/psca(i+1,j)
    else
     ua(i,j) = 10e30
    endif
   else
    ua(i,j) = 10e30
   endif
  enddo
 enddo

 ! BCs
  do j = 1,jdm 
   if (abs(u(1,j)) .lt. 10e10 .and. abs(u(2,j)) .lt. 10e10) then
    ua(1,j) = (u(2,j)-u(1,j))/psca(2,j)
   endif
   if (abs(u(idm,j)) .lt. 10e10 .and. abs(u(idm-1,j)) .lt. 10e10) then
    ua(idm,j) = (u(idm,j)-u(idm-1,j))/psca(idm,j)
   endif
  enddo

else              ! y-dir

 do i = 1,idm
  do j = 2,jdm-1
   if (abs(u(i,j)) .lt. 10e10) then
    if (abs(u(i,j+1)) .lt. 10e10 .and. abs(u(i,j-1)) .lt. 10e10) then
     ua(i,j) = (u(i,j+1)-u(i,j-1))/(psca(i,j+1)+psca(i,j))
    else if (abs(u(i,j-1)) .lt. 10e10) then
     ua(i,j) = (u(i,j)-u(i,j-1))/psca(i,j)
    else if (abs(u(i,j+1)) .lt. 10e10) then
     ua(i,j) = (u(i,j+1)-u(i,j))/psca(i,j+1)
    else
     ua(i,j) = 10e30
    endif
   else
    ua(i,j) = 10e30
   endif
  enddo
 enddo

 ! BCs
  do i = 1,idm
   if (abs(u(i,1)) .lt. 10e10 .and. abs(u(i,2)) .lt. 10e10) then
    ua(i,1)   = (u(i,2)-u(i,1))/psca(i,2)
   endif
   if (abs(u(i,jdm)) .lt. 10e10 .and. abs(u(i,jdm-1)) .lt. 10e10) then
    ua(i,jdm) = (u(i,jdm)-u(i,jdm-1))/psca(i,jdm)
   endif
  enddo

endif


end subroutine ddc


! +++++++++++++++++++++++++
! +     2D quantities     +
! +++++++++++++++++++++++++

subroutine vor(vort,qscx,qscy,idm,jdm,u,v)      
integer :: idm,jdm
real*4  :: vort(idm,jdm),tvort(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: qscx(idm,jdm),qscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

DO J= 1,JDM
 IF     (J.NE.1) THEN
  JM1 = J-1
  ELSE
  JM1 = 1    ! assume no change across southern boundary
 ENDIF
 DO I= 1,IDM
  IF     (I.NE.1) THEN
   IM1 = I-1
  ELSE
   IM1 =   1  ! assume non-periodic boundary
  ENDIF
  tvort(I,J) = QSCX(I,J)*(v(I,J) - v(IM1,J)) - QSCY(I,J)*(u(I,J) - u(I,JM1))

 ENDDO
ENDDO

DO J= 1,JDM
 IF     (J.NE.JDM) THEN
  JP1 = J+1
 ELSE
  JP1 = JDM  ! assume no change across northern boundary
 ENDIF
DO I= 1,IDM
 IF     (I.NE.IDM) THEN
  IP1 = I+1
 ELSE
  IP1 = IDM  ! assume non-periodic boundary
 ENDIF

 vort(I,J) = 0.25*(tvort(I,J) + tvort(IP1,J) + tvort(I,JP1) + tvort(IP1,JP1))
 if(abs(VORT(i,j)).gt.2.0**10) VORT(i,j) = 2.0**100

ENDDO
ENDDO

end subroutine vor

subroutine div(diver,qscx,qscy,idm,jdm,u,v)
integer :: idm,jdm
real*4  :: diver(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: qscx(idm,jdm),qscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

        DO J= 1,JDM-1
            JP1 = J+1    ! assume no change across southern boundary
          DO I= 1,IDM-1
              IP1 = I+1
            diver(I,J) = qscx(I,J)*(u(IP1,J) - u(I,J)) + qscy(I,J)*(v(I,JP1) - v(I,J))
            if(abs(diver(i,j)).gt.(1.0e10)) diver(i,j) = 2.0**100
          ENDDO
        ENDDO
endsubroutine div

subroutine shr(shear,qscx,qscy,idm,jdm,u,v)
integer :: idm,jdm
real*4  :: shear(idm,jdm),tshear(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: qscx(idm,jdm),qscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

DO J= 1,JDM
 IF     (J.NE.1) THEN
  JM1 = J-1
 ELSE
  JM1 = 1    ! assume no change across southern boundary
 ENDIF
DO I= 1,IDM
 IF     (I.NE.1) THEN
  IM1 = I-1
 ELSE
  IM1 =   1  ! assume non-periodic boundary
 ENDIF

TSHEAR(I,J) = QSCX(I,J)*(v(I,J) - v(IM1,J)) + QSCY(I,J)*(u(I,J) - u(I,JM1))

ENDDO
ENDDO

DO J= 1,JDM
 IF     (J.NE.JDM) THEN
  JP1 = J+1
 ELSE
  JP1 = JDM  ! assume no change across northern boundary
 ENDIF
DO I= 1,IDM
 IF     (I.NE.IDM) THEN
  IP1 = I+1
 ELSE
  IP1 = IDM  ! assume non-periodic boundary
 ENDIF

SHEAR(I,J) = 0.25*(tSHEAR(I,  J)   + &
               tSHEAR(IP1,J)   +     &
               tSHEAR(I,  JP1) +     &
               tSHEAR(IP1,JP1)  )

         ENDDO
        ENDDO

end subroutine shr


subroutine str(stretch,pscx,pscy,idm,jdm,u,v)
integer :: idm,jdm
real*4  :: stretch(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4 :: pscx(idm,jdm),pscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

        DO J= 1,JDM-1
            JP1 = J+1    ! assume no change across southern boundary
          DO I= 1,IDM-1
              IP1 = I+1
            stretch(I,J) = PSCX(I,J)*(u(IP1,J) - u(I,J)) -     &
                  PSCY(I,J)*(v(I,JP1) - v(I,J))
          ENDDO
        ENDDO
end subroutine str

subroutine okw(OKBWSS,idm,jdm,STR,SHEAR,VORT,u,v)
integer :: idm,jdm
real*4  :: OKBWSS(idm,jdm),STR(idm,jdm),SHEAR(idm,jdm),VORT(idm,jdm)
real*4  :: u(idm,jdm),v(idm,jdm)
real*4  :: pscx(idm,jdm),pscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

      DO J= 1,JDM
       DO I= 1,IDM
        OKBWSS(I,J) = STR(I,J)**2 + SHEAR(I,J)**2 - VORT(I,J)**2
       ENDDO
      ENDDO

end subroutine okw


end module modkinem
