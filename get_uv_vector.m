function [u_red,v_red,Lonred,Latred,magnitude,scale,scalelength]=get_uv_vector(maskfile,U,V,skip,npts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for plotting sea current
% U,V in (m)
% npts = [0 0 0 0];
% reftype, 'median', 'max', 'equal'
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(' ')
disp('NEMO lon, lat, mask ... ')
nc=netcdf(maskfile);
lon = nc{'nav_lon'}(:);
lat = nc{'nav_lat'}(:);
mask=nc{'tmaskutil'}(:);
close(nc),
mask(mask==0)=nan;
%
disp(' ')
%
%  Angle between X-axis and the direction
%  to the EAST at T-points [radians].
angle=get_angle(lat,lon);
%
%  Boundaries
%
latb=rempoints(lat,npts);
lonb=rempoints(lon,npts);
maskb=rempoints(mask,npts);
angleb=rempoints(angle,npts);
ub=rempoints(U,npts);
vb=rempoints(V,npts);
%
%  Rotation
%
cosaa = cos(angleb);
sinaa = sin(angleb);
[M,Lp]=size(cosaa);
L=Lp-1;
cosa=0.5*(cosaa(:,1:L)+cosaa(:,2:Lp));
sina=0.5*(sinaa(:,1:L)+sinaa(:,2:Lp));
u = ub.*cosa - vb.*sina;
v = vb.*cosa + ub.*sina;
%
%  Skip
%
imin=floor(0.5+0.5*skip);
imax=floor(0.5+L-0.5*skip);
jmin=ceil(0.5+0.5*skip);
jmax=ceil(0.5+M-0.5*skip);
ured=u(jmin:skip:jmax,imin:skip:imax);
vred=v(jmin:skip:jmax,imin:skip:imax);
latred=latb(jmin:skip:jmax,imin:skip:imax);
lonred=lonb(jmin:skip:jmax,imin:skip:imax);
maskred=maskb(jmin:skip:jmax,imin:skip:imax);
%
%  Apply mask
%
Ured=maskred.*ured;
Vred=maskred.*vred;
Lonred=lonred;
Latred=latred;
%

[th,z] = cart2pol(Ured,Vred);
x1=abs(diff(Ured')); x2=abs(diff(Ured)); 
y1=abs(diff(Vred')); y2=abs(diff(Vred));
[~,z1] = cart2pol(x1,y1); [~,z2] = cart2pol(x2,y2);
scalelength=min(mean(z1(~isnan(z1))),mean(z2(~isnan(z2))));
scalelength=round(scalelength,3);
refvar=median(z(~isnan(z)));
roundp=floor(log10(refvar));
refvar=floor(refvar/(10^roundp))*(10^roundp);
scale=round(scalelength/refvar,2);
magnitude= hypot(Ured,Vred);
u_red = Ured./magnitude; 
v_red = Vred./magnitude; 
%
return
