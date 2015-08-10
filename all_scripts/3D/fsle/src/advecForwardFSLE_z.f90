program advecForwardFSLE

use modiof
use modfsle

implicit none

integer, parameter :: day0=1,dayN=11,dayTr1=31,dayTr2=60,dayTr3=91,dayTr4=121
real*4, parameter :: tmicom=24*3600.,dt=2*3600.,tmicom0=24*3600.
real*4, parameter :: r1=5.,r2=10.,r3=20.							! hours?
integer, parameter :: lz=500									! particles deployed in layer
integer, parameter :: idm=1573,jdm=1073								! domain size
integer, parameter :: ids=300,jds=300								! domain size
integer, parameter :: np=20,mp=20,lp=1
integer, parameter :: npar=np*mp*lp*3 								! number of pairs

real*4 :: u(ids,jds,lz),v(ids,jds,lz),w(ids,jds,lz),w1(ids,jds,lz),w2(ids,jds,lz)
real*4 :: u1(ids,jds,lz),v1(ids,jds,lz),u2(ids,jds,lz),v2(ids,jds,lz)
real*4 :: tml(idm,jdm),ml(ids,jds)
real*4 :: tpscx(idm,jdm),tpscy(idm,jdm),pscx(ids,jds),pscy(ids,jds)
real*4 :: liap1(np,mp,lp),tau1(np,mp,lp),liap2(np,mp,lp),tau2(np,mp,lp),liap3(np,mp,lp),tau3(np,mp,lp)
real*4 :: di,df1,df2,df3,dr2,xM1,yM1,xM2,yM2,zM1,zM2,dz

real*4  :: x0(npar),y0(npar),z0(npar),x0i(npar),y0i(npar),z0i(npar),x0max,y0max
integer :: x0id(npar),y0id(npar),z0id(npar)
integer :: ii,iti,l,ipp,lup,skip,l0,no,countall,i,j,k,jj,it,ktkt,ipk,kk,p
real*4 :: ttime,elaps
character*30 :: fltraji ! read  trajectories file
character*30 :: fltrajo ! write trajectories file
character*40 :: flliap  ! output lyapunov exponents file
character*10 :: flnmu1,flnmv1,flnmu2,flnmv2,flnmw1,flnmw2
character*3 :: day
character*1 :: R
character*6,parameter :: flnmu='fort.u',flnmv='fort.v',flnmw='fort.w'
character*10,parameter :: flnmr ='fort.00A'
character*10 :: flnmm, buffer
integer,parameter :: iver = 0

! velocity files need to linked, with some external script, as fort.u1,fort.u2,fort.u4,...

integer :: x1,x2,y1,y2,z1,z2

dz = 2

CALL GETARG(1,BUFFER)
READ(BUFFER,*) X1

CALL GETARG(2,BUFFER)
READ(BUFFER,*) X2

CALL GETARG(3,BUFFER)
READ(BUFFER,*) Y1

CALL GETARG(4,BUFFER)
READ(BUFFER,*) Y2

CALL GETARG(5,BUFFER)
READ(BUFFER,*) R

write(*,*) x1,x2,y1,y2,R

z1 = 1
z2 = 500

fltrajo = 'traj.out.'//R
flliap  = 'fslf.'//R
fltraji = 'traj.ini'

! initialize from MLD. Initial vertical position. Adjust the day accordingly.

flnmm = 'fort.m01'
write(*,*) 'seed particles around MLD'


! read grid sizes
call rhf(flnmr,idm,jdm,10,tpscx)
call rhf(flnmr,idm,jdm,11,tpscy)

pscx = tpscx(x1:x2,y1:y2)
pscy = tpscy(x1:x2,y1:y2)

print*,'pscx(100,100),pscy(100,100)=',pscx(100,100),pscy(100,100)

! --- fsle-map parameters
! map fsle initial position

di=0.45*pscy(ids/2,jds/2)

if (iver.eq.1) then ! for separation in the vertical direction
 di=0.45*dz
endif

! separation radius for FSLE (I guess)

df1=r1*di
df2=r2*di
df3=r3*di

! not sure... what ktkt is.

! --- read launch positions
! --- triplets
! how to format launch position?
! pairs of x,y positions

 write(*,*) 'open trajectoris file:',fltrajo

! open(14,file=fltraji,status='old')
! do ipp=1,npar
!  write(*,*) x0(ipp),y0(ipp)
!  read(14,*) x0(ipp),y0(ipp)
!  x0i(ipp)=x0(ipp)
!  y0i(ipp)=y0(ipp)
! enddo !ipp
! close(14)

! write (17,*) 0.,x0i(1),y0i(1)

 call seed(x0,y0,z0,x1,x2,y1,y2,z1,z2,np,mp,lp) ! modified for 3D

! seed right below and right on top of ML

call rbf(flnmm,idm,jdm,6,tml(:,:))
ml = tml(x1:x2,y1:y2)/9806/dz

do k=1,lp
 do i=1,np
  do j=1,mp*3,3
   do p=0,2
    z0((i-1)*mp*3 + j + p) = ml(i,j)-10
   enddo
  enddo
 enddo
enddo


! --- output file
open(15,file=fltrajo,status='unknown',form='formatted')

 do ipp=1,npar
  write(*,*) ipp,x0(ipp),y0(ipp),z0(ipp)
  write(15,*) ipp,x0(ipp),y0(ipp),z0(ipp)
  x0i(ipp)=x0(ipp)
  y0i(ipp)=y0(ipp)
  z0i(ipp)=z0(ipp)
 enddo !ipp

 print*,'npar=',npar

 do i=1,np
  do j=1,mp
   do k=1,lp
   liap1(i,j,k)=0.
   tau1(i,j,k)=0.
   liap2(i,j,k)=0.
   tau2(i,j,k)=0.
   liap3(i,j,k)=0.
   tau3(i,j,k)=0.
   enddo
  enddo
 enddo

! --- time interpolation
 iti=nint(tmicom/dt)
 if (iti.le.1) stop
 skip=nint(tmicom/tmicom0)
 print*,'tmicom,dt = (sec) '   ,tmicom,dt
 print*,'tmicom,dt = (hours) ' ,tmicom/3600.,dt/3600.
 print*,'iti=',iti
 !ttime=float(day0)
 ttime=24*float(day0-1)
 print*,'ttime=',ttime

! --- model-output loop
 do l = day0,dayN-1   ! external. goes over the archives.

 print*,'-------------------------------------------------------'

! --- read micom fields and change axes
! read each time a different file.

! u1,v1 and u2,v2 are velocities at two consecutive times. it's for the particle
! advection

 if (l.le.10) then
  write(day,'(I3)') l
  flnmu1 = flnmu//'0'//trim(adjustl(day))
  flnmv1 = flnmv//'0'//trim(adjustl(day))
  flnmw1 = flnmw//'0'//trim(adjustl(day))
 endif
 if (l+1.le.10) then
  write(day,'(I3)') l+1
  flnmu2 = flnmu//'0'//trim(adjustl(day))
  flnmv2 = flnmv//'0'//trim(adjustl(day))
  flnmw2 = flnmw//'0'//trim(adjustl(day))
 endif

 write(*,*) flnmu1,flnmv1,flnmw1,flnmu2,flnmv2,flnmw2

 if(l>day0) then
  u1 = u2
  v1 = v2
  w1 = w2
  do k=1,lz
   call rbf(flnmu2,ids,jds,k,u2(:,:,k))
   call rbf(flnmv2,ids,jds,k,v2(:,:,k))
   call rbf(flnmw2,ids,jds,k,w2(:,:,k))
  enddo
 else
  do k=1,lz
   call rbf(flnmu1,ids,jds,k,u1(:,:,k))
   call rbf(flnmv1,ids,jds,k,v1(:,:,k))
   call rbf(flnmw1,ids,jds,k,w1(:,:,k))
   call rbf(flnmu2,ids,jds,k,u2(:,:,k))
   call rbf(flnmv2,ids,jds,k,v2(:,:,k))
   call rbf(flnmw2,ids,jds,k,w2(:,:,k))
  enddo
 endif

 print*,'u1,v1,w1 read'
 print*, u1(100,100,10),v1(100,100,10),w1(100,100,10)
 print*,'u2,v2,w2 read'
 print*, u2(100,100,10),v2(100,100,10),w2(100,100,10)


 print*,'..u2,v2 read'
 call zerotheland(u1,v1,w1)
 call zerotheland(u2,v2,w2)
 print*,'l,lup=',l,lup

    
! --- time-interpolation loop
 do it=1,iti   
 
  ttime=ttime+dt/3600.
  print*,'ttime=',ttime,'		day=',int(ttime/24.)
  elaps=ttime/24-day0+1
   print*,'elapsed time (days)=',elaps

! --- particles ipp advection
        ii = 0
        jj = 0
        kk = 0

        do ipp=1,npar
         !write(*,*) ipp,x0(ipp),ii,y0(ipp), jj,z0(ipp), kk
          
         if ((x0(ipp).lt.5.0.or.x0(ipp).gt.(ids-5)).or.(y0(ipp).lt.5.0.or.y0(ipp).gt.(jds-5.0)) &
               .or.(z0(ipp).lt.0.5.or.z0(ipp).gt.(lz-4.0))) then
          x0(ipp)=9999.
          y0(ipp)=9999.
          z0(ipp)=9999.
         else
          CALL EULER3(ids,jds,lz,X0(ipp),Y0(ipp),Z0(ipp),u1,v1,w1,u2,v2,w2,IT,ITI,DT,pscx(1,:),pscy(:,1),dz)
         endif

         write(15,*) ipp,x0(ipp),y0(ipp),z0(ipp)

         if (mod(ipp,200000).eq.0) print *,'ipp =',ipp, x0(ipp),z0(ipp)

         if (mod(ipp,3).eq.0) then

          xM1=x0(ipp-2)
          yM1=y0(ipp-2)
          zM1=z0(ipp-2)

          ii=x0i(ipp-2)*np/(x2-x1)+1
          jj=y0i(ipp-2)*mp/(y2-y1)+1
          kk=1!z0i(ipp-2)*lp/(z2-z1)+1


          do ipk=ipp-1,ipp

           xM2=x0(ipk)
           yM2=y0(ipk)
           zM2=z0(ipk)

           if (xM1.eq.9999..or.xM2.eq.9999.) then
            dr2=0.
           else

            if (iver.eq.1) then
             call distance3(jds,xM1,yM1,zM1,xM1,yM1,zM2,dr2,pscx(1,:),pscy(:,1),dz)
            else
             call distance3(jds,xM1,yM1,zM1,xM2,yM2,zM2,dr2,pscx(1,:),pscy(:,1),dz)
            endif

          !  write(*,*) sqrt(dr2),df1,df2,df3,tau1(ii,jj,kk),tau2(ii,jj,kk),tau3(ii,jj,kk)

            if (dr2.ge.df1**2.and.tau1(ii,jj,kk).eq.0.) then
             tau1(ii,jj,kk)=elaps*24.  !in hrs
            else if (dr2.ge.df2**2.and.tau2(ii,jj,kk).eq.0.) then
             tau2(ii,jj,kk)=elaps*24.  !in hrs
            else if (dr2.ge.df3**2.and.tau3(ii,jj,kk).eq.0.) then
             tau3(ii,jj,kk)=elaps*24.  !in hrs
            endif

           endif
          enddo !ipk
         endif

         if (x0(ipp).ne.9999.) x0max=max(x0max,x0(ipp))
         if (y0(ipp).ne.9999.) y0max=max(y0max,y0(ipp))
        
        !write (15,*) ipp,x0(ipp),y0(ipp),z0(ipp)

        enddo !ipp
        print*,'x0max,y0max=',x0max,y0max

 enddo !it
     
enddo !l
close(15)

! FSLE

do i=1,np
 do j=1,mp
      do k=1,lp
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
      enddo !k
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

end program 

