module modfilter

contains

subroutine sinxx(u,uf,pscx,pscy,idm,jdm,lambdac,flag)

real*4,  parameter :: pi=3.141592
real*4  :: uf(idm,jdm),u(idm,jdm),pscx(idm,jdm),pscy(idm,jdm)
real*4  :: lambdac,delta,deltac,kc,gnorm,G,a
integer :: i,j,it,countit,idif,i0,j0,flag

! flag defines if Lanczos contribution is computed (flag == 1) or not (flag != 1) G=G*sin(kc*delta/a)/(kc*delta/a)

deltac = lambdac/2.
kc     = 2*pi/lambdac
idif   = int(pi*deltac)*2
a      = 1.*lambdac/2.

write(*,*) 'lambdac (m) = ',lambdac

countit = 0

if (flag == 1) then

   do i0 = 1,idm
    do j0 = 1,jdm

    if (u(i0,j0).lt.10000) then
     gnorm = 0.
     uf(i0,j0) = 0.
     idif = int(1*lambdac/(2*pscx(1,j0)))+1
  
     do i = max(1,i0-idif),min(i0+idif,idm)
      do j = max(1,j0-idif),min(j0+idif,jdm)
       if (i.eq.i0.and.j.eq.j0) then
        G = 1.
       else
        delta = (i-i0)**2*pscx(i,j)**2+(j-j0)**2*pscy(i,j)**2
        delta = sqrt(delta)
        G = sin(kc*delta)/(kc*delta)
        G=G*sin(kc*delta/a)/(kc*delta/a)
       endif
       if (u(i,j).lt.10000) then
        uf(i0,j0) = uf(i0,j0)+u(i,j)*G
        gnorm = gnorm+G
        !gnorm=gnorm+abs(G)
       endif
      enddo !j
     enddo !i 

     if (gnorm.ne.0) then
      uf(i0,j0) = uf(i0,j0)/gnorm
     endif

    else
     uf(i0,j0) = 10e30
     countit = countit+1
     if (mod(countit,500000).eq.0) print*,'iterations=',countit

    endif

    enddo !j0
   enddo !i0

else

   do i0 = 1,idm
    do j0 = 1,jdm

    if (u(i0,j0).lt.10000) then
     gnorm = 0.
     uf(i0,j0) = 0.
     idif = int(1*lambdac/(2*pscx(1,j0)))+1

     do i = max(1,i0-idif),min(i0+idif,idm)
      do j = max(1,j0-idif),min(j0+idif,jdm)
       if (i.eq.i0.and.j.eq.j0) then
        G = 1.
       else
        delta = (i-i0)**2*pscx(i,j)**2+(j-j0)**2*pscy(i,j)**2
        delta = sqrt(delta)
        G = sin(kc*delta)/(kc*delta)
       endif
       if (u(i,j).lt.10000) then
        uf(i0,j0) = uf(i0,j0)+u(i,j)*G
        gnorm = gnorm+G
        !gnorm=gnorm+abs(G)
       endif
      enddo !j
     enddo !i 

     if (gnorm.ne.0) then
      uf(i0,j0) = uf(i0,j0)/gnorm
     endif

    else
     uf(i0,j0) = 10e30
     countit = countit+1
     if (mod(countit,500000).eq.0) print*,'iterations=',countit

    endif

    enddo !j0
   enddo !i0



endif

return
end subroutine





end module



