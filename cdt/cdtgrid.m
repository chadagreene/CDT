function [lat,lon] = cdtgrid(res,centerLon)
% cdtgrid uses meshgrid to easily create a global grid of latitudes and longitudes. 
% 
%% Syntax 
% 
%  [lat,lon] = cdtgrid
%  [lat,lon] = cdtgrid(res) 
%  [lat,lon] = cdtgrid([latres lonres])
%  [lat,lon] = cdtgrid(...,centerLon) 
% 
%% Description 
% 
% [lat,lon] = cdtgrid generates a meshgrid-style global grid of latitude and longitude
% values at a resolution of 1 degree. Postings are centered in the middle of grid cells, 
% so a 1 degree resolution grid will have latitude values of 89.5, 88.5, 87.5, etc.  
% 
% [lat,lon] = cdtgrid(res) specifies grid resolution res, where res is a scalar and 
% specifies degrees. Default res is 1.
%
% [lat,lon] = cdtgrid([latres lonres]) if res is a two-element array, the first element 
% specifies latitude resolution and the second element specifies longitude resolution. 
%  
% [lat,lon] = cdtgrid(...,centerLon) centers the grid on longitude value centerLon. Default
% centerLon is the Prime Meridian (0 degrees). 
% 
%% Example 
% For examples type 
% 
%   cdt cdtgrid
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG), February 2017. 
% http://www.chadagreene.com 
% 
% See also: meshgrid, cdtdim, and cdtarea. 

%% Error checks: 

narginchk(0,2) 
nargoutchk(2,2) 

%% Parse inputs: 

if nargin == 0 
   res = [1 1]; 
end

% If the grid has equal resolution in zonal and meridional, change res to make it easier to understand later: 
if numel(res)==1
   res = [res res]; 
   assert(isnumeric(res)==1,'Input error: resolution must be numeric.') 
   assert(numel(res)<=2,'Input error: resolution res must have one or two elements.') 
   assert(max(res)<90,'Error, I assume. Resolution should not exceed 90 degrees.') 
   
   if mod(180,res(1))~=0
      warning('Specified latitude resolution does not evenly divide 180 degrees from pole to pole. Continuing anyway, but the grid will not cover the whole Earth.') 
   end
   
   if mod(360,res(2))~=0
      warning('Specified longitude resolution does not evenly divide 360 degrees around the world. Continuing anyway, but the grid will not cover the whole Earth.') 
   end
end

% Set centerLon to Prime Meridian by default: 
if nargin<2
   centerLon = 0; 
end

%% Generate grid: 

% Create a 1D array of latitude values: 
lat1 = (90-res(1)/2):-res(1):(-90+res(1)/2);

% Create a 1D array of longitude values: 
lon1 = (-180+res(2)/2):res(2):(180-res(2)/2);

% Create a grid: 
[lon,lat] = meshgrid(lon1,lat1); 

% Recenter: 
if centerLon~=0
   lon = lon+centerLon; 
end


end

