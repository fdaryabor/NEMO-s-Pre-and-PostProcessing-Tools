function var_3d=SeaData2nemo_3d(SeaDatafile,maskfile,SeaData_varname,timeindex)
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
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
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

% set the default value if no data

default=NaN;
Roa=0;
disp([' Ext tracers: Roa = ',num2str(Roa/1000),...
      ' km - default value = ',num2str(default)])
%
[M,L]=size(lon_nemo);
%
dl=0.1;
lonmin=min(min(lon_nemo))-dl;
lonmax=max(max(lon_nemo))+dl;
latmin=min(min(lat_nemo))-dl;
latmax=max(max(lat_nemo))+dl;
%
% Read in the SeaDatafile 
%
ncdat=netcdf(SeaDatafile);
X=ncdat{'lon'}(:);
Y=ncdat{'lat'}(:);
Z=ncdat{'depth'}(:);
Nz=length(Z);
disp('Geting missing value ... ')
missvalue=ncdat{SeaData_varname}.FillValue_(:);
[lon_s,lat_s]=meshgrid(X,Y);
%
for k = 1 : Nz
    data1(k,:,:)=get_missing_val_2d(lon_s,lat_s,squeeze(ncdat{SeaData_varname}(timeindex,k,:,:)),missvalue,Roa,default);
    data2(k,:,:)=inpaint_nans(squeeze(data1(k,:,:)),0);
    data3(k,:,:)=interp2(lon_s,lat_s,squeeze(data2(k,:,:)),lon_nemo,lat_nemo,'linear');
end
%
%interpolation on the depth 
%
disp('Interpolation on the NEMO Depth')

ll=size(data3);
VAR = zeros(length(depth_nemo),ll(2),ll(3));
for jj = 1 : ll(2)
    for ii = 1 : ll(3)
        VAR(:,jj,ii)=interp1(Z,squeeze(data3(:,jj,ii)),dep3d(:,jj,ii),'linear');
    end
end
var_3d_nemo=inpaint_nans3(VAR,0);
var_3d = var_3d_nemo.*mask;
return
