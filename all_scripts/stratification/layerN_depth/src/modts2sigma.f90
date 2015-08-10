module modts2sigma
implicit none
!
!     usage:  echo pot.temp saln | ts_to_sigma
!
!     input:  temp saln
!     output: temp saln dens0 dens2
!
!             temp   = potential temperature (degC)
!             saln   = Salinity (psu)
!             dens0  = Sigma-0 potential density
!             dens2  = Sigma-2 potential density
!
!     alan j. wallcraft, naval research laboratory, august 2002.

real*4  dens0,dens2,saln,temp

contains

SUBROUTINE TOFSIG0(TSEA, RSEA,SSEA)
      IMPLICIT NONE

      REAL*4  TSEA,SSEA,RSEA

!   CALCULATE POTENTIAL TEMPERATURE FROM SIGMA-0 DENSITY AND SALINITY.

!   STATEMENT FUNCTIONS.

      REAL*4     DZERO,DTHIRD
      PARAMETER (DZERO=0.D0,DTHIRD=1.D0/3.D0)

      REAL*4 C1,C2,C3,C4,C5,C6,C7

      REAL*4  R,S,T
      REAL*4  A0,A1,A2,CUBQ,CUBR,CUBAN,CUBRL,CUBIM,TOFSIG

!  --- auxiliary statements for finding root of 3rd degree polynomial
      A0(S)=(C1+C3*S)/C6
      A1(S)=(C2+C5*S)/C6
      A2(S)=(C4+C7*S)/C6
      CUBQ(S)=DTHIRD*A1(S)-(DTHIRD*A2(S))**2
      CUBR(R,S)=DTHIRD*(0.5D0*A1(S)*A2(S)-1.5D0*(A0(S)-R/C6))-(DTHIRD*A2(S))**3
!  --- if q**3+r**2>0, water is too dense to yield real root at given
!  --- salinitiy. setting q**3+r**2=0 in that case is equivalent to
!  --- lowering sigma until a double real root is obtained.
      CUBAN(R,S)=DTHIRD*ATAN2(SQRT(MAX(DZERO,-(CUBQ(S)**3+CUBR(R,S)**2))),CUBR(R,S))
      CUBRL(R,S)=SQRT(-CUBQ(S))*COS(CUBAN(R,S))
      CUBIM(R,S)=SQRT(-CUBQ(S))*SIN(CUBAN(R,S))

!  --- temp (deg c) as a function of sigma and salinity (mil)
      TOFSIG(R,S)=-CUBRL(R,S)+SQRT(3.)*CUBIM(R,S)-DTHIRD*A2(S)

      TSEA = TOFSIG( RSEA,SSEA )
      RETURN
      end subroutine

      SUBROUTINE SIGMA0(RSEA,TSEA,SSEA)
      IMPLICIT NONE


      REAL*4  TSEA,SSEA,RSEA

!   CONVERT FROM SIGMA-0 TO SIGMA-2.

!   STATEMENT FUNCTIONS.

      REAL*4     DZERO,DTHIRD
      PARAMETER (DZERO=0.D0,DTHIRD=1.D0/3.D0)

      REAL*4     C1,C2,C3,C4,C5,C6,C7
!  --- coefficients for sigma-0 (based on Brydon & Sun fit)
      PARAMETER (C1=-1.36471e-01, C2= 4.68181e-02, C3= 8.07004E-01,     &
           C4=-7.45353e-03, C5=-2.94418E-03,     &
           C6= 3.43570e-05, C7= 3.48658e-05)

      REAL*4  S,T
      REAL*4  SIG

!  --- sigma-theta as a function of temp (deg c) and salinity (mil)
!  --- (friedrich-levitus 3rd degree polynomial fit)
      SIG(T,S)=(C1+C3*S+T*(C2+C5*S+T*(C4+C7*S+C6*T)))

!   T AND S TO SIG-2,

      RSEA = SIG( TSEA, SSEA )
      RETURN
      end subroutine

      SUBROUTINE SIGMA2(RSEA,TSEA,SSEA)
      IMPLICIT NONE

      REAL*4  TSEA,SSEA,RSEA

!   CONVERT FROM SIGMA-0 TO SIGMA-2.

!   STATEMENT FUNCTIONS.

      REAL*4     DZERO,DTHIRD
      PARAMETER (DZERO=0.D0,DTHIRD=1.D0/3.D0)

      REAL*4     C1,C2,C3,C4,C5,C6,C7
!  --- coefficients for sigma-2 (based on Brydon & Sun fit)
      PARAMETER (C1= 9.77093e+00, C2=-2.26493e-02, C3= 7.89879E-01, &
         C4=-6.43205E-03, C5=-2.62983E-03,     &  
         C6= 2.75835E-05, C7= 3.15235E-05)

      REAL*4  S,T
      REAL*4  SIG

!  --- sigma-theta as a function of temp (deg c) and salinity (mil)
!  --- (friedrich-levitus 3rd degree polynomial fit)
      SIG(T,S)=(C1+C3*S+T*(C2+C5*S+T*(C4+C7*S+C6*T)))

!   T AND S TO SIG-2,

      RSEA = SIG( TSEA, SSEA )
      RETURN
      END subroutine
end module
