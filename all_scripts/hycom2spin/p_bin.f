      program p_bin 
      implicit none

      integer i,j,it,jt,k,l,m,n,s,t,r,num
      real u,v,lon0,lon1,lat0,lat1,dt
      parameter (s = 8490234,t = 8490234,r = 10)

      real, dimension(r,s) :: floats
      real, allocatable :: sub(:,:)
      
      write(*,*) 'reading input file...'

      open(10, file='./floats_out_1stseeding_80days',
     & form='formatted')

      do i=1,t
       read(10,*) floats(:,i)

c      read(10,'(F4.0,F6.4,F2.0,F7.4,F6.4,F7.4,F6.2,F6.4,F6.4,F6.4)')
c     & floats(1,i),floats(2,i),floats(3,i),floats(4,i)
c     & ,floats(5,i),floats(6,i),floats(7,i),floats(8,i)
c     & ,floats(9,i),floats(10,i)
c      write(*,*) 'record: ', floats(1,i)
      if(mod(i,1000) == 0) then
      write(*,*) 'float ',i,':', floats(:,i)
      endif
      enddo
      close(10)

      write(*,*) 'reading input file...'
      write(*,*) 'Shape Input file:'
      write(*,*) shape(floats)

c determine and allocate the destination array
      write(*,*) 'allocationg sub array...'
      num = 0
      do j=1,t
      if(floats(1,j).ge.1.and.floats(1,j).le.5944) then
      num = num + 1
      write(*,*) floats(1,j)
      endif
      enddo
      write(*,*) num
      allocate(sub(r,num))
      write(*,*) shape(sub)

c fill array
      write(*,*) 'open sub array...'

       open(1, file='./floats_subset',
     & form='unformatted')

      write(*,*) 'filling sub array...'

      jt = 0

      do j=1,t
      if(floats(1,j).ge.1.and.floats(1,j).le.5944) then
      jt = jt +1
       do i=1,r
      sub(i,jt) = floats(i,j)
       enddo
      endif
      enddo

      write(*,*) 'Output file shape:'
      write(*,*) shape(sub)

      write(1) sub

      close(1)
      end
