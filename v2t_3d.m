function [var_t]=v2t_3d(var_v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var_t=v2t_3d(var_v)
%
% interpole a field at v points to a field at t points
%
% input:
%
%  var_v variable at v-points (3D matrix)
%
% output:
%
%  var_t   variable at t-points (3D matrix)  
% 
%  Copyright (c) 2018-2019 by Farshid Daryabor 
%  e-mail:farshid.daryabor@cmcc.it  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
[N,M,Lp]=size(var_v);
Mp=M+1;
Mm=M-1;
var_t=zeros(N,Mp,Lp);
var_t(:,2:M,:)=0.5*(var_v(:,1:Mm,:)+var_v(:,2:M,:));
var_t(:,1,:)=var_t(:,2,:);
var_t(:,Mp,:)=var_t(:,M,:);
	
return