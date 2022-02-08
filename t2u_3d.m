function var_u=t2u_3d(var_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var_u=t2u_3d(var_rho);
%
% interpole a field at t points to a field at u points
%
% input:
%
%  var_t variable at t-points (3D matrix)
%
% output:
%
%  var_u   variable at u-points (3D matrix)  
%
%  Copyright (c) 2018-2019 by Farshid Daryabor 
%  e-mail:farshid.daryabor@cmcc.it  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[N,Mp,Lp]=size(var_t);
L=Lp-1;
var_u=0.5*(var_t(:,:,1:L)+var_t(:,:,2:Lp));
return

