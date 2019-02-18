function h = stipple(x,y,mask,varargin)
% stipple creates a hatch filling or stippling within a grid. This
% function is designed primarily to show regions of statistical 
% significance in spatial maps. 
% 
%% Syntax
% 
%  stipple(x,y,mask) 
%  stipple(...,MarkerProperty,MarkerValue,...)
%  stipple(...,'density',DensityValue) 
%  stipple(...,'resize',false) 
%  h = stipple(...)
% 
%% Description
% 
% stipple(x,y,mask) plots black dots in x,y locations wherever a mask contains
% true values. Dimensions of x, y, and mask must all match. 
% 
% stipple(...,MarkerProperty,MarkerValue,...) specifies any marker properties
% that are accepted by the plot function (e.g., 'color', 'marker', 'markersize', etc). 
%  
% stipple(...,'density',DensityValue) specifies density of stippling markers. 
% Default density is 100, but if your plot is too crowded you may specify a 
% lower density value (and/or adjust the markersize). 
% 
% stipple(...,'resize',false) overrides the 'density' option and plots stippling 
% at the exact resolution of the input grid. By default, the grids are resized
% because any grid larger than about 100x100 would produce so many stippling
% dots it would black out anything under them. 
% 
% h = stipple(...) returns a handle of the plotted stippling objects. 
% 
%% Examples
% For examples, type 
% 
%  cdt stipple
% 
%% Author Info
% This function was written by Chad A. Greene, August 2018. 
% 
% See also: stipplem.

%% Error checks: 

narginchk(3,inf)

% Turn vectors into grids: 
if all([isvector(x) isvector(y)])
   [x,y] = meshgrid(x,y); 
end

assert(isequal(size(x),size(y),size(mask))==1,'Error: Dimensions of x, y, and mask must agree. Check inputs, or use [x,y] = meshgrid(x,y) if necessary.')
assert(islogical(mask)==1,'Error: Input mask must be logical, where 1 corresponds to desired areas of stippling.') 

%% Set defaults: 

density = 100; 
resize = true; 

%% Input parsing: 

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

%% Resize the grids: 

if resize 
   % Density is 100 by default, meaning hypot(Nrows,Ncols) will be 100. 
   InputDensity = hypot(size(mask,1),size(mask,2)); 

   sc = density/InputDensity; % scaling factor to convert InputDensity to desired density.

   % Resize the grids: 
   x = imresize(x,sc);
   y = imresize(y,sc); 
   mask = imresize(mask,sc); 

   % Remove every other grid cell in a checkerboard fashion: 
   checker = true(size(mask)); 
   checker(1:2:end,1:2:end) = false; 
   checker(2:2:end,2:2:end) = false; 
   mask = mask & checker; 
end

%% Plot it up: 

h = plot(x(mask),y(mask),'k.',varargin{:}); 

%% Clean up: 

if nargout==0
   clear h
end

end