module modIOHF
contains

subroutine RHF(flnm,imax,jmax,irec,orec)      
integer :: imax,jmax
real*4  :: orec(imax,jmax)
character*8 :: flnm
integer :: ld,irec,nrecl,npad

npad=4096-mod(imax*jmax,4096)

nrecl=4*(imax*jmax+npad)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl,status='old')

!     uclinic first layer
read(21,rec=irec) orec
!     vclinic first layer

close(21)
return
end subroutine RHF

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

subroutine WHF(flnm,imax,jmax,irec,orec)
integer,intent(in)::imax,jmax
real*4 :: orec(imax,jmax)
character*8 :: flnm
integer :: ld,irec,nrecl,npad

npad=4096-mod(imax*jmax,4096)

nrecl=4*(imax*jmax+npad)
open(21,file=flnm,form='unformatted',access='direct', recl=nrecl,status='new')


!     uclinic first layer

write(21,rec=irec) orec
!     vclinic first layer
stop
close(21)
end subroutine WHF


end module modIOHF
