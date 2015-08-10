module modfunctions

contains

subroutine linterp(x1,x2,y1,y2,xm,ym)
real*4 :: x1,x2,y1,y2,xm,ym,x1x2
x1x2 = 1/(x1-x2)
ym = (y1-y2)*x1x2*xm+(x1*y2-x2*y1)*x1x2
return
end subroutine

subroutine smooth2(R,times)
real*4             :: R(:,:)
real*4,allocatable :: Rf(:,:)
integer :: ids,jds,times,np,i,j,k,t,ip,jp

ids = size(R,1)
jds = size(R,2)

allocate ( Rf(ids,jds))

Rf = 10e30

do t=1,times

 do i=1,ids
  do j=1,jds

  if (R(i,j).lt.10e10) then
   Rf(i,j) = R(i,j)
   np = 1

   do k = 1,4

   select case (k)
   case (1)
   ip = -1
   jp = 0
   case (2)
   ip = 0
   jp = -1
   case (3)
   ip = 1
   jp = 0
   case default
   ip = 0
   jp = 1
   end select

   if (i+ip.gt.0 .and. j+jp.gt.0 .and. i+ip.lt.ids .and. j+jp.lt.jds) then
    if (R(i+ip,j+jp).lt.10e10) then
     Rf(i,j) = Rf(i,j) + R(i+ip,j+jp)
     np = np + 1
    endif
   endif

   enddo ! do
   Rf(i,j) = Rf(i,j)/np
  endif ! if

  enddo ! i
 enddo ! j

R = Rf
enddo ! t

return

end subroutine
end module
