function [mld]=get_mld(salt,temp,Z,pres,dep_ref,dT,dens,tmp,pden,ptmp)

% It is quasi homogeneous layer in the upper ocean where variation of density is negligible. 

% MLD in density with a variable threshold criterion (equivalent to a 0.2?C decrease) 
%depth refrence, surface 
%dT:
%MLD in temperature with a fixed threshold criterion (0.2 oC) 
%MLD in density with a fixed threshold criterion (0.03 kg/m3) 
%This mixed layer depth is a Temperature-Mixed Layer Depth, or Isothermal
%Layer Depth. It is reminded that T?C inversions are NOT contained into this isothermal layer! 
%We estimate this MLD, named MLD_DT02, from a fixed threshold on temperature
%profiles. The criterion is the following :
%MLD_DT02 = depth where (? = ?10m ? 0.2 ?C)
%http://www.ifremer.fr/cerweb/deboyer/mld/Surface_Mixed_Layer_Depth.php
%dens switch for estimation MLD in density and tmp switch in temperature
%pden,ptmp are respectively swith for computation of Potential density and temperature

% PREREQUISITE: you must have installed SW Package or you must have
% following function from Sea Water package
% sw_den.m ; sw_dens.m; sw_dens0.m; sw_seck.m; sw_smow.m
% 
% DESCRIPTION:  This function determines Mixed Layer Depth (MLD) from profile data
% sets based on subjective method. If you have 3D data sets i.e. level, lat and lon and want 
% to compute the MLD, then this function will be very handy. Because this function is 
% specifically designed for those cases. However, it can evaluate MLD from profile data too.
% 
%
% INPUTS: 
% salt = Salinity profiles over the study region [psu], either 3D or vector
% temp = Temperature profiles over the study region [deg. C], either 3D or vector
% Z = Levels [m], Must be vector
% dT = threshold value in temperature difference criterion [deg. C] or density [kg/m3], Must be scalar
% pres, sea pressure; z10,swithch for defination of deep ref [1] at 10 m [0] surface
% dens, switch to estimate in density [1]; tmp, switch to estimate in temperature [1]
% pden, swith to calculation of potential density if dens is [1],
% ptmp, swith to calculation of potential temperature if tmp is [1],
%
%
% OUTPUT: 
% mld = mixed layer depth, spatial output [m]
%
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
% ***********************************************************************************************%

% Taking care of sufficient input agrument
if ((nargin < 3) || (nargin > 10))
   error('get_mld.m: Must pass minimum 3 parameters')
end 
% Optional value
if (nargin == 3)
    pres=[];
    dT=[];
    dens=[];
    tmp=[];
    pden=[];
    ptmp=[];
    str='You are using DEFAULT value for the threshold value; dT = 1';
    warning(['get_mld.m: ', str])  
end
if (isempty(dT))
    dT=1; % desire temperature difference criterion (deltaT)
end
%
% Check : S & T & P must have same shape
% n1, n2, n3 stands for level, latitude and longitude respectively. 
[sn1, sn2, sn3]=size(salt); 
[tn1, tn2, tn3]=size(temp); 
[pn1, pn2, pn3]=size(pres); 

if isequal(size(salt),size(temp),size(pres))
   lt=sn2; 
   ln=sn3;
else
   disp('salt , temp and pres are not the same size.')
   lt=[]; 
   ln=[];
end
%
N=length(squeeze(Z(:,1,1)));
if ((sn1 ~= N) || (tn1 ~= N) || (pn1 ~= N))
    error('get_mld.m: Check_Z - level must be same as ')
end
if (numel(dT) ~= 1)
    error('get_mld.m: DT must be scalar');
end
%
% Post processing of the Data sets

% Salinity data
S=reshape(salt, sn1, sn2*sn3);
land=isnan(salt(1, :));       % Land portion location
S(:,land)=[];                 % removing land data
[sn4, sn5]=size(S);
%
% Temp data
T=reshape(temp, tn1, tn2*tn3);
oce= ~isnan(temp(1, :));      % Not land portion since land portion is NAN
land=isnan(temp(1, :));       % Land portion location
T(:, land)=[];                % removing land data
[tn4, tn5]=size(T);
%
% Pres data
P=reshape(pres, pn1, pn2*pn3);
land=isnan(pres(1, :));       % Land portion location
P(:,land)=[];                 % removing land data
[pn4, pn5]=size(P);
%
% Check dimension of S & T & P for oceanic portion
if (((sn4 == tn4) && (sn4 == pn4)) && ...
                        ((sn5 == tn5) && (sn5 == pn5)))
    n5=sn5; 
else
    error('get_mld.m: Oceanic portion of data set is not same')
end
%
%taking dep ref
hz=P;
valz = dep_ref;              % Dep ref at 10 m (Defult at 10 m)
[dz, iz0] = min( abs( hz(:,1) - valz ) );
%
% Mixed Layer Depth computation
mldepth=NaN(n5, 1);
for ii=1:n5
    s=S(:, ii);
    t=T(:, ii);
    p=P(:, ii);
    z=hz(:, ii);
    sst_dT=t(iz0) - dT;
    if dens == 1;
        disp('')
        disp('Estimation of MLD in density')
        if(pden)
            disp('')
            disp('computation of Potential density')
            sigma_t =sw_pden(s,t,p,0)-1000;
            sigma_dT=sw_pden(s(iz0),sst_dT,p(iz0),0)-1000;
        else
            disp('')
            disp('computation of density')
            sigma_t =sw_dens(s, t, 0) - 1000;
            sigma_dT=sw_dens(s(iz0), sst_dT, 0) - 1000;
        end
    elseif tmp == 1;
        disp('')
        disp('Estimation of MLD in temperature')
        if(ptmp)
            disp('')
            disp('computation of Potential temperature')
            sigma_t  = sw_ptmp(s,t,p,0);
            sigma_dT = sw_ptmp(s(iz0),sst_dT,p(iz0),0);
        else
            disp('')
            disp('Potential temperature is already existed')
            sigma_t  = t;
            sigma_dT = sst_dT;
        end
    end 
    pos1=find(sigma_t > sigma_dT);
    if ((numel(pos1) > 0) && (pos1(1) > 1))
        p2=pos1(1);
        p1=p2-1;
        mldepth(ii)=interp1(sigma_t([p1, p2]), z([p1, p2]), sigma_dT);
    else
        mldepth(ii)=NaN;
    end 
end 
mld=NaN*ones(1, lt*ln);
mld(oce)=mldepth;
mld=reshape(mld, lt, ln);
mld=inpaint_nans(mld,1);
%mld=mld.*mask;
return