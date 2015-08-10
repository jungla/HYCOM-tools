
      program advecBackwardFsle

      include 'paramFsle.h'
      real x0(npar),y0(npar),x0i(npar),y0i(npar)
      integer ii,iti,l,ipp,lup,skip,l0,no,countAll
      real vel(n,m)
      real ttime
      logical xin,yin
      character*30 fltraj
      character*40 flliap







      open(21,file='ini/dxdy800x500.dat',status='old',
     .                                   form='unformatted')
      read (21) dx,dy
      do i=1,n
      do j=1,m
       dx(i,j)=dx(i,j)*1000.
       dy(i,j)=dy(i,j)*1000.
      enddo !j
      enddo !i
      print*,'dx(400,250),dy(400,250)=',dx(400,250),dy(400,250)

      do j=1,m
       dx1(j)=dx(400,j)
       dy1(j)=dy(400,j)
      enddo !j
      

c      stop

      open(12,file='depth800x500.dat',status='old',form='unformatted')
      read (12) depth
      print*,'depth read'

c --- FSLE-map parameters
      di=0.45*dy(400,250)
      df1=r1*di
      df2=r2*di
      df3=r3*di

      flliap='fslb1.000'

c----  trajs nomanclature
c      fltraj='trajb.001'
c      fltraj='/hafiza/trajb.001'
c      no=8
      
      do ktkt=1,1

       l0=day0+1*(ktkt-1)
       print*,'ktkt,l0=',ktkt,l0

c       write(fltraj(7:9),'(i3.3)')ktkt
c       write(fltraj(7+no:9+no),'(i3.3)')ktkt
c       print*,'fltraj= ',fltraj

c      stop 

c --- read launch positions
      open(14,file='ini/traj.ini100992',
     .                status='old')
      do ipp=1,npar
       read(14,*) x0(ipp),y0(ipp)
       x0i(ipp)=x0(ipp)
       y0i(ipp)=y0(ipp)
      enddo !ipp
      close(14)
      write (17,*) 0.,x0i(1),y0i(1)
      print*,'npar=',npar

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

c      stop

c --- output file
c      open(15,file='traj.out',
c      open(15,file=fltraj,
c     .          status='unknown',form='unformatted')

c --- time interpolation
      iti=nint(tmicom/dt)
      if (iti.le.1) stop
      skip=nint(tmicom/tmicom0)
      print*,'tmicom,dt = (sec) ',tmicom,dt
      print*,'tmicom,dt = (hours) ',tmicom/3600.,dt/3600.
      print*,'iti=',iti
c      ttime=float(day0)
      ttime=24*float(day0-1)
      print*,'ttime=',ttime


c --- model-output loop
       do l=l0-1,max(l0-lmt,32),-skip
       print*,'-------------------------------------------------------'


c --- read micom fields and change axes
c      lup=min(l+skip,day0-1+lmt) doesn't work after ktkt=10
      lup=l+skip
      print*,'l+skip, day0-1+lmt: ',l+skip,day0-1+lmt
      if (lup.le.dayTr1) then
       call read_uv(lup,u1,v1)
      else if (lup.le.dayTr2) then
       call read2_uv(lup,u1,v1)
      else if (lup.le.dayTr3) then
       call read3_uv(lup,u1,v1)
      else if (lup.le.dayTr4) then
       call read4_uv(lup,u1,v1)
      else
       call read5_uv(lup,u1,v1)
      endif
c
       print*,'..u1 read'


      if (l.le.dayTr1) then
       call read_uv(l,u2,v2)
      else if (l.le.dayTr2) then
       call read2_uv(l,u2,v2)
      else  if (l.le.dayTr3) then
       call read3_uv(l,u2,v2)
      else if (l.le.dayTr4) then
       call read4_uv(l,u2,v2)
      else
       call read5_uv(l,u2,v2)
      endif
c


      print*,'l,lup=',l,lup

    
c --- time-interpolation loop
      do it=1,iti   
       
c       ttime=ttime+dt/3600.
       ttime=ttime-dt/3600.
       print*,'ttime=',ttime,'		day=',int(ttime/24.)
       elaps=-(ttime/24-day0+1)
       print*,'ELAPSED TIME (days)=',elaps

c --- particles ipp loop 
      do ipp=1,npar
         xin=.false.
         yin=.false.
         if(X0(ipp).ge.5.0.and.X0(ipp).le.(real(n)-5.0))
     .     xin=.true.
         if(Y0(ipp).ge.5.0.and.Y0(ipp).le.(real(m)-5.0))
     .     yin=.true.
         if(.not.(xin.and.yin)) then
           X0(ipp) = 999.
           Y0(ipp) = 999.
         else
          ii=int(x0(ipp))
          jj=int(y0(ipp)) 
          CALL RK4(n,m,X0(ipp),Y0(ipp),u1,v1,u2,v2,IT,ITI,-DT,dx,dy)
         endif

         if (mod(ipp,50000).eq.0) print *,'ipp =',ipp

c...check if outside the domain
         if(X0(ipp).lt.5.0) X0(ipp)= 999.
         if(X0(ipp).gt.(real(n)-5.0)) X0(ipp)= 999.
         if(Y0(ipp).lt.5.0) Y0(ipp)= 999.
         if(Y0(ipp).gt.(real(m)-5.0)) Y0(ipp)= 999.


c         if (mod(ttime,24).eq.0) then
c         if (mod(ttime,12).eq.0) then
c          write (15) ttime,x0(ipp),y0(ipp)
c         endif

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
           if (xM1.eq.999..or.xM2.eq.999.) then
            dr2=0.
           else
            call distance(m,xM1,yM1,xM2,yM2,dr2,dx1,dy1)
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
        

      enddo !ipp
        write (17,*) ttime,x0(1),y0(1)

      enddo !it
     
      enddo !l
c      close(15)

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


      print*,'*************************************************'

      enddo !ktkt


      end


c**********************************************
      subroutine read_uv(itime,urd,vrd)
   
      include 'param2.h'

c  declare passed variables.
      real    a(n,m)

c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmuv
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=ird*jrd*4
c        flnmuv='/hafiza/micomEcmwf/uvJan83.dat'
c        flnmuv='/hafiza/micomEcmwf/uvJul83.dat'
        flnmuv='/hafiza/micomClim/uvJan06.dat'
c        flnmuv='/hafiza/micomClim/uvJul05.dat'
         open(333,file=flnmuv,form='unformatted',
     &       access='direct',recl=nrecl,convert="big_endian")
        write(*,*) 'uvfields no1 open'
        irec=0
      endif
c
c  read fields to output file.
      irec=1+(itime-1)*2
c      irec=1+(itime-182)*2 !July start
c      irec=1+(itime-183)*2 !July80 start
c      irec=1+(itime-181)*2 !JulyC start
c      irec=itime
      read(333,rec=irec) urd
      print*,'irec=',irec
      irec=irec+1
      read(333,rec=irec) vrd
      print*,'irec=',irec
      return
      end
c**********************************************
      subroutine read2_uv(itime,urd,vrd)
       
      include 'param2.h'
      
c  declare passed variables.
      real    a(n,m)
     
c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmuv
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=ird*jrd*4
c        flnmuv='/hafiza/micomEcmwf/uvFeb83.dat'
c        flnmuv='/hafiza/micomEcmwf/uvAug83.dat'
c        flnmuv='/hafiza/micomClim/uvFeb06.dat'
c        flnmuv='/hafiza/micomClim/uvAug05.dat'
c        flnmuv='/hafiza/hycom/gs/uvFeb04.dat'
        flnmuv='/hafiza/lilith//hafiza/hycom/gs/uvFeb04.dat'
c        flnmuv='/hafiza/hycom/gs/uvFeb04G5b.dat'
c        flnmuv='/hafiza/hycom/gs/uvFeb04LP20.dat'
         open(334,file=flnmuv,form='unformatted',
     &       access='direct',recl=nrecl,convert="big_endian")
        write(*,*) 'uvfields no2 open'
        irec=0
      endif
c
c  read fields to output file.
       irec=1+(itime-dayTr1-1)*2
c      irec=itime
      read(334,rec=irec) urd
      print*,'irec=',irec
      irec=irec+1
      read(334,rec=irec) vrd
      print*,'irec=',irec
      return
      end

c**********************************************
      subroutine read3_uv(itime,urd,vrd)
                                       
      include 'param2.h'
                                      
c  declare passed variables.
      real    a(n,m)
                                     
c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmuv
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=ird*jrd*4
c        flnmuv='/hafiza/micomEcmwf/uvMar83.dat'
c        flnmuv='/hafiza/micomEcmwf/uvSep83.dat'
c        flnmuv='/hafiza/micomClim/uvMar06.dat'
c        flnmuv='/hafiza/micomClim/uvSep05.dat'
c        flnmuv='/hafiza/hycom/gs/uvMar04.dat'
        flnmuv='/hafiza/lilith//hafiza/hycom/gs/uvMar04.dat'
c        flnmuv='/hafiza/hycom/gs/uvMar04G5b.dat'
c        flnmuv='/hafiza/hycom/gs/uvMar04LP20.dat'
         open(335,file=flnmuv,form='unformatted',
     &       access='direct',recl=nrecl,convert="big_endian")
        write(*,*) 'uvfields no3 open'
        irec=0
      endif
c
c  read fields to output file.
       irec=1+(itime-dayTr2-1)*2
c      irec=itime
      read(335,rec=irec) urd
      print*,'irec=',irec
      irec=irec+1
      read(335,rec=irec) vrd
      print*,'irec=',irec
      return
      end
                                       

c**********************************************
      subroutine read4_uv(itime,urd,vrd)
                                       
      include 'param2.h'
                                      
c  declare passed variables.
      real    a(n,m)
                                     
c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmuv
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=ird*jrd*4
c        flnmuv='/hafiza/micomEcmwf/uvApr83.dat'
c        flnmuv='/hafiza/micomEcmwf/uvOct83.dat'
c        flnmuv='/hafiza/micomClim/uvApr06.dat'
c        flnmuv='/hafiza/micomClim/uvOct05.dat'
c        flnmuv='/hafiza/hycom/gs/uvApr04.dat'
        flnmuv='/hafiza/lilith//hafiza/hycom/gs/uvApr04.dat'
c        flnmuv='/hafiza/hycom/gs/uvApr04G5b.dat'
c        flnmuv='/hafiza/hycom/gs/uvApr04LP20.dat'
         open(336,file=flnmuv,form='unformatted',
     &       access='direct',recl=nrecl,convert="big_endian")
        write(*,*) 'uvfields no4 open'
        irec=0
      endif
c
c  read fields to output file.
       irec=1+(itime-dayTr3-1)*2
c      irec=itime
      read(336,rec=irec) urd
      print*,'irec=',irec
      irec=irec+1
      read(336,rec=irec) vrd
      print*,'irec=',irec
      return
      end
c**********************************************
      subroutine read5_uv(itime,urd,vrd)
                     
      include 'param2.h'
                    
c  declare passed variables.
      real    a(n,m)
                   
c  declare local temporary variables.
      integer nrecl
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*50 flnmuv
c
c  open output file on 1st pass.
      data init/0/
      if (init .eq. 0) then
        init=1
        nrecl=ird*jrd*4
c        flnmuv='/hafiza/hycom/gs/uvMay04.dat'
        flnmuv='/hafiza/lilith/hafiza/hycom/gs/uvMay04.dat'
c        flnmuv='/hafiza/hycom/gs/uvMay04G5b.dat'
c        flnmuv='/hafiza/hycom/gs/uvMay04LP20.dat'
         open(337,file=flnmuv,form='unformatted',
     &       access='direct',recl=nrecl,convert="big_endian")
        write(*,*) 'uvfields no5 open'
        irec=0
      endif
c
c  read fields to output file.
       irec=1+(itime-dayTr4-1)*2
c      irec=itime
      read(337,rec=irec) urd
      print*,'irec=',irec
      irec=irec+1
      read(337,rec=irec) vrd
      print*,'irec=',irec
      return
      end



c*******************************************************************
      SUBROUTINE EULER(n,m,X0,Y0,u1,v1,u2,v2,IT,
     .                 ITI,DT,dx,dy)
!
      integer n,m
      real u1(n,m),u2(n,m),v1(n,m),v2(n,m),dx(n,m),dy(n,m)
      REAL Uhor(n,m),Vhor(n,m)
      REAL X,PSU,XOUT,XT
      REAL Y,PSV,YOUT,YT
                                                                
! weight for the linear time interpolation
        at1=FLOAT(IT-1)/FLOAT(ITI)
        at2=FLOAT(ITI-(IT-1))/FLOAT(ITI)
        print*,'at1,at2  :',at1,at2
                                                                 
c        DO J=1,m
c        DO I=1,n
        do j=int(y0)-4,int(y0)+4
        do i=int(X0)-4,int(x0)+4
          Uhor(i,j)=(U1(i,j)*at2+U2(i,j)*at1)/dx(i,j)
          Vhor(i,j)=(V1(i,j)*at2+V2(i,j)*at1)/dy(i,j)
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
                                                                     
C*********************************************************************
      SUBROUTINE RK4(n,m,X0,Y0,u1,v1,u2,v2,IT,
     .                 ITI,DT,dx,dy)
!
      integer n,m
      real    u1(n,m),u2(n,m),v1(n,m),v2(n,m),dx(n,m),dy(n,m)
      REAL Uhor1(n,m),Vhor1(n,m),Uhor2(n,m),Vhor2(n,m)
      REAL Uhor(n,m),Vhor(n,m), Uhop(n,m),Vhop(n,m)
      REAL Uhoi(n,m),Vhoi(n,m)
      REAL X,PSU,XOUT,XT,DXT,DXM,DXT1,DXT2,DYT1,DYT2
      REAL Y,PSV,YOUT,YT,DYT,DYM,DXM1,DXM2,DYM1,DYM2
      REAL m2deg,PI,RayT,H2,H6
      REAL W1D1(KMT),W1D2(KMT),W1D(KMT),W1Dp(KMT),W1Di(KMT)
      LOGICAL VERT_OUI

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

c        DO J=1,m
c        DO I=1,n
        do j=int(y0)-4,int(y0)+4
        do i=int(X0)-4,int(x0)+4
          Uhor(i,j)=(U1(i,j)*at2+U2(i,j)*at1)/dx(i,j)
          Vhor(i,j)=(V1(i,j)*at2+V2(i,j)*at1)/dy(i,j)
          Uhop(i,j)=(U1(i,j)*at4+U2(i,j)*at3)/dx(i,j)
          Vhop(i,j)=(V1(i,j)*at4+V2(i,j)*at3)/dy(i,j)
          Uhoi(i,j)=(U1(i,j)*at6+U2(i,j)*at5)/dx(i,j)
          Vhoi(i,j)=(V1(i,j)*at6+V2(i,j)*at5)/dy(i,j)
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


c ===========================================================================
      SUBROUTINE INTERP(xp,yp,u,uu,nu)
!
!
      include 'param2.h'

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
