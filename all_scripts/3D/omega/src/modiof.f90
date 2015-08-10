module modiof

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

subroutine rbf3d(flnm,imax,jmax,nlayers,orec)
integer :: imax,jmax
real*4  :: orec(imax,jmax)
character*8 :: flnm
integer :: nlayers,nrecl,npad

nrecl=4*(imax*jmax)*nlayers
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl, status='old')
read(21,rec=irec) orec
close(21)
return
end subroutine rbf3d

!!!!!!!!!!writing subroutines!!!!!!!!!!!!!!!!

subroutine wbf(flnm,imax,jmax,irec,orec)
integer,intent(in)::imax,jmax
real*4 :: orec(imax,jmax)
character*8 :: flnm
integer :: ld,irec,nrecl,npad

nrecl=4*(imax*jmax)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl,status='new')

write(21,rec=irec) orec

close(21)
return
end subroutine wbf

subroutine wbf3d(flnm,imax,jmax,nl,orec)
integer,intent(in)::imax,jmax
real*4 :: orec(imax,jmax,nl)
character*8 :: flnm
integer :: l,nl,nrecl,npad

nrecl=4*(imax*jmax)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl, status='new')

do l=1,nl
 write(21,rec=l) orec(:,:,l)
enddo

close(21)
return
end subroutine wbf3d

!! HYCOM archives !!

subroutine rhf(flnm,imax,jmax,irec,orec)
integer :: imax,jmax
real*4  :: orec(imax,jmax)
character*8 :: flnm
integer :: irec,nrecl,npad

npad  = 4096-mod(imax*jmax,4096)
nrecl = 4*(imax*jmax+npad)

open(21,file=flnm,form='unformatted',access='direct', recl=nrecl, status='old')
read(21,rec=irec) orec
close(21)
return
end subroutine rhf

subroutine xcspmd(idm,jdm)
implicit none
integer :: idm,jdm,lp,mnproc
!
      character cvarin*6
      mnproc = 1
      lp     = 6
!
open(unit=11,file='fort.21',form='formatted',status='old',action='read')

      read( 11,*) idm,cvarin
      read( 11,*) jdm,cvarin

      write(lp,'(/ a,2i5 /)') 'xcspmd: idm,jdm =',idm,jdm

      close(unit=11)
      return
      end subroutine xcspmd

!!!!!!!!!!WRITING SUBROUTINES!!!!!!!!!!!!!!!!

subroutine whf(flnm,imax,jmax,irec,orec)
integer,intent(in)  ::imax,jmax
real*4              :: orec(imax,jmax)
character*8         :: flnm
integer             :: ld,irec,nrecl,npad

npad=4096-mod(imax*jmax,4096)

nrecl=4*(imax*jmax+npad)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl,status='new')

write(21,rec=irec) orec

close(21)
end subroutine whf


end module modiof
