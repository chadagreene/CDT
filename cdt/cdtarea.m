function A = cdtarea(lat,lon,varargin)
% cdtarea gives the approximate area of each cell in a lat,lon grid assuming an ellipsoidal
% Earth. This function was designed to enable easy area-averaged weighting of large gridded 
% climate datasets.  
% 
%% Syntax 
% 
%  A = cdtarea(lat,lon)
%  A = cdtarea(lat,lon,'km2')
% 
%% Description
% 
% A = cdtarea(lat,lon) gives an approximate area of each grid cell given by lat,lon. Inputs
% lat and lon must have matching dimensions, as if they were created by meshgrid. 
%
% A = cdtarea(lat,lon,'km2') gives grid cell area in square kilometers. 
%
%% Examples 
% For examples type 
% 
%   cdt cdtarea 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG). 
% 
% See also: cdtdim and cdtcurl. 

%% Error checks: 

narginchk(2,inf) 
assert(isvector(lat)==0,'Input error: lat and lon must be 2D grids as if created by meshgrid.') 
assert(isequal(size(lat),size(lon))==1,'Input error: the dimensions of lat and lon must agree.') 
assert(islatlon(lat,lon)==1,'Input error: Some of the values in lat or lon do not match typical lat,lon ranges. Check inputs and try again.') 

%% Set defaults: 

R = earth_radius(lat,lon); % Earth radius in meters

%% Input parsing: 

% If the user wants km^2 outputs: 
if any(strncmpi(varargin,'km2',2)); 
   R = R/1000; 
end

%% Determine grid sizes dlat and dlon: 

[dlat1,dlat2] = gradient(lat); 
[dlon1,dlon2] = gradient(lon); 

% We don't know if lat and lon were created by [lat,lon] = meshgrid(lat_array,lon_array) or [lon,lat] = meshgrid(lon_array,lat_array) 
% but we can find out: 

if isequal(dlat1,zeros(size(lat)))
   dlat = dlat2; 
   dlon = dlon1; 
   assert(isequal(dlon2,zeros(size(lon)))==1,'Error: lat and lon must be monotonic grids, as if created by meshgrid.') 
else
   dlat = dlat1; 
   dlon = dlon2; 
   assert(isequal(dlon1,dlat2,zeros(size(lon)))==1,'Error: lat and lon must be monotonic grids, as if created by meshgrid.') 
end

%% Calculate area based on dlat and dlon: 

dy = dlat.*R*pi/180;
dx = (dlon/180).*pi.*R.*cosd(lat); 

A = double(abs(dx.*dy)); 

end
