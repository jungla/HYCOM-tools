      program p_read 
      implicit none

      integer i,j,k,l,m,n,s,t,r
      real u,v,lon0,lon1,lat0,lat1,dt
      parameter (s = 4986806,t = 33117,r = 10)

      real, dimension(r,t) :: floats
 
      open(1, file='./sorted_temp',
     & form='unformatted') !,
c     & access='direct',
c     & recl=4*r*s)


c      do j = 1, t
       read (1) floats
c         read (1,rec=j) (floats(i,j), i=1,r)
c      end do

      do j = 1,t
C      do i = 1,r

      if(mod(j,10)==0) then
         write(*,*) floats(:,j)
      endif

C      enddo
c         write(*,*) '****************'
      enddo

      close(1)
      end

