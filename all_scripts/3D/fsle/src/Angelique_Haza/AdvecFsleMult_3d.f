
      program advecForward
!very high resolution runs of Zulema.

      implicit none
      include 'paramFsle.h'
      real land(n,m)
      real ttime,x0max,y0max,elaps
      integer jj,j,ii,i,it,l,lup,skip,iti,ipp,ktkt,l0,iout,ioutl
      character*40 flliap, flparx, flpary, flparz, flparin
      
      integer kk,k,nk,idxy
      real dx1(1073),dy1(1073)

c --- grid-spacing
      open(21,file='Ini/dxdy.dat',status='old')
      
      idxy=0
      do j=1,1073
       read (21,*) jj,dx1(j),dy1(j)
       dx1(j)=1000.*dx1(j)  !convertion in meters
       dy1(j)=1000.*dy1(j)
       
       if (j.ge.iyct-int(m/2).and.j.lt.iyct-int(m/2)+m) then
          idxy=idxy+1
          dx(idxy)=dx1(j)
          dy(idxy)=dy1(j)
c          print*, idxy, dy(idxy)
       endif

      enddo !j
      print*,'dx(middle),dy(middle)=',dx(int(m/2)),dy(int(m/2)) 

      dz=10.

c --------------

      if (iver.eq.1) then

       flliap='v_z_1.000_00'
       flparx='var_x00.out'
       flpary='var_y00.out'
       flparz='var_z00.out'

      else
       flliap='f_z_1.000_00'
       flparx='par_x00.out'
       flpary='par_y00.out'
       flparz='par_z00.out'
      endif
      
c      do ktkt=1,500,10

      l0=day1 ! iteration starting day 


c --- read launch positions

      flparin='Ini/traj270A.ini'
      write(flparin(9:11),'(i3.3)') day1
      flparin(12:12)=fcase(4:4)
      print*, flparin
                  

      if (iver.eq.1) then
         flparin(5:5)='v'
      endif

      open(14,file=flparin,status='old')

      do ipp=1,npar
       read (14,*) x0(ipp),y0(ipp),z0(ipp)
       x0i(ipp)=x0(ipp)
       y0i(ipp)=y0(ipp)
       z0i(ipp)=z0(ipp)
      enddo !ipp
      close(14)
      print*,'npar=',npar      

c --- output file                        
c      open(15,file='traj.out',status='unknown',form='unformatted')

c --- FSLE-map parameters
      di=0.45*dy(int(m/2))
      if (iver.eq.1) then
         di=0.45*dz
      endif
      df1=r1*di
      df2=r2*di
      df3=r3*di
    
      do i=1,n
      do j=1,m
      do k=1,lz
       liap1(i,j,k)=0.
       tau1(i,j,k)=0.
       liap2(i,j,k)=0.
       tau2(i,j,k)=0.
       liap3(i,j,k)=0.
       tau3(i,j,k)=0.
      enddo !j
      enddo !i
      enddo

c --- time interpolation
      iti=nint(thycom/dt)
      if (iti.le.1) stop
      skip=nint(thycom/thycom0)
      print*,'thycom,dt = (sec) ',thycom,dt
      print*,'thycom,dt = (hours) ',thycom/3600.,dt/3600.
      print*,'iti=',iti

      ttime=24*float(day1)

      print*,'ttime initial (day)=',ttime/24
      
c      write (15) ttime,x0(ipp),y0(ipp)


c --- model-output loop
      print*,'indTr1,indTr2,indTr3=',indTr1,indTr2,indTr3

      nk=0

      do l=l0,l0+lmt-1
       
       nk=nk+1
       print*,'---------------------------------------------------'
       print*,'l=',l
        
       call read_u(nk,u1)
       call read_v(nk,v1)
       call read_w(nk,w1)

       print*,'..u1,v1 read'

c       print*,'u1(500,400),u1(200,500)=',u1(500,400),u1(200,500)
       call zeroTheLand(u1,v1,w1)
       print*,'u1(500,400,50)',u1(190,160,50)

c       lup=l+1
       lup=nk+1

       call read_u(lup,u2)
       call read_v(lup,v2)
       call read_w(lup,w2)

       print*,'..u2,v2 read'
       call zeroTheLand(u2,v2,w2)
       print*,'l,lup=',l,lup
c       print*,'u2(500,400),u2(200,500)=',u2(500,400),u2(200,500)


       if (l.eq.l0) then
         open(45,file=flparx,status='unknown',form='unformatted')
         write (45) x0i
         close (45)
         open(46,file=flpary,status='unknown',form='unformatted')
         write (46) y0i
         close (46)
         open(47,file=flparz,status='unknown',form='unformatted')
         write (47) z0i
         close (47)
       endif


c --- time-interpolation loop
       do it=1,iti

        ttime=ttime+dt/3600.
        print*,'ttime (day)=',ttime/24.
        elaps=ttime/24-day1
        print*,'ELAPSED TIME (days)=',elaps

c --- particles ipp loop 
        x0max=-1000
        y0max=-1000

        do ipp=1,npar

         ii=nint(x0(ipp))
         jj=nint(y0(ipp))
         kk=nint(z0(ipp))

         if (x0(ipp).lt.5.0.or.x0(ipp).gt.(real(n)-5).or.
     &         y0(ipp).lt.5.0.or.y0(ipp).gt.(real(m)-5.0)
     &         .or.z0(ipp).lt.0.5.or.z0(ipp).gt.(real(lz)-4.0)
     &         .or.land(ii,jj).gt.4) then
          x0(ipp)=9999.
          y0(ipp)=9999.
          z0(ipp)=9999.
         else

          CALL EULER3(n,m,lz,X0(ipp),Y0(ipp),Z0(ipp),u1,v1,w1,
     &                u2,v2,w2,IT,ITI,DT,dx,dy,dz)
          
         endif

         ii=nint(x0(ipp))
         jj=nint(y0(ipp))
         kk=nint(z0(ipp))
         if (x0(ipp).lt.5.0.or.x0(ipp).gt.(real(n)-5).or.
     &         y0(ipp).lt.5.0.or.y0(ipp).gt.(real(m)-5.0)
     &         .or.z0(ipp).lt.0.5.or.z0(ipp).gt.(real(lz)-4.0)
     &         .or.land(ii,jj).gt.4) then
          x0(ipp)=9999.
          y0(ipp)=9999.
          z0(ipp)=9999.
         endif

         if (mod(ipp,200000).eq.0) print *,'ipp =',ipp, x0(ipp),z0(ipp)
    
         if (mod(ipp,3).eq.0) then

          xM1=x0(ipp-2)
          yM1=y0(ipp-2)
          zM1=z0(ipp-2)

          ii=x0i(ipp-2)
          jj=y0i(ipp-2)
          kk=z0i(ipp-2)
       
          do ipk=ipp-1,ipp
           xM2=x0(ipk)
           yM2=y0(ipk)
           zM2=z0(ipk)
           if (xM1.eq.9999..or.xM2.eq.9999.) then
            dr2=0.
           else

            if (iver.eq.1) then
              call distance3(m,xM1,yM1,zM1,xM1,yM1,zM2,dr2,dx,dy,dz)
            endif
            call distance3(m,xM1,yM1,zM1,xM2,yM2,zM2,dr2,dx,dy,dz)
             
            !write (31,*) sqrt(dr2)
            if (dr2.ge.df1**2.and.tau1(ii,jj,kk).eq.0.) then
             tau1(ii,jj,kk)=elaps*24.  !in hrs
             !ipcount=ipcount+1
            endif
            if (dr2.ge.df2**2.and.tau2(ii,jj,kk).eq.0.) then
             tau2(ii,jj,kk)=elaps*24.  !in hrs
            endif
            if (dr2.ge.df3**2.and.tau3(ii,jj,kk).eq.0.) then
             tau3(ii,jj,kk)=elaps*24.  !in hrs
            endif
           endif
          enddo !ipk
         endif



         if (x0(ipp).ne.9999.) x0max=max(x0max,x0(ipp))
         if (y0(ipp).ne.9999.) y0max=max(y0max,y0(ipp))

        enddo !ipp
        print*,'x0max,y0max=',x0max,y0max

       enddo !it

       if (iver.ne.1) then

       write(flparx(6:7),'(i2.2)')nk
       open(35,file=flparx,status='unknown',form='unformatted')
       write (35) x0
       close(35)
       write(flpary(6:7),'(i2.2)')nk
       open(36,file=flpary,status='unknown',form='unformatted')
       write (36) y0
       close(36)
       write(flparz(6:7),'(i2.2)')nk
       open(37,file=flparz,status='unknown',form='unformatted')
       write (37) z0
       close(37)
   
       endif


      enddo !l

CCCCCCCCCCCCCCCCCCCCC


      do i=1,n
      do j=1,m
      do k=1,lz
        if (tau1(i,j,k).eq.0.) then
         liap1(i,j,k)=0.
        else
         liap1(i,j,k)=log(r1)/tau1(i,j,k) !hr^{-1}
        endif
        if (tau2(i,j,k).eq.0.) then
         liap2(i,j,k)=0.
        else
         liap2(i,j,k)=log(r2)/tau2(i,j,k) !hr^{-1}
        endif
        if (tau3(i,j,k).eq.0.) then
         liap3(i,j,k)=0.
        else
         liap3(i,j,k)=log(r3)/tau3(i,j,k) !hr^{-1}
        endif
      enddo !j
      enddo !i
      enddo

c      iout=int((l0-day0))/2+day0
      iout=day1
      ioutl=lmt/2

      write(flliap(7:9),'(i3.3)')iout
      write(flliap(11:12),'(i2.2)')ioutl 
c      write(flliap(4:5),'(i2.2)')ktkt
c      print*,'liap1(500,400),(200,500)=',liap1(500,400),liap1(200,500)

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


c     enddo !ktkt

      end

c-------------------------------------------
      SUBROUTINE EULER3(n,m,lz,X0,Y0,Z0,u1,v1,w1,u2,v2,w2,
     &                 IT,ITI,DT,dx,dy,dz)
!
      integer n,m,lz
      real u1(n,m,lz),u2(n,m,lz),w1(n,m,lz),v1(n,m,lz),v2(n,m,lz),
     &      w2(n,m,lz),dx(m),dy(m),dz
      REAL Uhor(n,m,lz),Vhor(n,m,lz),Whor(n,m,lz)
      REAL PSU,PSV,PSW
      integer kl

! weight for the linear time interpolation
        at1=FLOAT(IT-1)/FLOAT(ITI)
        at2=FLOAT(ITI-(IT-1))/FLOAT(ITI)
c        print*,'at1,at2  :',at1,at2

        if (z0.ge.2.) then ! modified 5/16/12

          if (int(z0).le.4) then         
             kl=int(z0)-1
          else
             kl=4
          endif


c          print*, kl

          do k=int(z0)-kl,int(z0)+4
          do j=int(y0)-4,int(y0)+4
          do i=int(X0)-4,int(x0)+4
c             print*, 'k,j,i=',k,j,i
c             print*, 'u', u1(i,j,k),u2(i,j,k),dx(j)
            Uhor(i,j,k)=(U1(i,j,k)*at2+U2(i,j,k)*at1)/dx(j)
c              print*, 'uhor=', Uhor(i,j,k)
            Vhor(i,j,k)=(V1(i,j,k)*at2+V2(i,j,k)*at1)/dy(j)
c              print*, 'vhor=', vhor(i,j,k)
c              print*, 'w=', w1(i,j,k),w2(i,j,k)
            Whor(i,j,k)=(W1(i,j,k)*at2+W2(i,j,k)*at1)/dz
c              print*, 'whor',whor(i,j,k)
c              print*,'i,j,uhor(i,j)=',i,j,uhor(i,j)
         
          ENDDO
          ENDDO
          ENDDO
c          write (21) uhor
c          print*, i,j,k

         CALL INTERP3(x0,y0,Z0,Uhor,PSU,0)
         CALL INTERP3(X0,Y0,Z0,Vhor,PSV,0)
         CALL INTERP3(X0,Y0,Z0,Whor,PSW,0) ! U,V,W are all defined at the
c                                         center & bottom of the grid 
c         print*,'y0,int(y0)=',y0,int(y0)

      else
                
         do j=int(y0)-4,int(y0)+4
         do i=int(X0)-4,int(x0)+4

            Uhor(i,j,1)=(U1(i,j,1)*at2+U2(i,j,1)*at1)/dx(j)
            Vhor(i,j,1)=(V1(i,j,1)*at2+V2(i,j,1)*at1)/dy(j)
         
         ENDDO
         ENDDO
 
         do k=2,6            ! modified 5/16/12
            Uhor(i,j,k)=Uhor(i,j,1)  ! modified 5/16/12
            Vhor(i,j,k)=Vhor(i,j,1)  ! modified 5/16/12
         enddo   ! modified 5/16/12

        Z0=1.0
        CALL INTERP3(x0,y0,Z0,Uhor,PSU,0)
        CALL INTERP3(X0,Y0,Z0,Vhor,PSV,0)
        PSW=0.0

      endif

!X1=X0+ U1 DT
      X0=X0+DT*PSU
      Y0=Y0+DT*PSV
      Z0=Z0+DT*PSW
c      print*,'x0,y0= ',x0,y0
c      print*,'psu,psv=',psu,psv

      RETURN
      END


c-------------------------------------------
      subroutine zeroTheLand(u,v,w)

      include 'paramFsle.h'

      do i=1,n
       do j=1,m
       do k=1,lz
        if (u(i,j,k).gt.4.) then  !we are on land
         u(i,j,k)=0.
         v(i,j,k)=0.
         w(i,j,k)=0.
        endif
       enddo !j
      enddo !i
      enddo      
      return
      end
c-------------------------------------------
      subroutine read_u(nk,u)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(1573,1073)

c  declare local temporary variables.
      integer nrecl,izn,nk
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*61 fu

      integer day2, iday2
c
c  open output file on 1st pass.
c      data init/0/
c      if (init .eq. 0) then
c        init=1
        nrecl=n*m*4 
        print*, 'n,m=', n,m
        
c        flnmu='../vel_input/u_110_05_01.dat'
c        flnmu='../vel_input/u_110_05_01f.dat'
      fu='vel_in/high_res_3d/016_archv.0008_050_00_2m_A_3zu.A'


        day2=day1+int(real(nk-1)/2.)
        write(fu(35:37),'(i3.3)') day2
        write(fu(33:33),'(i1.1)') iyr

        if (mod(nk,2).eq.0) then
           iday2=12
        else
           iday2=0
        endif 
        write(fu(39:40),'(i2.2)') iday2
        fu(45:45)=fcase(4:4)

        print*, 'file=',fu
        open(333,file=fu,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')
        
        do irec=1,100
   
         read(333,rec=(irec-1)*5+1) u(:,:,irec)
        enddo

        print*,'u(100,100,1)',u(100,100,2)

        close(333)
      return
      end
c-------------------------------------------
 
c-------------------------------------------

      subroutine read_v(nk,v)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)

c  declare local temporary variables.
      integer nrecl,izn,nk
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*61 fv

      integer day2, iday2
c
c  open output file on 1st pass.
c      data init/0/
c      if (init .eq. 0) then
c        init=1
        nrecl=n*m*4

c        flnmv='../vel_input/v_110_05_01.dat'
c        flnmv='../vel_input/v_110_05_01f.dat'
      fv='vel_in/high_res_3d/016_archv.0008_050_00_2m_A_3zv.A'

        day2=day1+int(real(nk-1)/2.)
        write(fv(35:37),'(i3.3)') day2
        write(fv(33:33),'(i1.1)') iyr

        if (mod(nk,2).eq.0) then
           iday2=12
        else
           iday2=0
        endif 
        write(fv(39:40),'(i2.2)') iday2
        fv(45:45)=fcase(4:4)

        open(334,file=fv,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')

        do irec=1,100
           
         read(334,rec=(irec-1)*5+1) v(:,:,irec)
         
        enddo
        print*,'v(100,100,1)=',v(100,100,1)     
       close(334)
      
      return
      end
c-----------------------------------------------
 
c-------------------------------------------

      subroutine read_w(nk,w)

      include 'paramFsle.h'

c  declare passed variables.
c      real    a(n,m)

c  declare local temporary variables.
      integer nrecl,izn,nk
c
c  declare local saved variables.
      integer init,irec
      save    init,irec
      character*61 fw

      integer day2, iday2
c
c  open output file on 1st pass.
c      data init/0/
c      if (init .eq. 0) then
c        init=1
        nrecl=n*m*4

c        flnmv='../vel_input/v_110_05_01.dat'
c        flnmv='../vel_input/v_110_05_01f.dat'
      fw='vel_in/high_res_3d/016_archv.0008_050_00_2m_A_3zw.A'

        day2=day1+int(real(nk-1)/2.)
        write(fw(35:37),'(i3.3)') day2
        write(fw(33:33),'(i1.1)') iyr

        if (mod(nk,2).eq.0) then
           iday2=12
        else
           iday2=0
        endif 
        write(fw(39:40),'(i2.2)') iday2
        fw(45:45)=fcase(4:4)

        open(335,file=fw,form='unformatted',status='old',
     &       access='direct',recl=nrecl,convert='big_endian')

        do irec=1,100
           
         read(335,rec=(irec-1)*5+1) w(:,:,irec)
         
        enddo
        print*,'w(100,100,50)=',w(100,100,1)

       close(335)
      
      return
      end
c-----------------------------------------------

c----------------------------------------------------------------
      subroutine distance3(m,xM1,yM1,zM1,xM2,yM2,zM2,dist2,dx,dy,dz)

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
     &         + (dz*(zM2-zM1))**2
      else if (j1.eq.j2) then
       dist2 = base1**2+(dy(j1)*(yM2-yM1))**2 + (dz*(zM2-zM1))**2
      else
       deltayM=0.
       if (j1+1.lt.j2) then
        do j=j1+1,j2-1
         deltayM = deltayM + dy(j)
        enddo !j
       endif
       deltayM = deltayM + (j1+1-yM1)*dy(j1) + (yM2-j2)*dy(j2)
        dist2 = deltayM**2 + base1*base2 + (dz*(zM2-zM1))**2
      endif


      return
      end

c ===========================================================================
      SUBROUTINE INTERP3(xp,yp,zp,u,uu,nu)
!
!
      include 'paramFsle.h'

      PARAMETER(ll=4)

      REAL xp,yp,zp,uu
      REAL x1(ll),y1(ll),z1(ll),ub(ll,ll,ll)


!
!     FIRST: FIND SURROUNDING U,V POINTS
!
      nx = int(xp)
      ny = int(yp)
      nz = int(zp)
      d1 = xp - real(nx)
      d2 = yp - real(ny)
      d3 = zp - real(nz)

c nu=0 for central
      if (nu.eq.0) then
        nfx = nx
        nfy = ny
        nfz = nz
        ddx = d1
        ddy = d2
        ddz = d3
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
        nfz = nz
        ddz = d3
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
        nfz = nz
        ddz = d3
      endif

c nu=4 for w
      if (nu.eq.4) then
        if (d3.le.0.5) then
          nfz = nz
          ddz = d3 + 0.5
        else
          nfz = nz + 1
          ddz = d3 - 0.5
        endif
        nfx = nx
        ddx = d1
        nfy = ny
        ddy = d2
      endif

      if (nu.lt.5) then

       if (nfz.le.1) then
           nfz=2
       endif
       do in=1,ll
        x1(in) = real(nfx+(in-ll/2))
        y1(in) = real(nfy+(in-ll/2))
        z1(in) = real(nfz+(in-ll/2))
        do im=1,ll
          do il=1,ll
            ub(in,im,il) = u((nfx+(in-ll/2)),(nfy+(im-ll/2)),
     &                     (nfz+(il-ll/2)))
          enddo
        enddo
       enddo
      endif

c polynomial interpolation (from numerical recipes)

        call polin3(x1,y1,z1,ub,ll,ll,ll,
     &       real(nfx)+ddx,real(nfy)+ddy,real(nfz)+ddz,uu,err)

      RETURN
      END


!_______________________________________________________________________

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


!_______________________________________________________________________

      SUBROUTINE POLIN3(X1A,X2A,X3A,YA,L,M,N,X,Y,Z,U,DY)
!       by Yeon Chang (2012.2)
      PARAMETER (NMAX=20,MMAX=20,LMAX=20)
      DIMENSION X1A(L),X2A(M),X3A(N),YA(L,M,N),YNTMP(NMAX),YMTMP(MMAX)
     &          ,YLTMP(LMAX)

      DO 119 I=1,L
        DO 120 J=1,M
          DO 121 K=1,N
            YNTMP(K)=YA(I,J,K)
121        CONTINUE
          CALL POLINT(X3A,YNTMP,N,Z,YMTMP(J),DY)
120      CONTINUE
        CALL POLINT(X2A,YMTMP,M,Y,YLTMP(I),DY)
119   CONTINUE
      CALL POLINT(X1A,YLTMP,L,X,U,DY)
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
c          IF(DEN.EQ.0.)PAUSE
          IF(DEN.EQ.0.) THEN
          print*,'Yeon, you have to chck it !!!'
          STOP
          ENDIF
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

