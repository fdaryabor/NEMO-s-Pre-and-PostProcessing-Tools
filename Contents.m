% List of Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Developed by Farshid Daryabor, 2019, CMCC
%Email: farshid.daryabor@cmcc.it
%copyright reserved for any use of Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Average on the area/basin                 ---> area_avg_2d.m
% 2) Average on the area/basin                 ---> area_avg_3d.m
% 3) Water column average in                   ---> column_avg.m
% between of upper and lower values of the desired depth.
% 4) Compute the grid orientation              ---> get_angle.m
% 5) Function to fill                          ---> get_missing_val_2d.m
% the missing points of an horizontal gridded slice
% 6) get mixed layer depth in (m)              ---> get_mld.m
% 7) Projection of the seabed tracers          ---> get_seabed.m
% 8) Converting 2d matrix to 3d matrix         ---> get_tridim.m
% 9) getting uv-vector                         ---> get_uv_vector.m
% 10) computing wind stress from the           ---> get_windstr.m
% meridional and zonal wind components.
% 11) computing wind stress curl from the      ---> get_windstrcurl.m
% meridional and zonal wind components.
% 12) Replacing NaN values with nearst         ---> inpaint_nans.m
% interpolation.                               ---> inpaint_nans3.m
% 13) Extract a vertical slice along latitude  ---> lat_section.m
% 14) Extract a vertical slice along longitude ---> lon_section.m
% 15) plotting NEMO ouput horizontally         ---> nemo_plot_h.m
% 16) plotting NEMO ouput vertically           ---> nemo_plot_v.m
% 17) plotting NEMO vector current             ---> nemo_uvvector.m
% 18) computation of the NEMO's volume         ---> nemo_vol_ke.m
% kinetic energy
% 19) converting 3d SeaDataNet to NEMO grid    ---> SeaData2nemo_3d.m
% 20) converting 3d WOA to NEMO grid           ---> WOA2nemo_3d.m
% 21) converting 2d VAR to NEMO grid           ---> var2nemo_2d.m
% 22) converting the NEMO-T-grid to U-grid     ---> t2u_2d.m, t2u_3d.m
% 22) converting the NEMO-T-grid to V-grid     ---> t2v_2d.m, t2v_3d.m
% 23) converting the NEMO-U-grid to T-grid     ---> u2t_2d.m, u2t_3d.m
% 24) converting the NEMO-V-grid to T-grid     ---> v2t_2d.m, v2t_3d.m