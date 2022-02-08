function nemo_uvvector(nemo_filename,nemo_maskfile,time_record,number_layer,u_varname,v_varname,depth,unit,  ...
                                figurepath,Year,varanalysis,typeanalysis,skip,npts,titlename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% npts = [0 0 0 0];
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(' ')
%
nc_mask = netcdf(nemo_maskfile);
lon_nemo = nc_mask{'nav_lon'}(:);
lat_nemo = nc_mask{'nav_lat'}(:);
mask   = nc_mask{'tmaskutil'}(:);  
close(nc_mask)
mask_nemo=mask;
mask_nemo(mask==0)=nan;
%
nc=netcdf(nemo_filename);
missval=nc{u_varname}.FillValue_(:);

U_nemo=(squeeze(nc{u_varname}(time_record,number_layer,:,:))).*mask_nemo;
ua=get_missing_val_2d(lon_nemo,lat_nemo,U_nemo,missval,0,NaN);

V_nemo=(squeeze(nc{v_varname}(time_record,number_layer,:,:))).*mask_nemo;
va=get_missing_val_2d(lon_nemo,lat_nemo,V_nemo,missval,0,NaN);

close(nc)
%
%  Angle between XI-axis and the direction
%  to the EAST at RHO-points [radians].
angle=get_angle(lat_nemo,lon_nemo);
%
%  Boundaries
%
latb=rempoints(lat_nemo,npts);
lonb=rempoints(lon_nemo,npts);
maskb=rempoints(mask_nemo,npts);
angleb=rempoints(angle,npts);
ub=rempoints(ua,npts);
vb=rempoints(va,npts);
%
%  Rotation
%
cosaa = cos(angleb);
sinaa = sin(angleb);
[Mp,Lp]=size(cosaa);
L=Lp-1;
cosa=0.5*(cosaa(:,1:L)+cosaa(:,2:Lp));
sina=0.5*(sinaa(:,1:L)+sinaa(:,2:Lp));
u = ub.*cosa - vb.*sina;
v = vb.*cosa + ub.*sina;
%
%  Skip
%
[M,L]=size(lonb);
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
lonmin = min(min(lon_nemo));
lonmax = max(max(lon_nemo));
latmin = min(min(lat_nemo));
latmax = max(max(lat_nemo));

month = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'}';
%

magnitude= hypot(Ured,Vred);
%scale=round( magnitude , 2 );

[th,z] = cart2pol(Ured,Vred);
x1=abs(diff(Ured')); x2=abs(diff(Ured)); 
y1=abs(diff(Vred')); y2=abs(diff(Vred));
[~,z1] = cart2pol(x1,y1); [~,z2] = cart2pol(x2,y2);
scalelength=min(mean(z1(~isnan(z1))),mean(z2(~isnan(z2))));
refvar=median(z(~isnan(z)));
roundp=floor(log10(refvar));
refvar=floor(refvar/(10^roundp))*(10^roundp);
vector_scale=round(scalelength/refvar,1);

%
figure
set(gcf, 'Position', [500, 500, 1000, 500]);
disp(' Make a plots Sea Currents...')
m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
h=m_quiver(Lonred,Latred,Ured,Vred,vector_scale,'k','AutoScale','off');
m_coast('patch',[.9 .9 .9],'edgecolor','k','linewidth',1);
m_gshhs_h('save','gumby');
m_usercoast('gumby','patch',[.9 .9 .9]);
m_grid('box','fancy','xtick',8,'ytick',8,'tickdir','out','yaxislocation','left','fontsize',12);
lgd=legend(h,{[num2str(max(max(magnitude)),vector_scale), unit]},'Location','northwest');
%lgd=legend(h,{[num2str(scale),scale, unit]},'Location','northwest');
%lgd=legend(h,{[num2str(scale) unit]},'Location','northwest');
lgd.FontSize = 15;
set(h,'LineWidth',1);
%xlabel('Longitude, (degrees-E)','fontsize',12,'Position', [5.5 0.4 1.00011])
%ylabel('Latitude, (degrees-N)','fontsize',12,'Position', [5.5 0.4 1.00011])
title([titlename '- Month ='  char(month(time_record))],'fontsize',12) 
clear hc h C
disp('save figure in the host directory and folder')
filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
        varanalysis '_' num2str(depth,'%03.0f'), '_', typeanalysis,'_NEMO']; 
saveas(gcf,filename,'jpeg')
return