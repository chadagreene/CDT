function tf = island(lat,lon) 
% island returns true for any geolocations that are land.
% 
%% Syntax
% 
%  tf = island(lat,lon)
% 
%% Description 
% 
% tf = island(lat,lon) uses a 1/8 degree resolution global land mask to determine
% whether the geographic location(s) given by lat,lon correspond to land or water.
% Output is true for land locations, false otherwise. 
% 
%% Examples 
% For examples type 
% 
%    cdt island
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas Institute for Geophysics
% (UTIG). http://www.chadagreene.com. 
% 
% See also dist2coast, geomask, and topo_interp. 

%% Error checks: 

assert(nargin==2,'Input error: island requires exactly two inputs.') 
assert(isequal(size(lat),size(lon))==1,'Input error: Dimensions of lat and lon must match.')
assert(islatlon(lat,lon)==1,'Input error: Coordinates must be in the normal range of lat,lon values.') 

%% Wrap longitudes: 
% If any values exceed 180, subtract 360 from them to keep everything in the -180 to 180 range.

ind = lon>180; 
lon(ind) = lon(ind)-360; 

%% Load data: 

L = load('land_mask.mat','land','lat','lon');

%% Interpolate: 

tf = interp2(L.lon,L.lat,L.land,lon,lat,'nearest',0); 

end
