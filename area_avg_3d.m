function [Avg2D] = area_avg_3d(lon, lat, Data,lonbound,latbound)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%IN PUT
%longitude and latitude (matrix or vector 2D).
%lonbound=[lonmin  lonmax] and latbound=[latmin latmax]
% Data to get average (4D ".nc file")
%
%OUT PUT
%Avg (2D area-averaged Data )
%
%exampel:
%[Avg2D] = area_ave( lon, lat, Data, [99.5 116], [-1 14] );
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
idxx = find( lon(1,:) >= lonbound(1) & lon(1,:) <= lonbound(2) );
idxy = find( lat(:,1) >= latbound(1) & lat(:,1) <= latbound(2) );
%
data = Data(:, idxy, idxx );
[tt,mm,nn] = size( data );
for t = 1 : tt
    counter = 0;
    cdata = 0;
    for i = 1 : mm
        for j = 1 : nn
            if isnan( data(t,i,j) ) == 0
                counter = counter + 1;
                cdata = cdata + data(t,i,j);
            end
        end
    end
    Avg2D(t,1) = (cdata/counter);
end
return



