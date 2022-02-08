clear all
close all
clc

% Program for checking open boundary conditions at the Bosporus
ndepth=121;
modDir='/Users/sciliberti/Documents/07-BS-EXP/bs-simu_3.6/obc_votemper';
ff = '/Users/sciliberti/Documents/20-BS-PHY/Bathymetry/mesh_mask_BSFS_simu_3.0.nc'; %mesh_mask_Apr19_rev.nc'; %mesh_mask_BSFS_simu_3.0.nc';
depth = nc_varget(ff, 'nav_lev');
modName='votemper_obc_48_14_*.nc';
modFile=fullfile(modDir,modName);
cd /Users/sciliberti/Documents/07-BS-EXP/bs-simu_3.6/obc_votemper;
dinfo = dir(modFile);
filenames_mod = {dinfo.name};
sorted_filenames_mod = natsortfiles(filenames_mod)';

% Hovmoller data structure
hov_temp = zeros(ndepth,numel(sorted_filenames_mod));
for ii = 1:numel(sorted_filenames_mod);
    mod_file = (fullfile(modDir,char(sorted_filenames_mod(ii))));
    hov_temp(:,ii) = nc_varget(mod_file,'votemper');
end
depth(hov_temp(:,1)==0.0)=nan;
hov_temp(hov_temp==0.0)=nan;
t1 = datetime(2014,1,1);
t2 = datetime(2017,12,31);
tx = t1:t2;
figure (1)
set(gcf, 'Position', [500, 500, 1500, 500]);
pcolor(datenum(tx),-depth,(hov_temp));shading flat;colorbar
caxis([5 28]);
ylim([-60 0])
datetick('x', 'yyyy-mm',  'keepticks')
ylabel('depth (m)')
xlabel('time')
set(gca,'FontSize',15);
title('Hovmoller diagram for temperature @ Bosporus - BS-PHY model conf') 
