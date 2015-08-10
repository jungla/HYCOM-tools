
      program Lanczos1
c Lancsos filter 
c G ~ sinC(kc*delta)*sinC(kc*delta/a)
c here, a=1*lambdac/2

      implicit none
      include 'paramFsle.h'
c      parameter(n=1573,m=1073) 
      parameter(itmax=24*2*31)
      parameter (pi=3.14159)
      real uf(n,m)
      real pi,lambdac,delta,deltac,kc,gnorm,G,a
      integer i,j,it,itmax,dayi,dayf,itcount,
     .        countit,idif,i0,j0,nrecl,
     .        l,jj,irec,lfo

      lambdac=40. !50. !20. !km
      deltac=lambdac/2.
      kc=2*pi/lambdac
      idif=int(pi*delta)*2
      a=1.*lambdac/2.

      print*,'lambdac (km) = ',lambdac

      open(11,file='ini/dxdy.dat',status='old')
      do j=1,m
       read (11,*) jj,dx(j),dy(j)
      enddo !j
      print*,'dx(300),dx(450),dx(600)=',dx(300),dx(450),dx(600)
      print*,'dy(300),dy(450),dy(600)=',dy(300),dy(450),dy(600)


      nrecl=n*m*4

      open(20,file='uLP.dat',form='unformatted',access='direct',
     .        recl=nrecl,status='unknown',convert='big_endian')


c      do l=51,51+2*30-1
      do l=indTr1+1,indTr2
c      do l=indTr2+1,indTr3
c      do l=indTr3+1,indTr3+2*60-2
       print*,'l=',l

       if (l.le.indTr1) then
c        call read_u(l,u)
        call read_v(l,u)
       else if (l.le.indTr2) then
c        call read2_u(l,u)
        call read2_v(l,u)
       else if (l.le.indTr3) then
c        call read3_u(l,u)
        call read3_v(l,u)
       else
c        call read4_u(l,u)
        call read4_v(l,u)
       endif
       print*,'u(500,400),u(200,500)=',u(500,400),u(200,500)
c       write (14) u

       countit=0
       do i0=1,n
       do j0=1,760 !m
c       do i0=400,800
c       do j0=300,600
        if (u(i0,j0).gt.4) go to 31
        gnorm=0.
        uf(i0,j0)=0.
        idif=int(1*lambdac/(2*dx(j0)))+1
        do i=max(1,i0-idif),min(i0+idif,n)
        do j=max(1,j0-idif),min(j0+idif,m)
         if (i.eq.i0.and.j.eq.j0) then
          G=1.
         else
          delta=float((i-i0)**2*dx(j)**2+(j-j0)**2*dy(j)**2)
          delta=sqrt(delta)
          G=sin(kc*delta)/(kc*delta)
          G=G*sin(kc*delta/a)/(kc*delta/a) !Lanczos contribution
          !if (G.lt.0) G=0. !G=abs(G)
c          write (22,*) delta,G
         endif
         if (u(i,j).lt.4) then
          uf(i0,j0)=uf(i0,j0)+u(i,j)*G
          gnorm=gnorm+G
          !gnorm=gnorm+abs(G)
         endif
        enddo !j
        enddo !i 
        if (gnorm.ne.0) then
         uf(i0,j0)=uf(i0,j0)/gnorm
        endif
31      countit=countit+1
        if (mod(countit,500000).eq.0) print*,'iterations=',countit
       enddo !j0
       enddo !i0
     
c       lfo=l-50
       lfo=l-indTr1
       write(20,rec=lfo) uf
       print*,'l,avg rec = ',l,lfo
       print*,'---------------------------------'
         
      enddo !l
c      write (15) uf
      



      end

c-------------------------------------------
      subroutine read_u(itime,u)
      
      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)
      
c  declare local temporary variables.
      integer nrecl
c     
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmu
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
         flnmu='uv/u51-80.dat'
        open(333,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no1 open'
        irec=0
      endif
c
c  read fields to output file.
      irec=itime-50
      read(333,rec=irec) u
      print*,'irec of u=',irec
      return
      end
c-------------------------------------------
      subroutine read_v(itime,u)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)

c  declare local temporary variables.
      integer nrecl
c     
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmu
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
         flnmu='uv/v51-80.dat'
        open(334,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no1 open'
        irec=0
      endif
c
c  read fields to output file.
      irec=itime-50
      read(334,rec=irec) u
      print*,'irec of u=',irec
      return
      end
c-------------------------------------------
      subroutine read2_u(itime,u)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)

c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmu
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
        flnmu='uv/u81-110.dat'
        open(343,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no2 open'
        irec=0
      endif
c
c  read fields to output file.
      irec=itime-indTr1
      print*,'itime,new irec=',itime,irec
      read(343,rec=irec) u
      print*,'irec of u=',irec
      return
      end
c-----------------------------------------------
      subroutine read2_v(itime,v)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)

c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmv
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
        flnmv='uv/v81-110.dat'
        open(344,file=flnmv,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'vfields no2 open'
        irec=0
      endif
c
c  read fields to output file.
c      irec=itime
      irec=itime-indTr1
      read(344,rec=irec) v
      print*,'irec of v=',irec
      return
      end
c-------------------------------------------
      subroutine read3_u(itime,u)
        
      include 'paramFsle.h'

      
c  declare local temporary variables.
      integer nrecl
c     
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmu
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
        flnmu='uv/u111-140.dat'
        open(353,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no3 open'
        irec=0
      endif
c       
c  read fields to output file.
      irec=itime-indTr2
      print*,'itime,new irec=',itime,irec
      read(353,rec=irec) u
      print*,'irec of u=',irec
      return
      end
c-----------------------------------------------
      subroutine read3_v(itime,v)

      include 'paramFsle.h'


c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmv
c     
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
        flnmv='uv/v111-140.dat'
        open(354,file=flnmv,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'vfields no3 open'
        irec=0
      endif
c     
c  read fields to output file.
c      irec=itime
      irec=itime-indTr2
      read(354,rec=irec) v
      print*,'irec of v=',irec
      return
      end
c-------------------------------------------
      subroutine read4_u(itime,u)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)

c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmu
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
        flnmu='uv/u141-170.dat'
        open(363,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no4 open'
        irec=0
      endif
c
c  read fields to output file.
c      irec=itime
      irec=itime-indTr3
      print*,'itime,new irec=',itime,irec
      read(363,rec=irec) u
      print*,'irec of u=',irec
      return
      end
c-------------------------------------------
      subroutine read4_v(itime,v)

      include 'paramFsle.h'

      
c  declare local temporary variables.
      integer nrecl
c     
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmv
c     
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=n*m*4
        flnmv='uv/v141-170.dat'
        open(364,file=flnmv,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'vfields no4 open'
        irec=0 
      endif
c       
c  read fields to output file.
c      irec=itime
      irec=itime-indTr3
      read(364,rec=irec) v
      print*,'irec of v=',irec
      return 
      end
