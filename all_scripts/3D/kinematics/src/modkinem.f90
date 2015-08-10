module modkinem

!! contains subroutines to compute vorticity, shearing, stretching in the
!! p-points.

contains

subroutine vor(vort,pscx,pscy,idm,jdm,u,v)      

! qscx,qscy
! from u,v to p points

integer :: idm,jdm
real*4  :: vort(idm,jdm),tvort(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: pscx(idm,jdm),pscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

do j= 1,jdm
 if     (j.ne.1) then
  jm1 = j-1
  else
  jm1 = 1 
 endif
 do i= 1,idm
  if     (i.ne.1) then
   im1 = i-1
  else
   im1 =   1 
  endif
  tvort(i,j) = pscx(i,j)*(v(i,j)-v(im1,j)) - pscy(i,j)*(u(i,j)-u(i,jm1))
 enddo
enddo

do j= 1,jdm
 if     (j.ne.jdm) then
  jp1 = j+1
 else
  jp1 = jdm
 endif
do i= 1,idm
 if     (i.ne.idm) then
  ip1 = i+1
 else
  ip1 = idm
 endif

 vort(i,j) = 0.25*(tvort(i,j) + tvort(ip1,j) + tvort(i,jp1) + tvort(ip1,jp1))
 
if(abs(vort(i,j)).gt.2e10 .or. u(i,j).gt.2e10 .or. v(i,j).gt.2e10) vort(i,j) = 10e30

enddo
enddo

end subroutine vor

subroutine div(diver,qscx,qscy,idm,jdm,u,v)

! pscx,pscy

integer :: idm,jdm
real*4  :: diver(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: qscx(idm,jdm),qscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

do j= 1,jdm
 if     (j.ne.jdm) then
  jp1 = j+1
 else
  jp1 = jdm
 endif
do i= 1,idm
 if     (i.ne.idm) then
  ip1 = i+1
 else
  ip1 = idm
 endif

 diver(i,j) = qscx(i,j)*(u(ip1,j) - u(i,j)) + qscy(i,j)*(v(i,jp1) - v(i,j))
            
 if(abs(diver(i,j)).gt.(1.0e10).or. u(i,j).gt.2e10 .or. v(i,j).gt.2e10) diver(i,j) = 10e30
          enddo
        enddo

endsubroutine div

subroutine shr(shear,qscx,qscy,idm,jdm,u,v)

! qscx, qscy

integer :: idm,jdm
real*4  :: shear(idm,jdm),tshear(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: qscx(idm,jdm),qscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

do j= 1,jdm
 if     (j.ne.1) then
  jm1 = j-1
 else
  jm1 = 1    ! assume no change across southern boundary
 endif
do i= 1,idm
 if     (i.ne.1) then
  im1 = i-1
 else
  im1 =   1  ! assume non-periodic boundary
 endif

tshear(i,j) = qscx(i,j)*(v(i,j) - v(im1,j)) + qscy(i,j)*(u(i,j) - u(i,jm1))

enddo
enddo

do j= 1,jdm
 if     (j.ne.jdm) then
  jp1 = j+1
 else
  jp1 = jdm  ! assume no change across northern boundary
 endif
do i= 1,idm
 if     (i.ne.idm) then
  ip1 = i+1
 else
  ip1 = idm  ! assume non-periodic boundary
 endif

shear(i,j) = 0.25*(tshear(i,j) + tshear(ip1,j) + shear(i,jp1) + tshear(ip1,jp1))

  if(abs(shear(i,j)).gt.(1.0e10).or. u(i,j).gt.2e10 .or. v(i,j).gt.2e10) shear(i,j) = 10e30
 enddo
enddo

end subroutine shr


subroutine str(stretch,pscx,pscy,idm,jdm,u,v)

! pscx, pscy

integer :: idm,jdm
real*4  :: stretch(idm,jdm),u(idm,jdm),v(idm,jdm)
real*4  :: pscx(idm,jdm),pscy(idm,jdm)
integer :: i,j,im1,ip1,jp1,jm1

do j= 1,jdm
 if     (j.ne.jdm) then
  jp1 = j+1
 else
  jp1 = jdm  ! assume no change across northern boundary
 endif
do i= 1,idm
 if     (i.ne.idm) then
  ip1 = i+1
 else
  ip1 = idm  ! assume non-periodic boundary
 endif

  stretch(i,j) = pscx(i,j)*(u(ip1,j) - u(i,j)) - pscy(i,j)*(v(ip1,j) - v(i,j))
   if(abs(stretch(i,j)).gt.(1.0e10).or. u(i,j).gt.2e10 .or. v(i,j).gt.2e10) stretch(i,j) = 10e30
 enddo
enddo

end subroutine str

subroutine okw(okbwss,idm,jdm,str,shear,vort,u,v)
! p-points
integer :: idm,jdm
real*4  :: u(idm,jdm),v(idm,jdm),okbwss(idm,jdm),str(idm,jdm),shear(idm,jdm),vort(idm,jdm)
integer :: i,j

      do j= 1,jdm
       do i= 1,idm
        okbwss(i,j) = str(i,j)**2 + shear(i,j)**2 - vort(i,j)**2
if(abs(okbwss(i,j)).gt.(1.0e10).or. u(i,j).gt.2e10 .or. v(i,j).gt.2e10) okbwss(i,j) = 10e30
       enddo
      enddo

end subroutine okw


end module modkinem
