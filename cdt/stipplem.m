function h = stipplem(lat,lon,mask,varargin)
% stipplem creates a hatch filling or stippling in map coordinates. 
% 
%% Syntax
% 
%  stipplem(lat,lon,mask) 
%  stipplem(...,MarkerProperty,MarkerValue,...)
%  stipplem(...,'density',DensityValue) 
%  stipplem(...,'resize',false) 
%  h = stipplem(...)
% 
%% Description
% 
% stipplem(lat,lon,mask) plots black dots in x,y locations wherever a mask contains
% true values. Dimensions of x, y, and mask must all match. 
% 
% stipplem(...,MarkerProperty,MarkerValue,...) specifies any marker properties
% that are accepted by the plot function (e.g., 'color', 'marker', 'markersize', etc). 
%  
% stipplem(...,'density',DensityValue) specifies density of stippling markers. 
% Default density is 100, but if your plot is too crowded you may specify a 
% lower density value (and/or adjust the markersize). 
% 
% stipplem(...,'resize',false) overrides the 'density' option and plots stippling 
% at the exact resolution of the input grid. By default, the grids are resized
% because any grid larger than about 100x100 would produce so many stippling
% dots it would black out anything under them. 
% 
% h = stipplem(...) returns a handle of the plotted stippling objects. 
% 
%% Author Info
% This function was written by Chad A. Greene in 2019. 
% 
% See also: stipple and globestipple. 

%% Input wrangling: 

assert(islatlon(lat,lon),'Error: input coordinates appear to be outside the normal range of latitudes and longitudes.') 

% If inputs are arrays, try meshgridding them: 
if all([isvector(lat) isvector(lon)])
   [lon_tmp,lat_tmp] = meshgrid(lon,lat); 

   % If that didn't make the grids line up, try the other way:
   if isequal(size(lat_tmp),size(mask))
      lat = lat_tmp; 
      lon = lon_tmp; 
   else
      [lat,lon] = meshgrid(lat,lon); 
   end
end

% If the grids still don't line up, throw an error: 
assert(isequal(size(lat),size(lon),size(mask)),'Error: Dimensions of lat, lon, and mask do not agree.') 

%% Do coordinate transform: 

[x,y] = mfwdtran(lat,lon); 

%% Do the plotting: 

hold on
h = stipple(x,y,mask,varargin{:}); 

%% Clean up: 

if nargout==0
   clear h
end

end