function Cz = cdtcurl(lat,lon,U,V)
% cdtcurl calculates the z component of curl for gridded vectors on an ellipsoidal Earth.
% 
%% Syntax 
% 
%  Cz = cdtcurl(lat,lon,U,V)
% 
%% Description
% 
% Cz = cdtcurl(lat,lon,U,V) uses cdtdim to estimate the dimensions of each grid cell in the 
% lat,lon grid, then computes the curl of the gridded vectors U,V. 
%
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG). 
% 
% See also: curl, cdtgradient, ekman, and cdtdim. 

%% Error checks: 

narginchk(4,4) 
assert(isvector(lat)==0,'Input error: lat and lon must be 2D grids as if created by meshgrid.') 
assert(isequal(size(lat),size(lon))==1,'Input error: the dimensions of lat and lon must match.') 
assert(isequal(size(U),size(V))==1,'Input error: the dimensions of U and V must match.') 
assert(isequal(size(lat),[size(U,1) size(U,2)])==1,'Input error: the dimensions of lat and lon do not appear to match U and V.') 
assert(ismatrix(lat)==1,'Input error: lat and lon must be 2D matrices that correspond to the size of U and V.') 
assert(islatlon(lat,lon)==1,'Input error: Some of the values in lat or lon do not match typical lat,lon ranges. Check inputs and try again.') 

%% Change grid orientation if necessary: 
% Some grids are created like [lon,lat] = meshgrid(-180:180,-90:90) while others are created like 
% [lat,lon] = meshgrid(-90:90,-180:180). For consistency, let's permute the [lat,lon] types into [lon,lat] types: 

% An overview of gridtypes appears in the recenter function
gridtype = [sign(diff(lon(2,1:2))) sign(diff(lat(1:2,1))) sign(diff(lat(2,1:2))) sign(diff(lon(1:2,1)))]; 

if isequal(abs(gridtype),[1 1 0 0])
   % This means it's the [lon,lat] type, and we're good to keep going.
   permutedims = false; 
   
elseif isequal(abs(gridtype),[0 0 1 1])
   lat = permute(lat,[2 1 3]); 
   lon = permute(lon,[2 1 3]); 
   U = permute(U,[2 1 3]); 
   V = permute(V,[2 1 3]); 
   permutedims = true; 
else
   error('Unrecognized lat,lon grid type. It should be monotonic, like it was created by meshgrid.') 
end

%% Estimate grid size: 

[dx,dy] = cdtdim(lat,lon);

%% Calculate curlz:

% Preallocate curlz
Cz = nan(size(U)); 

% curlz is dV/dx - dU/dy, so solve it for each slice of U,V: 
for k = 1:size(U,3)
   [~,dUdy] = gradient(U(:,:,k)./dy);
   [dVdx,~] = gradient(V(:,:,k)./dx);
   Cz(:,:,k) = dVdx-dUdy; 
end

%% Return to original grid orientation if we changed it: 

if permutedims 
   Cz = ipermute(Cz,[2 1 3]); 
end

end
