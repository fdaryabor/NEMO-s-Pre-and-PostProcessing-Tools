function nemo_plot_h(nemo_filename,var_climato,nemo_maskfile,pcolor_jw,label_varname, unit,  ...
                            time_record,sla,Year,varanalysis,typeanalysis,figurepath,four_dim,         ...
                            number_layer,depth,caxis_min,caxis_max,titlename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%label_varname: 'temperature', unit: '(^oC)', 'salinity', unit: 'psu'
%coastfileplot='coastline_l.mat';
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
 
nc_mask = netcdf(nemo_maskfile);
lon = nc_mask{'nav_lon'}(:);
lat = nc_mask{'nav_lat'}(:);
mask2d   = nc_mask{'tmaskutil'}(:);
mask3d   = nc_mask{'tmask'}(:);  
close(nc_mask)

mask2d_nemo=mask2d; mask2d_nemo(mask2d==0)=nan;
mask3d_nemo=mask3d; mask3d_nemo(mask3d==0)=nan;
%
nc=netcdf(nemo_filename);
if four_dim == 1;
    varnemo=(squeeze(nc{var_climato}(time_record,:,:,:))).*mask3d_nemo;
    missval=nc{var_climato}.missing_value(:);
    var=get_missing_val_2d(lon,lat,squeeze(varnemo(number_layer,:,:)),missval,0,NaN);    
else
    varnemo=(squeeze(nc{var_climato}(time_record,:,:))).*mask2d_nemo;
    missval=nc{var_climato}.missing_value(:);
    var=get_missing_val_2d(lon,lat,varnemo,missval,0,NaN);
    if(sla)
        nc_mdt = netcdf(nemo_maskfile);
        MDT=nc_mdt{'mdt'}(:);
        mdt_missing_value=nc_mdt{'mdt'}.missing_value(:);
        mdt=get_missing_val_2d(lon,lat,MDT,mdt_missing_value,0,NaN);
        var=var-mdt;  
        close(nc_mdt),
    end
end
close(nc)
%
lonmin = min(min(lon));
lonmax = max(max(lon));
latmin = min(min(lat));
latmax = max(max(lat));
%
month = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'}';
%month = {'MAM','JJA','SON','DJF'}';
%
if (pcolor_jw)
    figure
    set(gcf, 'Position', [500, 500, 1000, 500]);
    pcolorjw(lon,lat,var); cb=colorbar; title(cb,[{label_varname};{unit}])
    set(gca,'Color',[0.5 0.5 0.5]);
    caxis([caxis_min caxis_max])
    if(sla)
        colormap(redblue)
    else
        colormap(jet)
    end
    colorbar
    hc=colorbar;
    xlabel(hc,[label_varname,  unit],'fontsize',12),
    hold on
    [C,h]=contour(lon,lat,var,'k');
    set(h,'ShowText','on','TextStep',get(h,'LevelStep')*0.5);
    h.LevelStep=0.5;
    clabel(C,h,'fontsize',10,'Color','k','FontWeight','bold')
    hold off
    xlabel('Longitude, (degrees-E)');
    ylabel('Latitude, (degrees-N)');
    grid on
    title([titlename '- Month ='  char(month(time_record))],'fontsize',12) 
    clear hc C h
    %
    disp('save figure in the host directory and folder') 
    if(sla)
        filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
        varanalysis,'_NEMO'];
    else
        filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
                    varanalysis '_' num2str(depth,'%03.0f'), '_', typeanalysis,'_NEMO'];
    end
    set(gcf, 'InvertHardcopy', 'off')
    saveas(gcf,filename,'jpeg')
    %
else
    figure
    set(gcf, 'Position', [500, 500, 1000, 500]);
    m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
    [C,h]=m_contourf(lon,lat,var);
    set(h,'ShowText','on','TextStep',get(h,'LevelStep')*0.5);
    h.LevelStep=0.5;
    clabel(C,h,'fontsize',10,'Color','k','FontWeight','bold')
    set(gca,'Color',[0.5 0.5 0.5]);
    set(gca, 'YScale', 'log');
    set(gca, 'YTickLabel', get(gca,'YTick'))
    m_gshhs_h('save','gumby');
    m_usercoast('gumby','patch',[0.5 0.5 0.5]);
    m_grid('box','fancy','xtick',8,'ytick',8,'tickdir','out','yaxislocation','left','fontsize',12);
    caxis([caxis_min caxis_max])
    if(sla)
        colormap(redblue)
    else
        colormap(jet)
    end
    colorbar
    hc=colorbar;
    hc.FontSize=14;
    xlabel(hc,[label_varname,  unit],'fontsize',12),
    set(gca,'FontSize',18);
    title([titlename '- Month ='  char(month(time_record))],'fontsize',12)  
    clear hc h C
    %
    disp('save figure in the host directory and folder')
    if(sla)
        filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
        varanalysis,'_NEMO'];
    else
        filename = [figurepath, [num2str(Year,4),num2str(time_record,'%02.0f')] '_', ...
                    varanalysis '_' num2str(depth,'%03.0f'), '_', typeanalysis,'_NEMO'];
    end
    set(gcf, 'InvertHardcopy', 'off')
    saveas(gcf,filename,'jpeg')
    %
end

return

