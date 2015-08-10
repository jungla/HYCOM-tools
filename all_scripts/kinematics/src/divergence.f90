program divergence
use modiof  ! hycom array i/o interface
use modkinem

implicit none
!
!     wind arrays.
!
      integer, allocatable :: msk(:,:)
      real*4,  allocatable :: qscx(:,:),qscy(:,:),pscx(:,:),pscy(:,:)
      real*4,  allocatable :: txm(:,:),tym(:,:),      &    
      txp(:),typ(:),u(:,:),v(:,:),uhyc(:,:),vhyc(:,:),     & 
      divt(:,:,:)

      real*4,  parameter   :: onem=1.0
      integer,  parameter   :: kdm = 30

      character*8,parameter :: flnm='fort.10A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      k,idm,jdm,i,ios,im1,ip1,j,jm1,jp1,krec,nrec,irec,npad
      real*4       hmina,hminb,hmaxa,hmaxb
      real*4       xmin,xmax,q,area,temp
!
! --- model arrays.
!
      call xcspmd(idm,jdm)  !define idm,jdm

      allocate(   msk(idm,jdm) )
      allocate(  pscx(idm,jdm) )
      allocate(  pscy(idm,jdm) )
      allocate(  qscx(idm,jdm) )
      allocate(  qscy(idm,jdm) )
      allocate(   txm(idm,jdm) )
      allocate(   tym(idm,jdm) )
      allocate(  divt(idm,jdm,kdm) )
      allocate( u(idm,jdm) )
      allocate( uhyc(idm,jdm) )
      allocate( v(idm,jdm) )
      allocate( vhyc(idm,jdm) )
      allocate(   txp(0:idm) )
      allocate(   typ(0:jdm) )

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

!      write(6,*) txm(500,500)
!      write(6,*) tym(500,500)
!      write(6,*) qscx(500,500)
!      write(6,*) qscy(500,500)

do k=1,kdm
     write(*,*) k
     call rhf(flnm,idm,jdm,7+5*k,u)
     call rhf(flnm,idm,jdm,8+5*k,v)
     do i=1,idm
      do j=1,jdm
       txm(i,j)=uhyc(i,j)+u(i,j)
       tym(i,j)=vhyc(i,j)+v(i,j)
      enddo
     enddo

call div(divt(:,:,k),pscx,pscy,idm,jdm,txm,tym)


enddo

call wbf3d(flnmo,idm,jdm,kdm,divt)
     
end
