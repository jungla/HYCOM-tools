program PK 
 use modfunctions
 use modiof

 implicit none

 real*4,  allocatable :: w(:,:,:),r(:,:,:)
 real*4,  allocatable :: plat(:,:),f(:,:)
 real*4,  allocatable :: ml(:,:)
 integer,  parameter  :: nl=27, ids=808, jds=193
 real*4 , parameter   :: omg  = 7.2921150e-5, gf = 9.806
 real*4 , parameter   :: pi   = 3.1415926535897932384626433832795

 character*8,parameter :: flnmr='fort.10A', flnmw='fort.11A'
 character*8,parameter :: flnmo='fort.00A', flnmh='fort.12A'
   
 integer      i,j,l
 real*4       rt,zt,mPK,tPK,h(nl)

 allocate (    w(ids,jds,nl) )
 allocate (    r(ids,jds,nl) )
 allocate (   ml(ids,jds) )
 allocate ( plat(ids,jds) )

! read density

!write(*,*) 'read density'

do l=1,nl
! write(*,*) l
 call rbf(flnmr,ids,jds,l,r(:,:,l))
! write(*,*) r(1,1,l)
 call rbf(flnmw,ids,jds,l,w(:,:,l))
! write(*,*) w(1,1,l)
enddo

! read ml depth
 call rhf(flnmh,ids,jds,6,ml)

 ml = ml/9806

! build layer thickness


h(1) = 0.0
h(2) = 2.0
h(3) = 5.0
h(4) = 10.0
h(5) = 15.0
h(6) = 20.0
h(7) = 30.0
h(8) = 40.0
h(9) = 50.0
h(10) = 60.0
h(11) = 70.0
h(12) = 80.0
h(13) = 100.0
h(14) = 120.0
h(15) = 140.0
h(16) = 160.0
h(17) = 180.0
h(18) = 200.0
h(19) = 250.0
h(20) = 300.0
h(21) = 350.0
h(22) = 400.0
h(23) = 450.0
h(24) = 500.0
h(25) = 550.0
h(26) = 650.0
h(27) = 700.0


!write(*,*) 'layer thickness'


! compute Rd
!write(*,*) 'Compute Rd'

do i=1,ids
 do j=1,jds
  tPK = 0
  tPK = tPK + w(i,j,1)*r(i,j,1)*h(1)
  l=2

  do while (h(l) .lt. ml(i,j) .and. l.lt.nl)
  ! write(*,*) l
   tPK = tPK + r(i,j,l)*w(i,j,l)*(h(l)-h(l-1))

!   if (i.eq.100.and.j.eq.50) then
!    write(*,*) l,r(i,j,l)*w(i,j,l),h(l),tPK/h(l)
!   endif

   l=l+1
  enddo

! compute density at the ml
 call linterp(h(l),h(l+1),w(i,j,l)*r(i,j,l),w(i,j,l+1)*r(i,j,l+1),ml(i,j),mPK) 

! average delta in the ml, rho_0
 tPK = tPK + mPK*(ml(i,j)-h(l-1)) ! add the density between last layer and ml
 tPK = tPK/ml(i,j)

! if (i.eq.500.and.j.eq.500) then
!  write(*,*) tPK,mPK,ml(i,j),h(l-1)
! endif

 enddo
enddo

 write(*,*) tPK

! call wbf(flnmo,ids,jds,1,PK)

end
