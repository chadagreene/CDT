function h = globestipple(lat,lon,mask,varargin)
% globestipple creates a hatch filling or stippling over a region of a
% globe. This function is designed primarily to show regions of statistical
% significance in spatial maps.
% 
%% Syntax
% 
%  globestipple(lat,lon,mask) 
%  globestipple(...,MarkerProperty,MarkerValue,...)
%  globestipple(...,'radius',GlobeRadius)
%  globestipple(...,'density',DensityValue) 
%  globestipple(...,'resize',false) 
%  h = globestipple(...)
% 
%% Description
% 
% globestipple(lat,lon,mask) plots black dots on a globe at locations
% defined by lat and lon wherever mask contains true values. The globe has
% radius of 6371, where 6371 corresponds to the average radius of the Earth
% in kilometers. Dimensions of lat, lon, and mask must all match.
% 
% globestipple(...,MarkerProperty,MarkerValue,...) specifies any marker
% properties that are accepted by the plot function (e.g., 'color',
% 'marker', 'markersize', etc).
%  
% globestipple(...,'radius',GlobeRadius) specifies the radius of the globe
% as GlobeRadius.
%
% globestipple(...,'density',DensityValue) specifies density of stippling
% markers. Default density is 100, but if your plot is too crowded you may
% specify a lower density value (and/or adjust the markersize).
% 
% globestipple(...,'resize',false) overrides the 'density' option and plots
% stippling at the exact resolution of the input grid. By default, the
% grids are resized because any grid larger than about 100x100 would
% produce so many stippling dots it would black out anything under them.
% 
% h = globestipple(...) returns a handle of the plotted stippling objects.
% 
%% Examples
% For examples type 
% 
%  cdt globestipple
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for Climate Data Tools for Matlab, 2019. 
% 
% See also: globeplot. 
%
%% Error checks: 

narginchk(3,Inf) % asserts at least three inputs. 
assert(islatlon(lat,lon),'The first two inputs in globeplot must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')
assert(islogical(mask)==1,'Error: Input mask must be logical, where 1 corresponds to desired areas of stippling.') 

%% Set defaults: 

density = 100; 
resize = true; 

%% Input parsing: 

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
else
   radius = 6371; % the default radius, corresponding to the average Earth radius in kilometers.
end

tmp = strncmpi(varargin,'density',3); 
if any(tmp)
   density = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1)=1; 
   varargin = varargin(~tmp); 
   assert(isscalar(density)==1,'Input error: Density value must be a scalar. Default density is 100.') 
end

tmp = strncmpi(varargin,'resize',3); 
if any(tmp)
   resize = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1)=1; 
   varargin = varargin(~tmp); 
   assert(islogical(resize),'Input error: Resize option must be true or false. Default is true.') 
end

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius);

%% Resize the grids: 

if resize 
   % Density is 100 by default, meaning hypot(Nrows,Ncols) will be 100. 
   InputDensity = hypot(size(mask,1),size(mask,2)); 

   sc = density/InputDensity; % scaling factor to convert InputDensity to desired density.

   % Resize the grids: 
   x = imresize(x,sc);
   y = imresize(y,sc);
   z = imresize(z,sc);
   mask = imresize(mask,sc); 

   % Remove every other grid cell in a checkerboard fashion: 
   checker = true(size(mask)); 
   checker(1:2:end,1:2:end) = false; 
   checker(2:2:end,2:2:end) = false; 
   mask = mask & checker; 
end

%% Plot it up: 

if ~ishold
   view(3)
   hold on
end

h = plot3(x(mask),y(mask),z(mask),'k.',varargin{:}); 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Clean up: 

if nargout==0
   clear h
end

end