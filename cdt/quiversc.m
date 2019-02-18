function h = quiversc(x,y,u,v,varargin)
% quiversc scales a dense grid of quiver arrows to comfortably fit in axes
% before plotting them.
% 
%% Syntax
% 
%  quiversc(x,y,u,v)
%  quiversc(...,'density',DensityValue)
%  quiversc(...,scale)
%  quiversc(...,LineSpec)
%  quiversc(...,LineSpec,'filled')
%  quiversc(...,'Name',Value)
%  h = quiversc(...)
% 
%% Description 
% 
% quiversc(x,y,u,v) plots vectors as arrows at the coordinates specified in 
% each corresponding pair of elements in x and y. The matrices x, y, u, and 
% v must all be the same size and contain corresponding position and velocity
% components. By default, the arrows are scaled to just not overlap, but you 
% can scale them to be longer or shorter if you want.
% 
% quiversc(...,'density',DensityFactor) specifies density of quiver arrows. The 
% DensityFactor defines how many arrows are plotted. Default DensityFactor is 
% 50, meaning hypot(Nrows,Ncols)=50, but if your plot is too crowded you may 
% specify a lower DensityFactor (and/or adjust the markersize). 
% 
% quiversc(...,scale) automatically scales the length of the arrows to fit within 
% the grid and then stretches them by the factor scale. scale = 2 doubles their 
% relative length, and scale = 0.5 halves the length. Use scale = 0 to plot the 
% velocity vectors without automatic scaling. You can also tune the length of 
% arrows after they have been drawn by choosing the Plot Edit tool, selecting 
% the quiver object, opening the Property Editor, and adjusting the Length slider.
% 
% quiversc(...,LineSpec) specifies line style, marker symbol, and color using 
% any valid LineSpec. quiversc draws the markers at the origin of the vectors.
% 
% quiversc(...,LineSpec,'filled') fills markers specified by LineSpec.
% 
% quiversc(...,'Name',Value) specifies property name and property value pairs
% for the quiver objects the function creates.
% 
% h = quiversc(...) returns the quiver object handle h. 
% 
%% Examples 
% For examples, type 
% 
%  cdt quiversc 
% 
%% Author Info
% This function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 
% 
% See also: quiver

%% Input parsing: 

% Turn vectors into grids: 
if all([isvector(x) isvector(y)])
   [x,y] = meshgrid(x,y); 
end

% Ensure all the dimensions match: 
assert(isequal(size(x),size(y),size(u),size(v))==1,'Error: Dimensions of x, y, u, and v must all agree. Check inputs, or use [x,y] = meshgrid(x,y) if necessary.')

% Check for user-defined density: 
tmp = strncmpi(varargin,'density',3); 
if any(tmp)
   density = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1)=1; 
   varargin = varargin(~tmp); 
   assert(isscalar(density)==1,'Input error: Density value must be a scalar. Default density is 100.') 
else 
   density = 50; 
end

%% Resize the grids: 

% Density is 50 by default, meaning hypot(Nrows,Ncols) will be 50. 
InputDensity = hypot(size(x,1),size(x,2)); 

sc = density/InputDensity; % scaling factor to convert InputDensity to desired density.

if ~isnan(sc)

   % First, scale by nearest-neighbor:
   xn = imresize(x,sc,'nearest');
   yn = imresize(y,sc,'nearest');
   un = imresize(u,sc,'nearest');
   vn = imresize(v,sc,'nearest');

   % For most of the grid we'll use default bicubic though: 
   x = imresize(x,sc);
   y = imresize(y,sc); 
   u = imresize(u,sc); 
   v = imresize(v,sc); 

   % But fill in NaNs with nearest-neighbor results b/c otherwise coastal areas would be decimated: 
   x(isnan(x)) = xn(isnan(x)); 
   y(isnan(y)) = yn(isnan(y)); 
   u(isnan(u)) = un(isnan(u)); 
   v(isnan(v)) = vn(isnan(v)); 
end

if false
   % Remove every other grid cell in a checkerboard fashion: 
   % This functionality is turned off, but could easily be added as an
   % option in a future release. 
   checker = true(size(x)); 
   checker(1:2:end,1:2:end) = false; 
   checker(2:2:end,2:2:end) = false; 
   x(checker) = NaN; 
   y(checker) = NaN; 
   u(checker) = NaN; 
   v(checker) = NaN; 
end

%% Plot

h = quiver(x,y,u,v,varargin{:}); 

%% Clean up: 

if nargout==0
   clear h
end

end