module modkinem

!! contains subroutines to compute vorticity, shearing, stretching in the
!! p-points.

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
real*4  :: pscx(idm,jdm),pscy(idm,jdm)
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
