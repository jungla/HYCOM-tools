function [R] = sigma0(T,S)

%  CONVERT FROM SIGMA-0 TO SIGMA-2.

%  --- coefficients for sigma-2 (based on Brydon & Sun fit)

      C1=-1.36471e-01;
      C2= 4.68181e-02;
      C3= 8.07004e-01;
      C4=-7.45353e-03;
      C5=-2.94418e-03;
      C6= 3.43570e-05;
      C7= 3.48658e-05;

%  --- sigma-theta as a function of temp (deg c) and salinity (mil)
%  --- (friedrich-levitus 3rd degree polynomial fit)

      R = (C1+C3*S+T*(C2+C5*S+T*(C4+C7*S+C6*T)));
