module modrelax

implicit none

contains

subroutine tridiag(jmx,a,b,c,f)

! jmx = dimension of all the following arrays
! a   = sub lower diagonal
! b   = center diagonal
! c   = super upper diagonal
! f   = right hand side
! q   = work array

! a(1) and c(jmx) need to be initialized
! the output is in f; a, b, c, are unchanged

real*4     :: a(:), b(:), c(:), f(:), p
real*4     :: q(jmx)
integer*4  :: j,jmx

!a(1)   = 0
!c(jmx) = 0

! forward elimitaion sweep

q(1) = -c(1)/b(1)
f(1) =  f(1)/b(1)

do j = 2,jmx
 p    = 1.0/(b(j) + a(j)*q(j-1))
 q(j) = -c(j)*p
 f(j) = (f(j)-a(j)*f(j-1))*p
enddo
! backward pass

do j=jmx-1,1,-1
 f(j) = f(j)+q(j)*f(j+1)
enddo

return
end subroutine

  subroutine lineq_gausselim_dp(a,b)

    implicit none
    real*4,intent(inout) :: a(:,:),b(:)
    real*4 :: frac
    integer :: i,j
    integer :: n

    n = size(a,1)

    do i=1,n-1
       do j=i+1,n
          if(a(i,j).ne.0) then
             frac = a(i,j)/a(i,i)
             b(j) = b(j) - frac * b(i)
             a(i:,j) = a(i:,j) - frac * a(i:,i)
          endif
       enddo
    enddo

   write(*,*) 'one'

    do i=n,2,-1
       do j=i-1,1,-1
          if(a(i,j).ne.0) then
             frac = a(i,j)/a(i,i)
             b(j) = b(j) - frac * b(i)
             a(i:,j) = a(i:,j) - frac * a(i:,i)
          endif
       enddo
    enddo

   write(*,*) 'two'

    do i=1,n
       b(i) = b(i) / a(i,i)
    enddo

   write(*,*) 'done'

  end subroutine lineq_gausselim_dp

subroutine rhsJ(E,O,uscx,vscy,pscx,pscy,dz,ni,nf,Bf,G)
! O enter as vertical velocity and exits as RHS

integer*4             :: i,j,k,ni,nf,idm,jdm
real*4                :: E(:,:,:),O(:,:,:), G(:,:,:), Bf(:,:,:), dz(:)
real*4                :: uscx(:,:),pscx(:,:),vscy(:,:),pscy(:,:)
real*4                :: aa,bb,cc,A,B,C,D,X,Y,Z

idm = size(G,1)
jdm = size(G,2)

do i=2,idm-1
 do j=2,jdm-1
  do k=ni,nf
  X = 1.0/(uscx(i,j)*uscx(i+1,j)*pscx(i,j))
  Y = 1.0/(vscy(i,j)*vscy(i,j+1)*pscy(i,j))
  A = Bf(i,j,k)*uscx(i,j)*X
  B = Bf(i,j,k)*uscx(i+1,j)*X
  C = Bf(i,j,k)*vscy(i,j)*Y
  D = Bf(i,j,k)*vscy(i,j+1)*Y
  Z = 1.0/(dz(k)*dz(k+1)*(dz(k)+dz(k+1)))
  aa   = dz(k+1)*Z
  bb   = A+B+C+D-Z*(dz(k)+dz(k+1))
  cc   = dz(k)*Z

   E(i,j,k) = (A*O(i+1,j,k)+B*O(i-1,j,k)+C*O(i,j+1,k)+D*O(i,j-1,k) &
              -aa*O(i,j,k+1) -cc*O(i,j,k-1) -G(i,j,k))/bb

  enddo
 enddo
enddo

do i=2,idm-1
 do j=2,jdm-1
  do k=ni,nf

 if (abs(E(i,j,k)) .gt. 1) then
  E(i,j,k) = (E(i+1,j,k) + E(i-1,j,k) + E(i,j+1,k) + E(i,j-1,k) &
             + E(i,j,k+1) + E(i,j,k-1))/6
 endif

  enddo
 enddo
enddo

return
end subroutine

subroutine rhs(O,uscx,vscy,dz,Bf,G)
! O enter as vertical velocity and exits as RHS

integer*4             :: i,j,k,nl,idm,jdm
real*4                :: O(:,:,:), G(:,:,:), Bf(:,:,:)
real*4                :: uscx(:,:),vscy(:,:),dz(:)
real*4                :: A,B,C,X,Y,Z
real*4, allocatable   :: E(:,:)

idm = size(G,1)
jdm = size(G,2)
nl  = size(dz,1) ! size(G,3) - 1. No special treatment at the boundaries

allocate ( E(idm,jdm)) 

do k=1,nl

 if(k == 1) then
  Z = dz(k)*dz(k)
 else
  Z = dz(k)*dz(k-1)
 endif

 do i=2,idm-1
  do j=2,jdm-1
  X =  uscx(i,j)*uscx(i+1,j)
  Y =  vscy(i,j)*vscy(i,j+1)
  A = -Bf(i,j,k)*Z/X
  B = -Bf(i,j,k)*Z/Y
  C =  G(i,j,k)*Z
  E(i,j) = A*(O(i+1,j,k)+O(i-1,j,k)) + B*(O(i,j+1,k)+O(i,j-1,k)) + C
  enddo
 enddo

 ! BC

 E(1,:)   = E(2,:)
 E(idm,:) = E(idm-1,:)
 E(:,1)   = E(:,2)
 E(:,jdm) = E(:,jdm-1)
  
 O(:,:,k) = E(:,:)

enddo

deallocate ( E)

return
end subroutine

end module modrelax
