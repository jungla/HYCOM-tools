program ri
 use modiof
 use modts2sigma

 implicit none

 real*4,  allocatable :: u(:,:,:),v(:,:,:),r(:,:,:)
 real*4,  allocatable :: T(:,:),S(:,:)
 real*4,  allocatable :: N2(:,:,:),uvz(:,:,:),Rn(:,:,:)
 integer,  parameter  :: nl=41

 character*8,parameter :: flnmu='fort.10A', flnmv='fort.11A', flnmr='fort.09A', flnmo='fort.12A' &
                          ,flnmd='fort.13A'
   
 integer      i,j,l,idm,jdm,z(nl)
 real*4       rt,zt,dz

 call xcspmd(idm,jdm)  !define idm,jdm

 allocate(   u(idm,jdm,nl) )
 allocate(   v(idm,jdm,nl) )
 allocate(   r(idm,jdm,nl) )
 allocate(   N2(idm,jdm,nl) )
 allocate(   uvz(idm,jdm,nl) )
 allocate(   Rn(idm,jdm,nl) )
 allocate(   T(idm,jdm) )
 allocate(   S(idm,jdm) )

! depths
z(1)=0000
z(2)=0001
z(3)=0002
z(4)=0003
z(5)=0004
z(6)=0005
z(7)=0006
z(8)=0007
z(9)=0008
z(10)=0009
z(11)=0010
z(12)=0020
z(13)=0030
z(14)=0040
z(15)=0050
z(16)=0060
z(17)=0070
z(18)=0080
z(19)=0090
z(20)=0100
z(21)=0120
z(22)=0140
z(23)=0160
z(24)=0180
z(25)=0200
z(26)=0250
z(27)=0300
z(28)=0350
z(29)=0400
z(30)=0450
z(31)=0500
z(32)=0550
z(33)=0650
z(34)=0700
z(35)=1000
z(36)=1500
z(37)=2000
z(38)=2500
z(39)=3000
z(40)=3500
z(41)=4000


! 1 - compute brunt-vaisala freq
! 2 - compute vertical shear

do l=1,nl
 call rbf(flnmu,idm,jdm,l,u(:,:,l))
 call rbf(flnmv,idm,jdm,l,v(:,:,l))
 call rbf(flnmr,idm,jdm,l,r(:,:,l))
enddo

! call RHF(flnmd,idm,jdm,9+l*5,H(:,:,l))
! call RHF(flnmd,idm,jdm,10+l*5,T)
! call RHF(flnmd,idm,jdm,11+l*5,S)

! H(:,:,l) = H(:,:,l)/9806

! if(l .gt. 1) then
!  H(:,:,l) = H(:,:,l) + H(:,:,l-1)
! endif

! do i=1,idm
!  do j=1,jdm
!   call sigma0(Rd(i,j,l),T(i,j),S(i,j))
!  enddo
! enddo
!enddo

r = r + 1000

! 1   brunt-vaisala freq
! 1.1 mean density profile

! the definition correct is without mean density profile...


! 1.2 frequency and shear

do  i=1,idm
 do  j=1,jdm

 do l=2,nl-1
  if(r(i,j,l+1) .lt. 10e10) then
   dz = z(l+1)-z(l)
   N2(i,j,l) = 9.806/((r(i,j,l-1)+r(i,j,l)+r(i,j,l+1))/3.0)*(r(i,j,l+1) - r(i,j,l))/dz
   uvz(i,j,l) = ((u(i,j,l+1) - u(i,j,l))/dz)**2 + ((v(i,j,l+1) - v(i,j,l))/dz)**2
  else
   dz = z(l)-z(l-1)
   N2(i,j,l) = 9.806/((r(i,j,l-1)+r(i,j,l)+r(i,j,l-1))/3.0)*(r(i,j,l) - r(i,j,l-1))/dz
   uvz(i,j,l)  = ((u(i,j,l) - u(i,j,l-1))/(z(l)-z(l-1)))**2 + ((v(i,j,l) - v(i,j,l-1))/(z(l)-z(l-1)))**2
  endif
 enddo
 dz = z(nl)-z(nl-1)
 N2(i,j,nl) = 9.806/((r(i,j,nl)+r(i,j,nl-1))*0.5)*(r(i,j,nl) - r(i,j,nl-1))/dz
 uvz(i,j,nl)  = ((u(i,j,nl) - u(i,j,nl-1))/(dz))**2 + ((v(i,j,nl) - v(i,j,nl-1))/(dz))**2

 dz = z(2)
 N2(i,j,1) = 9.806/((r(i,j,2)+r(i,j,1))*0.5)*(r(i,j,2) - r(i,j,1))/dz
 uvz(i,j,1)  = ((u(i,j,2) - u(i,j,1))/(dz))**2 + ((v(i,j,2) - v(i,j,1))/(dz))**2

enddo
enddo

! 3 Richardson number

do l=1,nl
 Rn(:,:,l) = N2(:,:,l)/uvz(:,:,l)
enddo

! 4 sanitize
do  i=1,idm
 do  j=1,jdm
  do l=1,nl
   if(r(i,j,l) .gt. 10e10) then
    Rn(i,j,l) = 10e30
   endif
  enddo
 enddo
enddo

! write(*,*) 'z(l)', ' r(500,500,l)',  ' N2(500,500,l)', ' u(500,500,l)', ' v(500,500,l)', ' uvz(500,500,l)', ' Rn(500,500,l)'

! do l=1,nl
!  write(*,*) z(l), r(500,500,l), N2(500,500,l), u(500,500,l), v(500,500,l), uvz(500,500,l), Rn(500,500,l)
! enddo

 call wbf3d(flnmo,idm,jdm,nl,Rn)

end
