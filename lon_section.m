function [transect ,Z,VAR] = lon_section(maskfile,lonsec,latsec,vname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 
%lonsec = [100.5 116];
%latsec = [1 8];
%
%  Extract a vertical slice in any direction (or along a curve)
%  from a NEMO netcdf file.
%
% 
% On Input:
% 
%    maskfile    mask NetCDF file name (character string). 
%    lonsec      Longitudes of the points of the section. 
%                 (vector or [min max] or single value if N-S section).
%
%    latsec      Latitudes of the points of the section. 
%                 (vector or [min max] or single value if E-W section)
%
%
%    NB: if lonsec and latsec are vectors, they must have the same length.
%
%    vname       NetCDF variable name to process (character string).
%
%    tindex      Netcdf time index (integer).
%                
%
% On Output:
%
%    transect    Slice X or Y-distances from the first point (2D matrix).
%    Z           Slice Z-positions (matrix). 
%    VAR         Slice of the variable (matrix).
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Find maximum grid angle size (dl)
%

nc=netcdf(maskfile);
lon=nc{'nav_lon'}(:);
lat=nc{'nav_lat'}(:);
dep=nc{'gdept'}(:);
mask=nc{'tmaskutil'}(:);
close(nc)
%

[M,L]=size(lon);
dl=1.5* max([max(max(abs(lon(2:M,:)-lon(1:M-1,:)))) ...
        max(max(abs(lon(:,2:L)-lon(:,1:L-1)))) ...
        max(max(abs(lat(2:M,:)-lat(1:M-1,:)))) ...
        max(max(abs(lat(:,2:L)-lat(:,1:L-1))))]);
%
[M,L]=size(lon);
%
% Find minimal subgrids limits
%
minlon=min(lonsec)-dl;
minlat=min(latsec)-dl;
maxlon=max(lonsec)+dl;
maxlat=max(latsec)+dl;
sub=lon>minlon & lon<maxlon & lat>minlat & lat<maxlat;
if (sum(sum(sub))==0)
  error('Section out of the domain')
end
ival=sum(sub,1);
jval=sum(sub,2);
imin=min(find(ival~=0));
imax=max(find(ival~=0));
jmin=min(find(jval~=0));
jmax=max(find(jval~=0));
%
% Get subgrids
%
lon=lon(jmin:jmax,imin:imax);
lat=lat(jmin:jmax,imin:imax);
sub=sub(jmin:jmax,imin:imax);
mask=mask(jmin:jmax,imin:imax);
%
% Put latitudes and longitudes of the section in the correct vector form
%
if (length(lonsec)==1)
  disp(['N-S section at longitude: ',num2str(lonsec)])
  if (length(latsec)==1)
    error('Need more points to do a section')
  elseif (length(latsec)==2)
    latsec=(latsec(1):dl:latsec(2));
  end
  lonsec=0.*latsec+lonsec;
elseif (length(latsec)==1)
  disp(['E-W section at latitude: ',num2str(latsec)])
  if (length(lonsec)==2)
    lonsec=(lonsec(1):dl:lonsec(2));
  end
  latsec=0.*lonsec+latsec;
elseif (length(lonsec)==2 & length(latsec)==2)
  Npts=ceil(max([abs(lonsec(2)-lonsec(1))/dl ...
                  abs(latsec(2)-latsec(1))/dl]));
  if lonsec(1)==lonsec(2)
    lonsec=lonsec(1)+zeros(1,Npts+1);
  else
    lonsec=(lonsec(1):(lonsec(2)-lonsec(1))/Npts:lonsec(2));
  end
  if latsec(1)==latsec(2)
    latsec=latsec(1)+zeros(1,Npts+1);
  else
    latsec=(latsec(1):(latsec(2)-latsec(1))/Npts:latsec(2));
  end
elseif (length(lonsec)~= length(latsec))
  error('Section latitudes and longitudes are not of the same length')
end
Npts=length(lonsec);
%
% Get the subgrid
%
sub=0*lon;
for i=1:Npts
  sub(lon>lonsec(i)-dl & lon<lonsec(i)+dl & ...
      lat>latsec(i)-dl & lat<latsec(i)+dl)=1;
end
%
%  get the coefficients of the objective analysis
%
londata=lon(sub==1);
latdata=lat(sub==1);
coef=oacoef(londata,latdata,lonsec,latsec,100e3);
%
% Get the mask
%
mask=mask(sub==1);
m1=griddata(londata,latdata,mask,lonsec,latsec,'nearest');
londata=londata(mask==1);
latdata=latdata(mask==1);
%
%  Get the vertical levels
%
N=length(dep(:,1,1));
for k=1:N
    h=dep(k,jmin:jmax,imin:imax);
    h=h(sub==1);
    h=h(mask==1);
    h=griddata(londata,latdata,h,lonsec,latsec,'linear');
    Z(k,:)=m1.*h;
end
%
% Loop on the vertical levels
%VAR=0.*Z;
for k=1:N
    var=vname(k,jmin:jmax,imin:imax);
    var=var(sub==1);
    var=var(mask==1);
    var=griddata(londata,latdata,var,lonsec,latsec,'linear');
    VAR(k,:)=m1.*var;
end
%
transect = squeeze(tridim(lonsec,N));

return




