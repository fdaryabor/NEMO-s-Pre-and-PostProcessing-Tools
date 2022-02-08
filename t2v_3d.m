function var_v=t2v_3d(var_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var_v=t2v_3d(var_t);
%
% interpole a field at t points to a field at v points
%
% input:
%
%  var_t variable at t-points (3D matrix)
%
% output:
%
%  var_v   variable at v-points (3D matrix)  
% 
%  Copyright (c) 2018-2019 by Farshid Daryabor 
%  e-mail:farshid.daryabor@cmcc.it  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[N,Mp,Lp]=size(var_t);
M=Mp-1;
var_v=0.5*(var_t(:,1:M,:)+var_t(:,2:Mp,:));
return

