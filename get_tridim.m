function var3d=get_tridim(field2d,N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  Put a 2D matrix in 3D (reproduce it N times).
%  e.g., field2d is M*L you want to be N*M*L
%  Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(field2d);
var3d=reshape(field2d,1,M,L);
var3d=repmat(var3d,[N 1 1]);
return
  
