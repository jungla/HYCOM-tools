module modiobf
contains

subroutine rbf(flnm,imax,jmax,irec,orec)      
integer :: imax,jmax
real*4  :: orec(imax,jmax)
character*8 :: flnm
integer :: ld,irec,nrecl,npad

nrecl=4*(imax*jmax)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl,status='old')

!     uclinic first layer
read(21,rec=irec) orec
!     vclinic first layer

close(21)
return
end subroutine rbf

!!!!!!!!!!writing subroutines!!!!!!!!!!!!!!!!

subroutine wbf(flnm,imax,jmax,irec,orec)
integer,intent(in)::imax,jmax
real*4 :: orec(imax,jmax)
character*8 :: flnm
integer :: ld,irec,nrecl,npad

nrecl=4*(imax*jmax)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl,status='new')


!     uclinic first layer

write(21,rec=irec) orec
!     vclinic first layer
stop
close(21)
end subroutine wbf


end module modiobf
