function [var_t]=u2t_3d(var_u)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var_t=u2t_3d(var_u)
%
% interpole a field at u points to a field at t points
%
% input:
%
%  var_u variable at u-points (3D matrix)
%
% output:
%
%  var_t   variable at t-points (3D matrix)  
% 
%  Copyright (c) 2018-2019 by Farshid Daryabor 
%  e-mail:farshid.daryabor@cmcc.it  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N,Mp,L]=size(var_u);
Lp=L+1;
Lm=L-1;
var_t=zeros(N,Mp,Lp);
var_t(:,:,2:L)=0.5*(var_u(:,:,1:Lm)+var_u(:,:,2:L));
var_t(:,:,1)=var_t(:,:,2);
var_t(:,:,Lp)=var_t(:,:,L);
	
return	