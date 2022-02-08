function var_u=t2u_2d(var_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var_u=t2u_2d(var_t);
%
% interpole a field at t points to a field at u points
%
% input:
%
%  var_t variable at t-points (2D matrix)
%
% output:
%
%  var_u   variable at u-points (2D matrix)  
% 
% 
%  Copyright (c) 2018-2019 by Farshid Daryabor 
%  e-mail:farshid.daryabor@cmcc.it  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(var_t);
L=Lp-1;
var_u=0.5*(var_t(:,1:L)+var_t(:,2:Lp));
return

