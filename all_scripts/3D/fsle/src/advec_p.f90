program advecFSLE

use modiof
use modfsle

implicit none

include 'mpif.h'


integer, parameter :: day0=1,dayN=3,dayTr1=31,dayTr2=60,dayTr3=91,dayTr4=121
real*4, parameter :: tmicom=24*3600.,dt=2*3600.,tmicom0=24*3600.
real*4, parameter :: r1=5.,r2=10.,r3=20.							! hours?
integer, parameter :: lz=500									! particles deployed in layer
integer, parameter :: idm=1573,jdm=1073								! domain size
integer, parameter :: ids=300,jds=300								! domain size
integer, parameter :: np=50,mp=50,lp=1
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
character*11 :: fltrajo ! write trajectories file
character*40 :: flliap  ! output lyapunov exponents file
character*10 :: flnmu1,flnmv1,flnmu2,flnmv2,flnmw1,flnmw2
character*3 :: day,proc
character*1 :: R
character*6,parameter :: flnmu='fort.u',flnmv='fort.v',flnmw='fort.w'
character*10,parameter :: flnmr ='fort.00A'
character*10 :: flnmm, buffer
integer,parameter :: iver = 0

! mpi declaration
integer :: ierr, nprocs, my_id, pp
integer :: start_par, end_par 
integer :: status(MPI_STATUS_SIZE)
character*20 :: fltrajop ! write trajectories file

! velocity files need to linked, with some external script, as fort.u1,fort.u2,fort.u4,...

integer :: x1,x2,y1,y2,z1,z2

dz = 2

call MPI_INIT ( ierr )
call MPI_COMM_RANK (MPI_COMM_WORLD, my_id, ierr)
call MPI_COMM_SIZE (MPI_COMM_WORLD, nprocs, ierr)

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

fltrajo = 'traj.out.'//R//'.'
flliap  = 'fslf.'//R
fltraji = 'traj.ini'

! initialize from MLD. Initial vertical position. Adjust the day accordingly.

! separation radius for FSLE (I guess)

df1=r1*di
df2=r2*di
df3=r3*di

! not sure... what ktkt is.

! --- read launch positions
! --- triplets
! how to format launch position?
! pairs of x,y positions

! write(*,*) 'open trajectoris file:',fltrajo

! open(14,file=fltraji,status='old')
! do ipp=1,npar
!  write(*,*) x0(ipp),y0(ipp)
!  read(14,*) x0(ipp),y0(ipp)
!  x0i(ipp)=x0(ipp)
!  y0i(ipp)=y0(ipp)
! enddo !ipp
! close(14)

! write (17,*) 0.,x0i(1),y0i(1)


! --- output file
 open(100,file=fltrajo,status='unknown',form='formatted')

 print*,'npar=',npar

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

 do ipp=1,npar
  x0i(ipp)=x0(ipp)
  y0i(ipp)=y0(ipp)
  z0i(ipp)=z0(ipp)
 enddo !ipp


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

 call zerotheland(u1,v1,w1)
 call zerotheland(u2,v2,w2)

 ! read grid

 call rhf(flnmr,idm,jdm,10,tpscx)
 call rhf(flnmr,idm,jdm,11,tpscy)
 
 pscx = tpscx(x1:x2,y1:y2)
 pscy = tpscy(x1:x2,y1:y2)

 write(*,*) my_id, ' pscx(100,100), pscy(100,100)=',pscx(100,100),pscy(100,100)

!do ipp=1,npar
 !write(*,*) ipp,x0(ipp),ii,y0(ipp), jj,z0(ipp), kk
    
! --- time-interpolation loop
 do it=1,iti   
 
  ttime=ttime+dt/3600.
!  print*,'ttime=',ttime,'		day=',int(ttime/24.)
  elaps=ttime/24-day0+1
!   print*,'elapsed time (days)=',elaps

        ii = 0
        jj = 0
        kk = 0

! MASTER
! - seed particles
! - divide the particles between the SLAVES

if (my_id == 0) then

 call seed(x0,y0,z0,x1,x2,y1,y2,z1,z2,np,mp,lp) ! modified for 3D

 ! seed right below and right on top of ML

  
 ! --- fsle-map parameters
 ! map fsle initial position
 
 di=0.45*pscy(ids/2,jds/2)
 
 if (iver.eq.1) then ! for separation in the vertical direction
  di=0.45*dz
 endif

 flnmm = 'fort.m01'
 write(*,*) my_id, 'Seeds particles around MLD.'
 write(*,*) my_id, 'read MLD'

 call rbf(flnmm,idm,jdm,6,tml(:,:))
 ml = tml(x1:x2,y1:y2)/9806/dz

 write(*,*) my_id, 'read MLD. DONE'

 do k=1,lp
  do i=1,np
   do j=1,mp*3,3
    do p=0,2
!     z0((i-1)*mp*3 + j + p) = ml(i,j)-10
    enddo
   enddo
  enddo
 enddo

 write(*,*) my_id , 'Seeds particles around MLD. DONE'

 ! advect particles of proc 0
 write(*,*) my_id, 'Advect particles MOTHER.'

 do ipp=1,npar/nprocs
  if ((x0(ipp).lt.5.0.or.x0(ipp).gt.(ids-5)).or.(y0(ipp).lt.5.0.or.y0(ipp).gt.(jds-5.0)) &
   .or.(z0(ipp).lt.0.5.or.z0(ipp).gt.(lz-4.0))) then
   x0(ipp)=9999.
   y0(ipp)=9999.
   z0(ipp)=9999.
  else
   CALL EULER3(ids,jds,lz,X0(ipp),Y0(ipp),Z0(ipp),u1,v1,w1,u2,v2,w2,IT,ITI,DT,pscx(1,:),pscy(:,1),dz)
  endif
 enddo

 write(*,*) my_id, 'Advect particles MOTHER. DONE'

 ! separate particles in SLAVES

 do p=1,nprocs-1
  write(*,*) my_id, 'send particles to CHILDREN', p
  start_par = p*npar/nprocs
  call MPI_SEND(start_par, 1, MPI_INTEGER, p, 2001, MPI_COMM_WORLD, ierr)
  write(*,*) my_id, 'send particles to CHILDREN',p,'. DONE'
 enddo !ipp

 else ! SLAVES

  end_par   = (my_id+1)*npar/nprocs
  write(*,*) my_id, 'receive start_par from MOTHER'
  call MPI_RECV(start_par, 1, MPI_REAL, 0, 2001, MPI_COMM_WORLD, status, ierr)
  write(*,*) my_id, 'receive start_par:',start_par,' from MOTHER. DONE'
  
  do ipp=start_par,end_par
   if ((x0(ipp).lt.5.0.or.x0(ipp).gt.(ids-5)).or.(y0(ipp).lt.5.0.or.y0(ipp).gt.(jds-5.0)) &
    .or.(z0(ipp).lt.0.5.or.z0(ipp).gt.(lz-4.0))) then
    x0(ipp)=9999.
    y0(ipp)=9999.
    z0(ipp)=9999.
   else
    CALL EULER3(ids,jds,lz,X0(ipp),Y0(ipp),Z0(ipp),u1,v1,w1,u2,v2,w2,IT,ITI,DT,pscx(1,:),pscy(:,1),dz)
   endif
   ! send advected particles
    write(*,*) my_id, 'send adv particle',ipp,'to MOTHER'
    call MPI_SEND(X0(ipp), 1, MPI_REAL, 0, 1, MPI_COMM_WORLD, ierr)
    call MPI_SEND(Y0(ipp), 1, MPI_REAL, 0, 2, MPI_COMM_WORLD, ierr)
    call MPI_SEND(Z0(ipp), 1, MPI_REAL, 0, 3, MPI_COMM_WORLD, ierr)
    write(*,*) my_id, 'send adv particle',ipp,'to MOTHER. DONE'
  enddo

 endif ! MASTER - SLAVE

! receive the advected particles
  do p=1,nprocs-1
   do ipp=p*npar/nprocs,npar,npar/nprocs
    write(*,*) my_id, 'receive advected particle',ipp,' from CHILDREN.'
    call MPI_RECV(X0(ipp), 1, MPI_REAL, p, 1, MPI_COMM_WORLD, status, ierr)
    call MPI_RECV(Y0(ipp), 1, MPI_REAL, p, 2, MPI_COMM_WORLD, status, ierr)
    call MPI_RECV(Z0(ipp), 1, MPI_REAL, p, 3, MPI_COMM_WORLD, status, ierr)
    write(*,*) my_id, 'receive advected particle',ipp,' from CHILDREN. DONE'
   enddo
  enddo


 ! save the advected particles

 write(100,*) ipp,ttime,x0(ipp),y0(ipp),z0(ipp)

 enddo !it
     
enddo !l

call MPI_FINALIZE ( ierr )

end program 

