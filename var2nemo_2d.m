function [var2nemo]=var2nemo_2d(varfilename,nemo_maskfile,varname,...
                            lonname,latname,grid_type,time_record)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function used to regrid any 2d variables horizontally in NEMO grid-point
%Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(' ')
%
% set the value of ro (oa decorrelation scale [m]) 
% and default (value if no data)
%
ro=0;
default=NaN;
disp([' Ext tracers: ro = ',num2str(ro/1000),...
      ' km - default value = ',num2str(default)])

%
disp('Extract NEMO Parameters ...')

nc_mask = netcdf(nemo_maskfile);
lon_nemo=nc_mask{'nav_lon'}(:);
lat_nemo=nc_mask{'nav_lat'}(:);
if grid_type == 'T'   
    mask   = squeeze(nc_mask{'tmask'}(1,1,:,:));
elseif grid_type == 'U'
    mask   = squeeze(nc_mask{'umask'}(1,1,:,:));
elseif grid_type == 'V'
    mask   = squeeze(nc_mask{'vmask'}(1,1,:,:));
elseif grid_type == 'W'
    mask   = squeeze(nc_mask{'fmask'}(1,1,:,:));
end
close(nc_mask)
mask_nemo=mask;
mask_nemo(mask==0)=nan;

%
disp('Extract ARGO-Monthly Climatology Parameters and Variabels ...')
nc=netcdf(varfilename);
data2d=squeeze(nc{varname}(time_record,:,:));
X=nc{lonname}(:);
Y=nc{latname}(:);
[lon,lat]=meshgrid(X,Y);
%
disp('Geting missing value ... ')
missvalue=nc{varname}.FillValue_(:);
close(nc)
%
var2d=get_missing_val_2d(lon,lat,data2d,missvalue,ro,default);
data1=inpaint_nans(var2d,0);
var=interp2(lon,lat,data1,lon_nemo,lat_nemo,'spline');
[var2nemo]=var.*mask_nemo;
return