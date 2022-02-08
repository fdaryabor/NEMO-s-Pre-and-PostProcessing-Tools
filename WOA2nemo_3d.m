function var_3d=WOA2nemo_3d(woafile,maskfile,woavar,timeindex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%interpolation mrthods
%'linear'   - (default) linear interpolation
%'nearest'  - nearest neighbor interpolation
%'next'     - next neighbor interpolation
%'previous' - previous neighbor interpolation
%'spline'   - piecewise cubic spline interpolation (SPLINE)
%'pchip'    - shape-preserving piecewise cubic interpolation
%'cubic'    - same as 'pchip'
%'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                   extrapolate and uses 'spline' if X is not equally
%                   spaced.
%Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(' ')
%
nc = netcdf(maskfile);
lon_nemo=nc{'nav_lon'}(:);
lat_nemo=nc{'nav_lat'}(:);
depth_nemo=nc{'nav_lev'}(:);
dep3d = nc{'gdept'}(:);
maskt  =squeeze(nc{'tmask'}(1,:,:,:));
close(nc)
mask = maskt; mask(maskt==0) = NaN;
%
% set the default value if no data
%
default=NaN;
Roa=0;
disp([' Ext tracers: Roa = ',num2str(Roa/1000),...
      ' km - default value = ',num2str(default)])
%
[M,L]=size(lon_nemo);
%
%
%
dl=0.5;
lonmin=min(min(lon_nemo))-dl;
lonmax=max(max(lon_nemo))+dl;
latmin=min(min(lat_nemo))-dl;
latmax=max(max(lat_nemo))+dl;
%
% Read in the woafile 
%
ncdat=netcdf(woafile);
X=ncdat{'lon'}(:);
Y=ncdat{'lat'}(:);
Z=ncdat{'depth'}(:);
Nz=length(Z);
%
% get a subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-1440>=lonmin & X-1440<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+1440>=lonmin & X+1440<=lonmax);
x=cat(1,X(i1)-1440,X(i2),X(i3)+1440);
y=Y(j);
%
% Interpole the dataset on the horizontal NEMO grid
%
disp('Interpolation on the horizontal NEMO grid')

data2d_nemo=zeros(Nz,M,L);
missval=ncdat{woavar}.missing_value(:);
for k=1:Nz
    if ~isempty(i2)
        data=squeeze(ncdat{woavar}(timeindex,k,j,i2));
    else
        data=[];
    end
    if ~isempty(i1)
        data=cat(2,squeeze(ncdat{woavar}(timeindex,k,j,i1)),data);
    end
    if ~isempty(i3)
        data=cat(2,data,squeeze(ncdat{woavar}(timeindex,k,j,i3)));
    end
    data=get_missing_val(x,y,data,missval,Roa,default);
    data2d_nemo(k,:,:)=interp2(x,y,data,lon_nemo,lat_nemo,'linear');
end
close(ncdat);
%
% Test for salinity (no negative salinity !)
%
if strcmp(woavar,'salinity')
  disp('salinity test')
  data2d_nemo(data2d_nemo<2)=2;
end
%
%
%interpolation on the depth 
%
%
disp('Interpolation on the NEMO Depth')

ll=size(data2d_nemo);
VAR = zeros(length(depth_nemo),ll(2),ll(3));
for jj = 1 : ll(2)
    for ii = 1 : ll(3)
        VAR(:,jj,ii)=interp1(Z,squeeze(data2d_nemo(:,jj,ii)),dep3d(:,jj,ii),'linear');
    end
end
var_3d_nemo=inpaint_nans3(VAR,0);
var_3d = var_3d_nemo.*mask;
return
