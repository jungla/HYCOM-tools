      program p_vel 
      implicit none

      integer i,j,k,l,m,n,r,npad,nrec1
      real lat,lon,id,dt,vlon,vlat
      character*80 CLINE
      integer,parameter::imax=1573,jmax=1073,s=4986806,t=4986806
      real, dimension(10,t) :: floats

      npad=4096-mod(imax*jmax,4096)

      nrec1=4*(imax*jmax+npad)

      open(1, file='./floats_subset_quicksort',
     & form='unformatted')

      open(21, file='./regional.grid.a',
     & form='unformatted',access='direct', recl=4)

      read (1) floats

      READ(21,rec=1) j! skip idm
      READ(21,rec=2) k! skip jdm
      READ(21,rec=3) l! skip mapflg
      WRITE(6,*) j,k,l

 
      do i = t-100,t-1

      if (floats(2,i)>floats(2,i+1)) then
      id = floats(1,i)
      dt = floats(2,i)-floats(2,i+1)
      lon = floats(4,i)-floats(4,i+1)
      lat = floats(5,i)-floats(5,i+1)
      vlon = lon/dt
      vlat = lat/dt
      write(*,*) vlon,vlat
      endif

      enddo
       
      close(1)
      end
