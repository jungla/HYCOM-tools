
      program advecBackward
!very high resolution runs of Zulema.

      implicit none
      include 'paramFsle.h'
      real land(n,m)
      real ttime,x0max,y0max,elaps
      integer jj,j,ii,i,it,l,lup,skip,iti,ipp,ktkt,l0
      character*40 flliap


c --- grid-spacing
      open(21,file='ini/dxdy.dat',status='old')
      do j=1,m
       read (21,*) jj,dx(j),dy(j)
       dx(j)=1000.*dx(j)  !convertion in meters
       dy(j)=1000.*dy(j)
      enddo !j
      print*,'dx(500),dy(500)=',dx(500),dy(500) 

c --- read land location
      open(22,file='ini/land.dat',status='old',form='unformatted')
      read (22) land

c --- fsle nomanclature
      flliap='fslb1.000'

c      do ktkt=18,18
      do ktkt=86,95

c      l0=day0+2*(ktkt-1)  !odd
c      l0=day0+1+2*(ktkt-1) !even
      l0=day0+ktkt-1

      print*,'------------------------------------------------'
      print*,'ktkt, l0= ',ktkt,l0
      print*,'------------------------------------------------'


c --- read launch positions
c      open(14,file='ini/traj.ini5067',
c      open(14,file='ini/traj.ini527553',
c      open(14,file='ini/trajA.ini527553',
      open(14,file='ini/traj.ini1055106',
c      open(14,file='ini/traj.ini1095105',
     .   status='old')
      do ipp=1,npar
       read (14,*) x0(ipp),y0(ipp)
       x0i(ipp)=x0(ipp)
       y0i(ipp)=y0(ipp)
      enddo !ipp
      close (14)
      print*,'npar=',npar      

c --- output file                        
c      open(15,file='traj.out',status='unknown',form='unformatted')

c --- FSLE-map parameters
      di=0.45*dy(525)
      df1=r1*di
      df2=r2*di
      df3=r3*di

      do i=1,n
      do j=1,m
       liap1(i,j)=0.
       tau1(i,j)=0.
       liap2(i,j)=0.
       tau2(i,j)=0.
       liap3(i,j)=0.
       tau3(i,j)=0.
      enddo !j
      enddo !i

c --- time interpolation
      iti=nint(thycom/dt)
      if (iti.le.1) stop
      skip=nint(thycom/thycom0)
      print*,'thycom,dt = (sec) ',thycom,dt
      print*,'thycom,dt = (hours) ',thycom/3600.,dt/3600.
      print*,'iti=',iti
      ttime=24*float(day0)
c      ttime=24*float(day0-1)
      print*,'ttime initial (day)=',ttime/24
      
c      write (15) ttime,x0(ipp),y0(ipp)


c --- model-output loop
      print*,'indTr1,indTr2,indTr3=',indTr1,indTr2,indTr3
c      do l=day0,day0+lmt-1
c      do l=day0-1,day0-lmt,-1
      do l=l0-1,l0-lmt,-1
       print*,'---------------------------------------------------'
       lup=l+1
       print*,'lup=',lup
       if (lup.le.indTr1) then
        call read_u(lup,u1)
        call read_v(lup,v1)
       else if (lup.le.indTr2) then
        call read2_u(lup,u1)
        call read2_v(lup,v1)
       else if (lup.le.indTr3) then
        call read3_u(lup,u1)
        call read3_v(lup,v1)
       else 
        call read4_u(lup,u1)
        call read4_v(lup,v1)
       endif
       print*,'..u1,v1 read'
       if (lup.eq.day0) write (30) u1
       print*,'u1(500,400),u1(200,500)=',u1(500,400),u1(200,500)
       call zeroTheLand(u1,v1)
       print*,'u1(500,400),u1(200,500)=',u1(500,400),u1(200,500)

       !lup=l+1
       if (l.le.indTr1) then
        call read_u(l,u2)
        call read_v(l,v2)
       else if (l.le.indTr2) then
        call read2_u(l,u2)
        call read2_v(l,v2)
       else if (l.le.indTr3) then
        call read3_u(l,u2)
        call read3_v(l,v2)
       else
        call read4_u(l,u2)
        call read4_v(l,v2)
       endif
       print*,'..u2,v2 read'
       call zeroTheLand(u2,v2)
       print*,'l,lup=',l,lup
       print*,'u2(500,400),u2(200,500)=',u2(500,400),u2(200,500)
c       write (30+l) u1,v1


c --- time-interpolation loop
       do it=1,iti

c        ttime=ttime+dt/3600.
        ttime=ttime-dt/3600.
        !print*,'ttime=',ttime,'          day=',int(ttime/24.)
        print*,'ttime (day)=',ttime/24.
c        elaps=ttime/24-day0
        elaps=day0-ttime/24.
        print*,'ELAPSED TIME (days)=',elaps

c --- particles ipp loop 
c        x0max=-1000
c        y0max=-1000
        do ipp=1,npar

         ii=nint(x0(ipp))
         jj=nint(y0(ipp))
         if (x0(ipp).lt.5.0.or.x0(ipp).gt.(real(n)-5).or.
     .         y0(ipp).lt.5.0.or.y0(ipp).gt.(real(m)-5.0)
     .         .or.land(ii,jj).gt.4) then
          x0(ipp)=9999.
          y0(ipp)=9999.
         else
          CALL EULER(n,m,X0(ipp),Y0(ipp),u1,v1,u2,v2,IT,ITI,DT,dx,dy)
c          CALL RK4(n,m,X0(ipp),Y0(ipp),u1,v1,u2,v2,IT,ITI,DT,dx,dy)
         endif
         ii=nint(x0(ipp))
         jj=nint(y0(ipp))
         if (x0(ipp).lt.5.0.or.x0(ipp).gt.(real(n)-5).or.
     .         y0(ipp).lt.5.0.or.y0(ipp).gt.(real(m)-5.0)
     .         .or.land(ii,jj).gt.4) then
          x0(ipp)=9999.
          y0(ipp)=9999.
         endif
c         if (ipp.eq.3) write (17,*) ttime,x0(ipp),y0(ipp)
c         if (mod(ipp,2000).eq.0) print *,'ipp =',ipp
         if (mod(ipp,200000).eq.0) print *,'ipp =',ipp
    
c         if (mod(ttime,12).eq.0) then
c          write (15) ttime,x0(ipp),y0(ipp) 
c         endif
c         write (17,*) ttime,ipp,x0(ipp),y0(ipp)

         if (mod(ipp,3).eq.0) then
          !write (31,*) ipp,x0i(ipp),y0i(ipp)
          xM1=x0(ipp-2)
          yM1=y0(ipp-2)
          ii=x0i(ipp-2)
          jj=y0i(ipp-2)
          !write (31,*) ii,jj
          do ipk=ipp-1,ipp
           xM2=x0(ipk)
           yM2=y0(ipk)
           if (xM1.eq.9999..or.xM2.eq.9999.) then
            dr2=0.
           else
            call distance(m,xM1,yM1,xM2,yM2,dr2,dx,dy)
            !write (31,*) sqrt(dr2)
            if (dr2.ge.df1**2.and.tau1(ii,jj).eq.0.) then
             tau1(ii,jj)=elaps*24.  !in hrs
             !ipcount=ipcount+1
            endif
            if (dr2.ge.df2**2.and.tau2(ii,jj).eq.0.) then
             tau2(ii,jj)=elaps*24.  !in hrs
            endif
            if (dr2.ge.df3**2.and.tau3(ii,jj).eq.0.) then
             tau3(ii,jj)=elaps*24.  !in hrs
            endif
           endif
          enddo !ipk
         endif

c         if (x0(ipp).ne.9999.) x0max=max(x0max,x0(ipp))
c         if (y0(ipp).ne.9999.) y0max=max(y0max,y0(ipp))
        enddo !ipp
c        print*,'x0max,y0max=',x0max,y0max

       enddo !it

      enddo !l

      do i=1,n
      do j=1,m
       if (tau1(i,j).eq.0.) then
        liap1(i,j)=0.
       else
        liap1(i,j)=log(r1)/tau1(i,j) !hr^{-1}
       endif
       if (tau2(i,j).eq.0.) then
        liap2(i,j)=0.
       else
        liap2(i,j)=log(r2)/tau2(i,j) !hr^{-1}
       endif
       if (tau3(i,j).eq.0.) then
        liap3(i,j)=0.
       else
        liap3(i,j)=log(r3)/tau3(i,j) !hr^{-1}
       endif
      enddo !j
      enddo !i
      write(flliap(7:9),'(i3.3)')l0
      flliap(5:5)='1'
      print*,'flliap=',flliap
      open(32,file=flliap,status='unknown',form='unformatted')
      write (32) liap1
      close(32)
      flliap(5:5)='2'
      open(33,file=flliap,status='unknown',form='unformatted')
      write (33) liap2
      close(33)
      flliap(5:5)='3'
      open(34,file=flliap,status='unknown',form='unformatted')
      write (34) liap3
      close(34)

      enddo !ktkt

      end

c-------------------------------------------
      SUBROUTINE EULER(n,m,X0,Y0,u1,v1,u2,v2,IT,
     .                 ITI,DT,dx,dy)
!
      integer n,m
      real u1(n,m),u2(n,m),v1(n,m),v2(n,m),dx(m),dy(m)
      REAL Uhor(n,m),Vhor(n,m)
      REAL X,PSU,XOUT,XT
      REAL Y,PSV,YOUT,YT

! weight for the linear time interpolation
        at1=FLOAT(IT-1)/FLOAT(ITI)
        at2=FLOAT(ITI-(IT-1))/FLOAT(ITI)
c        print*,'at1,at2  :',at1,at2

c        DO J=1,m
c        DO I=1,n
        do j=int(y0)-4,int(y0)+4
        do i=int(X0)-4,int(x0)+4
          Uhor(i,j)=(U1(i,j)*at2+U2(i,j)*at1)/dx(j)
          Vhor(i,j)=(V1(i,j)*at2+V2(i,j)*at1)/dy(j)
c          print*,'i,j,uhor(i,j)=',i,j,uhor(i,j)
        ENDDO
        ENDDO
c        write (21) uhor

      CALL INTERP(x0,y0,Uhor,PSU,2)
      CALL INTERP(X0,Y0,Vhor,PSV,3)
c      print*,'y0,int(y0)=',y0,int(y0)

!X1=X0+ U1 DT
      X0=X0+DT*PSU
      Y0=Y0+DT*PSV
c      print*,'x0,y0= ',x0,y0
c      print*,'psu,psv=',psu,psv

      RETURN
      END

c-------------------------------------------
      SUBROUTINE RK4(n,m,X0,Y0,u1,v1,u2,v2,IT,
     .                 ITI,DT,dx,dy)
!    
      integer n,m
      real    u1(n,m),u2(n,m),v1(n,m),v2(n,m),dx(m),dy(m)
      REAL Uhor1(n,m),Vhor1(n,m),Uhor2(n,m),Vhor2(n,m)
      REAL Uhor(n,m),Vhor(n,m), Uhop(n,m),Vhop(n,m)
      REAL Uhoi(n,m),Vhoi(n,m)
      REAL X,PSU,XOUT,XT,DXT,DXM,DXT1,DXT2,DYT1,DYT2
      REAL Y,PSV,YOUT,YT,DYT,DYM,DXM1,DXM2,DYM1,DYM2
      REAL m2deg,PI,RayT,H2,H6
      REAL W1D1(KMT),W1D2(KMT),W1D(KMT),W1Dp(KMT),W1Di(KMT)
      LOGICAL VERT_OUI
c      real x0,y0

        H2=DT/2.
        H6=DT/6.
        
! *******
! Compute the weight for the linear time interpolation
! *******
        at1=FLOAT(IT-1)/FLOAT(ITI)
        at2=FLOAT(ITI-(IT-1))/FLOAT(ITI)
! *******
! TIME+DT
! *******
        at3=at1+1./FLOAT(ITI)
        at4=at2-1./FLOAT(ITI)
! *******
! TIME+DT/2
! *******
        at5=at1+0.5/FLOAT(ITI)
        at6=at2-0.5/FLOAT(ITI)
        
c        WRITE(*,*) 'time coef=', at1,at2,at3,at4,at5,at6

        do j=int(y0)-4,int(y0)+4
        do i=int(X0)-4,int(x0)+4
          Uhor(i,j)=(U1(i,j)*at2+U2(i,j)*at1)/dx(j)
          Vhor(i,j)=(V1(i,j)*at2+V2(i,j)*at1)/dy(j)
          Uhop(i,j)=(U1(i,j)*at4+U2(i,j)*at3)/dx(j)
          Vhop(i,j)=(V1(i,j)*at4+V2(i,j)*at3)/dy(j)
          Uhoi(i,j)=(U1(i,j)*at6+U2(i,j)*at5)/dx(j)
          Vhoi(i,j)=(V1(i,j)*at6+V2(i,j)*at5)/dy(j)
        ENDDO
        ENDDO
!
! Interpolation horizontale
! -------------------------
! U1=U(x0,t0)
      CALL INTERP(X0,Y0,Uhor,PSU,2)
      CALL INTERP(X0,Y0,Vhor,PSV,3)

!X1=X0+0.5 U1 DT
      XT=X0+H2*PSU
      YT=Y0+H2*PSV

! U2=U(x1,t0+DT/2)
      CALL INTERP(XT,YT,Uhoi,DXT,2)
      CALL INTERP(XT,YT,Vhoi,DYT,3)
!X2=X0+0.5 U1 DT
      XT=X0+H2*DXT
      YT=Y0+H2*DYT
! U3=U(x2,t0+DT/2)
      CALL INTERP(XT,YT,Uhoi,DXM,2)
      CALL INTERP(XT,YT,Vhoi,DYM,3)
!X3=X0+ U3 DT
      XT=X0+DXM*DT
      YT=Y0+DYM*DT
      DXM=DXT+DXM
      DYM=DYT+DYM
! U4=U(x3,t1)
      CALL INTERP(XT,YT,Uhop,DXT,2)
      CALL INTERP(XT,YT,Vhop,DYT,3)
!X4=X0+ (u1+2U2+2U3+U4) dt
      X0=X0+(PSU+2.*DXM+DXT)*H6
      Y0=Y0+(PSV+2.*DYM+DYT)*H6
c      print*,'x0,y0=',x0,y0
c      print*,'psv,dym,dyt=',psv,dym,dyt

      RETURN
      END
c-------------------------------------------
      subroutine zeroTheLand(u,v)

      include 'paramFsle.h'

      do i=1,n
       do j=1,m
        if (u(i,j).gt.4.) then  !we are on land
         u(i,j)=0.
         v(i,j)=0.
        endif
       enddo !j
      enddo !i      
      return
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
c        flnmu='u51-61z.dat'
         flnmu='uv/u51-80.dat'
c        flnmu='u81-110.dat'
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
c        flnmu='u51-61z.dat'
c         flnmu='u51-80.dat'
        flnmu='uv/u81-110.dat'
        open(343,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no2 open'
        irec=0
      endif
c
c  read fields to output file.
c      irec=itime
      irec=itime-indTr1
      print*,'itime,new irec=',itime,irec
      read(343,rec=irec) u
      print*,'irec of u=',irec
      return
      end
c-------------------------------------------
      subroutine read3_u(itime,u)

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
c        flnmu='u51-61z.dat'
c        flnmu='u51-80.dat'
c        flnmu='u81-110.dat'
        flnmu='uv/u111-140.dat'
        open(353,file=flnmu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'ufields no3 open'
        irec=0
      endif
c
c  read fields to output file.
c      irec=itime
      irec=itime-indTr2
      print*,'itime,new irec=',itime,irec
      read(353,rec=irec) u
      print*,'irec of u=',irec
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
c        flnmu='u51-61z.dat'
c        flnmu='u51-80.dat'
c        flnmu='u81-110.dat'
c        flnmu='u111-140.dat'
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

      subroutine read_v(itime,v)

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
c        flnmv='v51-61z.dat'
        flnmv='uv/v51-80.dat'
c        flnmv='v81-110.dat'
        open(334,file=flnmv,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        write(*,*) 'vfields no1 open'
        irec=0
      endif
c
c  read fields to output file.
      irec=itime-50
      read(334,rec=irec) v
      print*,'irec of v=',irec
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
c        flnmv='v51-61z.dat'
c        flnmv='v51-80.dat'
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
c-----------------------------------------------
      subroutine read3_v(itime,v)

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
c        flnmv='v51-61z.dat'
c        flnmv='v51-80.dat'
c        flnmv='v81-110.dat'
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
c-----------------------------------------------
      subroutine read4_v(itime,v)

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
c        flnmv='v51-61z.dat'
c        flnmv='v51-80.dat'
c        flnmv='v81-110.dat'
c        flnmv='v111-140.dat'
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

c----------------------------------------------------------------
      subroutine distance(m,xM1,yM1,xM2,yM2,dist2,dx,dy)

      integer m
      real dx(m),dy(m)
      real base1,base2,z2,deltayM,xt,yt !,xM1,yM1,xM2,yM2,dist2
      integer j1,j2,i1,i2,jt

      j1=int(yM1)
      j2=int(yM2)
      if (j2.lt.j1) then
       xt=xM2
       xM2=xM1
       xM1=xt
       yt=yM2
       yM2=yM1
       yM1=yt
      endif
      i1=int(xM1)
      i2=int(xM2)
      j1=int(yM1)
      j2=int(yM2)
      base1=(xM2-xM1)*dx(j1)
      base2=(xM2-xM1)*dx(j2)


      if (i1.eq.i2.and.j1.eq.j2) then
       dist2 = (dx(j1)*(xM2-xM1))**2 + (dy(j1)*(yM2-yM1))**2
      else if (j1.eq.j2) then
       dist2 = base1**2+(dy(j1)*(yM2-yM1))**2
      else
       deltayM=0.
       if (j1+1.lt.j2) then
        do j=j1+1,j2-1
         deltayM = deltayM + dy(j)
        enddo !j
       endif
       deltayM = deltayM + (j1+1-yM1)*dy(j1) + (yM2-j2)*dy(j2)
        dist2 = deltayM**2+base1*base2
      endif


      return
      end
c ===========================================================================
      SUBROUTINE INTERP(xp,yp,u,uu,nu)
!
!
      include 'paramFsle.h'

      PARAMETER(ll=4)

      REAL xp,yp,uu
      REAL x1(ll),y1(ll),ub(ll,ll)
!
!     FIRST: FIND SURROUNDING U,V POINTS
!
      nx = int(xp)
      ny = int(yp)
      d1 = xp - real(nx)
      d2 = yp - real(ny)

c nu=0 for central
      if (nu.eq.0) then
        nfx = nx
        nfy = ny
        ddx = d1
        ddy = d2
      endif

c nu=2 for u
      if (nu.eq.2) then
        if (d1.le.0.5) then
           nfx = nx
           ddx = d1 + 0.5
        else
           nfx = nx + 1
           ddx = d1 - 0.5
        endif
        nfy = ny
        ddy = d2
      endif
c nu=3 for v
      if (nu.eq.3) then
        if (d2.le.0.5) then
          nfy = ny
          ddy = d2 + 0.5
        else
          nfy = ny + 1
          ddy = d2 - 0.5
        endif
        nfx = nx
        ddx = d1
      endif

      if (nu.lt.4) then
       do in=1,ll
        x1(in) = real(nfx+(in-ll/2))
        y1(in) = real(nfy+(in-ll/2))
        do im=1,ll
          ub(in,im) = u((nfx+(in-ll/2)),(nfy+(im-ll/2)))
        enddo
       enddo
      endif

c polynomial interpolation (from numerical recipes)
        call polin2(x1,y1,ub,ll,ll,real(nfx)+ddx,real(nfy)+ddy,uu,err)

      RETURN
      END

!
      SUBROUTINE POLIN2(X1A,X2A,YA,M,N,X1,X2,Y,DY)
!       from "numerical recipes"
      PARAMETER (NMAX=20,MMAX=20)
      DIMENSION X1A(M),X2A(N),YA(M,N),YNTMP(NMAX),YMTMP(MMAX)
      DO 120 J=1,M
        DO 121 K=1,N
          YNTMP(K)=YA(J,K)
121      CONTINUE
        CALL POLINT(X2A,YNTMP,N,X2,YMTMP(J),DY)
120    CONTINUE
      CALL POLINT(X1A,YMTMP,M,X1,Y,DY)
      RETURN
      END
! ________________________________________________________________________
!
      SUBROUTINE POLINT(XA,YA,N,X,Y,DY)
!       from "numerical recipes"
      PARAMETER (NMAX=10)
      DIMENSION XA(N),YA(N),C(NMAX),D(NMAX)
      NS=1
      DIF=ABS(X-XA(1))
      DO 11 I=1,N
        DIFT=ABS(X-XA(I))
        IF (DIFT.LT.DIF) THEN
          NS=I
          DIF=DIFT
        ENDIF
        C(I)=YA(I)
        D(I)=YA(I)
11    CONTINUE
      Y=YA(NS)
      NS=NS-1
      DO 13 M=1,N-1
        DO 12 I=1,N-M
          HO=XA(I)-X
          HP=XA(I+M)-X
          W=C(I+1)-D(I)
          DEN=HO-HP
          IF(DEN.EQ.0.)PAUSE
          DEN=W/DEN
          D(I)=HP*DEN 
          C(I)=HO*DEN
12      CONTINUE
        IF (2*NS.LT.N-M)THEN
          DY=C(NS+1)
        ELSE
          DY=D(NS)
          NS=NS-1
        ENDIF
        Y=Y+DY
13    CONTINUE
      RETURN
      END
! ___________________________________________________________________________

