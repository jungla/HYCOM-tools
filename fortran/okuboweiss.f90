program okuboweiss
use modiof  ! hycom array i/o interface
use modkinem

implicit none
      integer, allocatable :: msk(:,:)
      real*4,  allocatable :: qscx(:,:),qscy(:,:),pscx(:,:),pscy(:,:)
      real*4,  allocatable :: txm(:,:),tym(:,:),stret(:,:),      &    
      txp(:),typ(:),u(:,:),v(:,:),uhyc(:,:),vhyc(:,:),     & 
      vort(:,:),qvort(:,:),shear(:,:),qshear(:,:),okbwss(:,:,:)

      integer,  parameter   :: kdm = 30
      real*4, parameter     :: onem = 1.0

      character preambl(5)*79

      character*8,parameter :: flnm='fort.10A', flnmo='fort.12A'
      character*8,parameter :: flnmr='fort.21A'
      integer      idm,jdm,i,j,k
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
      allocate(  vort(idm,jdm) )
      allocate( qvort(idm,jdm) )
      allocate(  stret(idm,jdm) )
      allocate(  shear(idm,jdm) )
      allocate( qshear(idm,jdm) )
      allocate( okbwss(idm,jdm,kdm) )
      allocate( u(idm,jdm) )
      allocate( uhyc(idm,jdm) )
      allocate( v(idm,jdm) )
      allocate( vhyc(idm,jdm) )
      allocate(   txp(0:idm) )
      allocate(   typ(0:jdm) )

     call rhf(flnmr,idm,jdm,10,pscx)
     call rhf(flnmr,idm,jdm,11,pscy)
     call rhf(flnmr,idm,jdm,12,qscx)
     call rhf(flnmr,idm,jdm,13,qscy)

      do i= 1,idm
        do j= 1,jdm
          pscx(i,j) = 1.0/max(onem,pscx(i,j)) !1/pscx
          pscy(i,j) = 1.0/max(onem,pscy(i,j)) !1/pscy
          qscx(i,j) = 1.0/max(onem,qscx(i,j)) !1/qscx
          qscy(i,j) = 1.0/max(onem,qscy(i,j)) !1/qscy
        enddo
      enddo

     call rhf(flnm,idm,jdm,10,uhyc)
     call rhf(flnm,idm,jdm,11,vhyc)

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

     call vor(vort,qscx,qscy,idm,jdm,txm,tym)
     call shr(shear,qscx,qscy,idm,jdm,txm,tym)
     call str(stret,pscx,pscy,idm,jdm,txm,tym)

call okw(okbwss(:,:,k),idm,jdm,stret,shear,vort,txm,tym)

write(*,*) okbwss(10,10,k)

enddo

call wbf3d(flnmo,idm,jdm,kdm,okbwss)
     
end
