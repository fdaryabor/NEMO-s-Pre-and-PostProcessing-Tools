function [Avg1D] = area_avg_2d(lon, lat, Data,lonbound,latbound)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%IN PUT
%longitude and latitude (matrix or vector 2D).
%lonbound=[lonmin  lonmax] and latbound=[latmin latmax]
% Data to get average (3D ".nc file")
%
%OUT PUT
%Avg (1D area-averaged Data )
%
%exampel:
%[Avg1D] = area_ave( lon, lat, Data, [99.5 116], [-1 14] );
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idxx = find( lon(1,:) >= lonbound(1) & lon(1,:) <= lonbound(2) );
idxy = find( lat(:,1) >= latbound(1) & lat(:,1) <= latbound(2) );
%
data = Data(idxy,idxx);
[mm, nn] = size(data);
counter = 0;
cdata = 0;
for i = 1 : mm
    for j = 1 : nn
        if isnan( data(i,j) ) == 0
            counter = counter + 1;
            cdata = cdata + data(i,j);
        end
    end
end
Avg1D = cdata/counter;
return

