function [K_e]=nemo_vol_ke(maskfile,ufname,vfname,tfname,tindex,        ...
                            Llon,Rlon,Blat,Tlat,delta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2018 Farshid Daryabor CMCC.                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [K_e]=nemo_vol_ke(maskfile,NEMODIR,Year,tindex, ...              %
%                                   Llon,Rlon,Blat,Tlat,delta)              %
%                                                                           %
% This function computes the volume integral Kinetic energy for the         %
% entire domain or specified region.                                        %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    maskfile    mesh_mask NetCDF file name (character string).             %
%    ufname      u-field NetCDF file name (character string).               %
%    vfname      v-field NetCDF file name (character string).               %
%    tfname      temp-salt-field NetCDF file name (character string).       %
%    tindex      Time records to process (integer; scalar or vector).       %
%                  If tindex is a vector, the data will integrated          %
%                  over requested time records.                             %
%    Llon        Left corner longitude (East values are negative).          %
%    Rlon        Right corner longitude (East values are negative).         %
%    Blat        Bottom corner latitude (South values are negative).        %
%    Tlat        Top corner latitude (South values are negative).           %
%    delta       Horizontal grid spacing to interpolate (degrees).          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    KE          Volume kinetic energy data (structure array).              %
%                                                                           %
%                  K_e:   kinetic energy (Joules/m2)                        %
%                  KE.area:    total area (m2)                              %
%                  KE.volume:  total volume (m3)                            %
%                                                                           % 
%The total energy density present in a system is equal to the initial       %
%energy plus the energy supplied by the external forces minus the energy    %
%lost by mixing process. This kind of conservation energy is not trivial    %
%in a terrain-following coordinates model. We should always look at these   %
%diagnostics as approximated quantities and not as an energy conservation   %
%statement. They are useful to determine if the model blowing-up and to     %
%check the behavior of the total basin volume. They are also useful in      %
%spin-up problems. Recall, that we are computing a volume integral, which   %
%requires special parallel considerations.                                  %
%                                                                           %
% for example:                                                              %
%NEMODIR = '/Users/fdaryabor/Preliminary_runs_evaluate_against_climatologies/2019/BS-SIMU_01.3/';
%Year=2014;                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

method='linear';

% Activate interpolation switch.

if (nargin > 5),
  interpolate=1;
else
  interpolate=0;
end,

%----------------------------------------------------------------------------
% Read in grid data.
%----------------------------------------------------------------------------

% Read in horizontal curvilinear metrics.

nc = netcdf(maskfile);

e1 = nc{'e1t'}(:); 
e2 = nc{'e2t'}(:); 
e3 = nc{'e3t'}(:);
[Np,Lp,Mp]=size(e3);
L=Lp-1;
M=Mp-1;
N=Np-1;

% Read in horizontal positions.

lon=nc{'nav_lon'}(:);
lon=0.25.*(lon(1:L,1:M)+lon(2:Lp,1:M)+                                  ...
            lon(1:L,2:Mp)+lon(2:Lp,2:Mp));

lat=nc{'nav_lat'}(:);
lat=0.25.*(lat(1:L,1:M)+lat(2:Lp,1:M)+                                  ...
            lat(1:L,2:Mp)+lat(2:Lp,2:Mp));


% Read in Land/Sea mask.

tmsk=nc{'tmaskutil'}(:);
msk1=0.25.*(tmsk(1:L,1:M)+tmsk(2:Lp,1:M)+tmsk(1:L,2:Mp)+                ...
                    tmsk(2:Lp,2:Mp));
msk=msk1; msk(msk1>0 & msk1<1)=1;


tmask=squeeze(nc{'tmask'}(1,:,:,:)); 
mask1=0.25.*(tmask(:,1:L,1:M)+tmask(:,2:Lp,1:M)+                        ...
               tmask(:,1:L,2:Mp)+tmask(:,2:Lp,2:Mp));

mask = 0.5.*(mask1(2:Np,:,:)+mask1(1:Np-1,:,:));
                    
close(nc)


% Compute grid spacing at PSI-points.


gx=0.25.*(e1(1:L,1:M)+e1(2:Lp,1:M)+e1(1:L,2:Mp)+e1(2:Lp,2:Mp));
dx=reshape(gx,1,L,M);
dx=repmat(dx,[N 1 1]);

gy=0.25.*(e2(1:L,1:M)+e2(2:Lp,1:M)+e2(1:L,2:Mp)+e2(2:Lp,2:Mp));
dy=reshape(gy,1,L,M);
dy=repmat(dy,[N 1 1]);


gz=0.25.*(e3(:,1:L,1:M)+e3(:,2:Lp,1:M)+                        ...
               e3(:,1:L,2:Mp)+e3(:,2:Lp,2:Mp));
dz = 0.5.*(gz(2:Np,:,:)+gz(1:Np-1,:,:));



dxdy = gx.*gy.*msk;

dxdydz = dx.*dy.*dz.*mask;

clear gx gy msk

% Set grid to interpolate horizontally.

if (interpolate),
  x=Llon:delta:Rlon; x=x';
  Im=length(x);
  y=Blat:delta:Tlat;
  Jm=length(y);

  Xi=x(:,ones([1 Jm]));
  Yi=y(ones([1 Im]),:);
end,

% Get total volume for the analyzed area.

if (interpolate),
  F2d=sum(dxdydz,3);
  Fint=interp2(lon',lat',F2d',Xi,Yi,method);
  KE.volume=(sum(sum(Fint)));
  clear F2d Fint
  Fint=interp2(lon',lat',dxdy',Xi,Yi,method);
  KE.area=sum(sum(Fint));
  clear Fint
else
  KE.volume=sum(sum(sum(dxdydz)));
  KE.area=sum(sum(dxdy));
end,

clear dx dxdy dy dz mask 

%----------------------------------------------------------------------------
% Volume integrate requested variable.
%----------------------------------------------------------------------------

%  Read in velocities and density

for Trec = 1 : length(tindex)
    
    nc_u = netcdf(ufname);
    u =  squeeze(nc_u{'vozocrtx'}(Trec,:,:,:)); 
    close(nc_u)
    
    nc_v = netcdf(vfname);
    v =  squeeze(nc_v{'vomecrty'}(Trec,:,:,:));
    close(nc_v)
    
    nc_ts = netcdf(tfname);
    temp = squeeze(nc_ts{'votemper'}(Trec,:,:,:));
    salt = squeeze(nc_ts{'vosaline'}(Trec,:,:,:));
    close(nc_ts)
    rho =  rho_pot(temp,salt);
        
%  Compute kinetic energy at PSI-points (J/m2).
        
    ke = 0.25.*(rho(:,1:L,1:M)+rho(:,2:Lp,1:M)+ ...
                rho(:,1:L,2:Mp)+rho(:,2:Lp,2:Mp)).* ...
             0.25.*((u(:,1:L,1:M)+u(:,1:L ,2:Mp)).* ...
                     (u(:,1:L,1:M)+u(:,1:L ,2:Mp))+ ...
                     (v(:,1:L,1:M)+v(:,2:Lp,1:M)).* ...
                        (v(:,1:L,1:M)+v(:,2:Lp,1:M)));
    
    ke = 0.5.*(ke(2:Np,:,:)+ke(1:Np-1,:,:)); 
    
    ke=ke.*dxdydz;

%  Integrate vertically and interpolate to requested area, if any.
        
    if (interpolate),
        F=sum(ke,3);
        F2d=interp2(lon',lat',F',Xi,Yi,method);
        clear F
    else
        F2d=sum(ke,3);
    end,

%  Integrate horizontally and divide by area so units are J/m2.
        
    K_e(Trec)=sum(sum(F2d))*0.5/KE.area;
end,

return
