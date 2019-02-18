function [dx,dy] = cdtdim(lat,lon,varargin)
% cdtdim gives the approximate dimensions of each cell in a lat,lon grid assuming an
% ellipsoidal earth. 
% 
%% Syntax 
% 
%  [dx,dy] = cdtdim(lat,lon)
%  [dx,dy] = cdtdim(lat,lon,'km')
% 
%% Description
% 
% [dx,dy] = cdtdim(lat,lon) gives an approximate dimensions in meters of each grid cell given 
% by the geographical coordinate grids lat,lon. Inputs lat and lon must have matching dimensions,
% as if they were created by meshgrid. 
%
% [dx,dy] = cdtdim(lat,lon,'km') gives grid cell sizes in kilometers rather than the default meters.
%
%% Quick Example 
%
% [lon,lat] = meshgrid(-175:10:175,-85:10:85); 
% 
% [dx,dy] = cdtdim(lat,lon,'km'); 
% 
% pcolor(lon,lat,dx)
% cb = colorbar('southoutside'); 
% xlabel(cb,'grid cell zonal width (km)')
% 
%% More examples 
% For more examples, type 
% 
%   cdt cdtdim
%
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG). 
% http://www.chadagreene.com
% 
% See also: cdtarea and cdtcurl. 

%% Error checks: 

narginchk(2,inf) 
assert(isvector(lat)==0,'Input error: lat and lon must be 2D grids as if created by meshgrid.') 
assert(isequal(size(lat),size(lon))==1,'Input error: the dimensions of lat and lon must agree.') 
assert(islatlon(lat,lon)==1,'Input error: Some of the values in lat or lon do not match typical lat,lon ranges. Check inputs and try again.') 

%% Set defaults: 

R = earth_radius(lat,lon); % Earth radius in meters. 

%% Input parsing: 

% If the user wants km outputs: 
if any(strncmpi(varargin,'km',2))
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

%% Calculate dimensions based on dlat and dlon: 

dy = dlat.*R*pi/180;
dx = (dlon/180).*pi.*R.*cosd(lat); 

end
