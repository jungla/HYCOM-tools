function [X1,X2,Y1,Y2,R] = regions(id)

 if (id == 1)
  X1 = 472
  X2 = 840
  Y1 = 77+3
  Y2 = 267+5
  R = 'A'
 elseif (id == 2)
  X1 = 840
  X2 = 1279+1
  Y1 = 77+3
  Y2 = 267+5
  R = 'B'
 elseif (id == 3)
  X1 = 619+1
  X2 = 988
  Y1 = 774+2
  Y2 = 900
  R = 'C'
 else
  X1 = 472
  X2 = 768
  Y1 = 393+3
  Y2 = 584
  R = 'D'
 end
