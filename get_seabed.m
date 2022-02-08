function desired_var=get_seabed(maskfile,tracer,desired_depth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projection of the seabed tracers with replacing NaN's in a vector field (var2d)
% with the nearest value. tracer can be salinity or temperture 
% desired_depth, favorit depth to project from the sea surface
% Farshid Daryabor, CMCC, Email: farshid.daryabor@cmcc.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc = netcdf(maskfile);
dept1d = nc{'nav_lev'}(:);
mask2d = nc{'tmaskutil'}(:);
close(nc)
mask2d(mask2d==0)=NaN;
%
A = reshape(tracer,[],1);
lo = ~isnan(tracer);
ii = find(lo);
C = interp1(ii,A(lo),(1:numel(A))','previous');
var_out = reshape(C,size(tracer));
if nargin == 2;
    desired_var=(squeeze(var_out(end-1,:,:))).*mask2d;
else
    [~,iiix] = (min(abs(dept1d - desired_depth)));
    desired_var=(squeeze(var_out(iiix-1,:,:))).*mask2d;
end
return



