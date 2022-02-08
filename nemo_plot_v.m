function nemo_plot_v(nemo_filename,nemo_maskfile,Latitude_Range,Longitude_Range,varname,lon_transect,        ...
                            vartitle_name,unit,time_record,depth_min, depth_max,Year,varanalysis, ...
                            typeanalysis,pcolor_jw,figurepath,caxis_min,caxis_max,titlename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nemo_filename = '/Users/fdaryabor/Preliminary_runs_evaluate_against_climatologies/BS-SIMU_01.2/Grid_T/nemo_output_climato.cdf';
%nemo_maskfile='/Users/fdaryabor/Preliminary_runs_evaluate_against_climatologies/GEO/mesh_mask_bs.nc';
%woafile='/Users/fdaryabor/Preliminary_runs_evaluate_against_climatologies/WOA2005/temp_month.cdf';
%Longitude_Range = [28:40]; Latitude_Range = 44; lon_transect=1;
%four_dim: if 4-dimension variable (t,z,y,x) is for analaysis (switch T or 1),
%otherwise 0 or F.
%varname = 'var_climato'; grid_type='T'; woavar='temperature';, 'salinity';
%vartitle_name='temperature';  unit='(o^C)';
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
month = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'}';
%
nc=netcdf(nemo_maskfile);
lon=nc{'nav_lon'}(:);
lat=nc{'nav_lat'}(:);
mask2d=nc{'tmaskutil'}(:);
mask3d=nc{'tmask'}(:);  
close(nc)
mask2d(mask2d==0)=nan;
mask3d(mask3d==0)=nan;
%
nc=netcdf(nemo_filename);
missval=nc{varname}.missing_value(:);
varnemo=(squeeze(nc{varname}(time_record,:,:,:))).*mask3d;
for k = 1 : length(varnemo(:,1,1))
    vname(k,:,:)=get_missing_val_2d(lon,lat,squeeze(varnemo(k,:,:)),missval,0,NaN);  
end
%

if lon_transect==1;
    [ll_nemo ,depth,var_nemo] = lon_section(nemo_maskfile,Longitude_Range,Latitude_Range,vname);
else
    [ll_nemo ,depth,var_nemo] = lat_section(nemo_maskfile,Longitude_Range,Latitude_Range,vname);
end

if (pcolor_jw)
    figure
    set(gcf, 'Position', [500, 500, 1000, 500]);
    pcolorjw(ll_nemo, -depth,var_nemo);
    set(gca,'Color',[.5 .5 .5])
    colormap(jet)
    caxis([caxis_min caxis_max])
    hold on
    [C,h]=contour(ll_nemo, -depth, var_nemo,'k');
    set(h,'ShowText','on','TextStep',get(h,'LevelStep')*0.5);
    clabel(C,h,'fontsize',10,'Color','k','FontWeight','bold')
    hold off
    clear C h hc
    ylabel('Depth (m)','fontsize',18)
else
    figure
    set(gcf, 'Position', [500, 500, 1000, 500]);
    [C,h]=contourf(ll_nemo, -depth,var_nemo);
    set(h,'ShowText','on','TextStep',get(h,'LevelStep')*0.5);
    h.LevelStep=0.5;
    set(gca,'Color',[.5 .5 .5])
    set(gca, 'YScale', 'log');
    set(gca, 'YTickLabel', get(gca,'YTick'))
    clabel(C,h,'fontsize',10,'Color','k','FontWeight','bold')
    colormap(jet)
    caxis([caxis_min caxis_max])
    clear C h hc
    ylabel('Depth (m)','fontsize',18)
end
grid on
%

if lon_transect==1;
    axis([min(min(ll_nemo)) max(max(ll_nemo)) depth_min depth_max])
    xlabel('Longitude','fontsize',18)
    set(gca,'FontSize',18);
else
    axis([min(min(ll_nemo)) max(max(ll_nemo)) depth_min depth_max])
    xlabel('Latitude','fontsize',18)
    set(gca,'FontSize',18);
end
%
hc=colorbar;
hc.FontSize=14;
xlabel(hc,[vartitle_name  ,   unit],'fontsize',18),
if(lon_transect)
    title({[titlename '- Month ='  char(month(time_record))];   ['Transection at,'  num2str(Latitude_Range) '^o N']},'fontsize',12)
    disp('save figure in the host directory and folder')
    filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
                        varanalysis '_' num2str(Latitude_Range) 'N', '_', typeanalysis,'_NEMO']; 
    set(gcf, 'InvertHardcopy', 'off')
    saveas(gcf,filename,'jpeg')
else
    title({[titlename '- Month ='  char(month(time_record))];   ['Transection at,'  num2str(Longitude_Range) '^o E']},'fontsize',12)
    disp('save figure in the host directory and folder')
    filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
                        varanalysis '_' num2str(Longitude_Range) 'E', '_', typeanalysis,'_NEMO']; 
    set(gcf, 'InvertHardcopy', 'off')                
    saveas(gcf,filename,'jpeg')
end
clear hc

return
