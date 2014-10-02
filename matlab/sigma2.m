function [R] = sigma2(T,S)


%  CONVERT FROM SIGMA-0 TO SIGMA-2.

%  --- coefficients for sigma-2 (based on Brydon & Sun fit)

      C1= 9.77093e+00;
      C2=-2.26493e-02;
      C3= 7.89879E-01;
      C4=-6.43205E-03;
      C5=-2.62983E-03;
      C6= 2.75835E-05;
      C7= 3.15235E-05;

%  --- sigma-theta as a function of temp (deg c) and salinity (mil)
%  --- (friedrich-levitus 3rd degree polynomial fit)

      R =(C1+C3*S+T*(C2+C5*S+T*(C4+C7*S+C6*T)));
