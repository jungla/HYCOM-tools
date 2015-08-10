program shearing
use modiof  ! hycom array i/o interface
use modkinem

implicit none
!
!     wind arrays.
!
      real*4,  allocatable :: pscx(:,:),pscy(:,:)
      real*4,  allocatable :: txm(:,:),tym(:,:),u(:,:),v(:,:),uhyc(:,:),vhyc(:,:),shear(:,:,:)

      real*4,  parameter   :: onem=1.0
      integer,  parameter   :: kdm=30

      character*8,parameter :: flnm='fort.10A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      k,idm,jdm,i,ios,im1,ip1,j,jm1,jp1,krec,nrec,irec,npad
      real*4       hmina,hminb,hmaxa,hmaxb
      real*4       xmin,xmax,q,area,temp
!
! --- model arrays.
!
      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(  pscx(idm,jdm) )
      allocate(  pscy(idm,jdm) )
      allocate(   txm(idm,jdm) )
      allocate(   tym(idm,jdm) )
      allocate(  shear(idm,jdm,kdm) )
      allocate( u(idm,jdm) )
      allocate( uhyc(idm,jdm) )
      allocate( v(idm,jdm) )
      allocate( vhyc(idm,jdm) )

     call rhf(flnmr,idm,jdm,10,pscx)
     call rhf(flnmr,idm,jdm,11,pscy)
!

      do i= 1,idm
        do j= 1,jdm
          pscx(i,j) = 1.0/max(onem,pscx(i,j)) !1/pscx
          pscy(i,j) = 1.0/max(onem,pscy(i,j)) !1/pscy
        enddo
      enddo

!     initialize hycom input and output.


     call rhf(flnm,idm,jdm,10,uhyc)
     call rhf(flnm,idm,jdm,11,vhyc)

do k=1,kdm
     call rhf(flnm,idm,jdm,7+5*k,u)
     call rhf(flnm,idm,jdm,8+5*k,v)
     do i=1,idm
      do j=1,jdm
       txm(i,j)=uhyc(i,j)+u(i,j)
       tym(i,j)=vhyc(i,j)+v(i,j)
      enddo
     enddo


call shr(shear(:,:,k),pscx,pscy,idm,jdm,txm,tym)

     write(*,*) k,shear(500,500,k)

enddo

call wbf3d(flnmo,idm,jdm,kdm,shear)

     
end
