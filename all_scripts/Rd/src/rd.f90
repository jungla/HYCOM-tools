program rd
 use modfunctions
 use modiof
 use modts2sigma

 implicit none

 real*4,  allocatable :: u(:,:,:),v(:,:,:),r(:,:,:),rdf(:,:)
 real*4,  allocatable :: T(:,:),S(:,:),h(:,:,:)
 real*4,  allocatable :: plat(:,:),f(:,:)
 real*4,  allocatable :: ml(:,:)
 integer,  parameter  :: nl=30
 real*4 , parameter   :: omg  = 7.2921150e-5, gf = 9.806
 real*4 , parameter   :: pi   = 3.1415926535897932384626433832795

 character*8,parameter :: flnmi='fort.10A', flnmo='fort.12A'
 character*8,parameter :: flnmr='fort.21A'
   
 integer      i,j,l,idm,jdm,z(nl)
 real*4       rt,zt,dz,mrho,trho,drho

 call xcspmd(idm,jdm)  !define idm,jdm

 allocate (    r(idm,jdm,nl) )
 allocate (    h(idm,jdm,nl) )
 allocate (  rdf(idm,jdm) )
 allocate (   ml(idm,jdm) )
 allocate (    T(idm,jdm) )
 allocate (    S(idm,jdm) )
 allocate ( plat(idm,jdm) )
 allocate (    f(idm,jdm) )

! use HYCOM archives in hybrid coordinates

call rhf(flnmr,idm,jdm,2, plat(:,:))

! coriolis
do i = 1,idm
 do j = 1,jdm
 f(i,j) = 2*omg*sin(plat(i,j)*pi/180)
 enddo
enddo

! initiate fields
mrho = 10e30
drho = 10e30

! read density
write(*,*) 'read density'

do l=1,nl

 call rhf(flnmi,idm,jdm,10+l*5,T)
 call rhf(flnmi,idm,jdm,11+l*5,S)

   do i=1,idm
    do j=1,jdm
    call sigma2(r(i,j,l),T(i,j),S(i,j))
    enddo
   enddo

enddo

 r = r + 1000

! read ml depth
 call rhf(flnmi,idm,jdm,6,ml)

 ml = ml/9806


! build layer thickness
write(*,*) 'layer thickness'

call rhf(flnmi,idm,jdm,9+5,h(:,:,1))
h(:,:,1) = h(:,:,1)/9806

do l=2,nl
   call rhf(flnmi,idm,jdm,9+l*5,h(:,:,l))
   h(:,:,l) = h(:,:,l-1) + h(:,:,l)/9806
enddo

! compute Rd
write(*,*) 'Compute Rd'

do i=1,idm
 do j=1,jdm
  trho = 0
  trho = trho + r(i,j,1)*h(i,j,1)
  l=2

  do while (h(i,j,l) .lt. ml(i,j) .and. l.lt.nl)
  ! write(*,*) l
   trho = trho + r(i,j,l)*(h(i,j,l)-h(i,j,l-1))

   if (i.eq.500.and.j.eq.500) then
    write(*,*) l,r(i,j,l),h(i,j,l),trho/h(i,j,l)
   endif

   l=l+1
  enddo

! compute density at the ml
 call linterp(h(i,j,l),h(i,j,l+1),r(i,j,l),r(i,j,l+1),ml(i,j),mrho) 

! average delta in the ml, rho_0
 trho = trho + mrho*(ml(i,j)-h(i,j,l-1)) ! add the density between last layer and ml
 trho = trho/ml(i,j)

! delta rho with the surface
 drho = r(i,j,1)-mrho

 rdf(i,j) = (gf*drho*ml(i,j))/(trho*f(i,j)**2)

 if (i.eq.500.and.j.eq.500) then
  write(*,*) rdf(i,j),trho,drho,mrho,ml(i,j),h(i,j,l-1)
 endif


 enddo
enddo

 call wbf(flnmo,idm,jdm,1,rdf)

end
