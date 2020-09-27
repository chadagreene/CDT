function [Zr,xr,yr] = demresize(Z,x,y,sc,varargin)
% demresize is like imresize, but also resizes corresponding map coordinates. 
% 
%% Syntax 
% 
%  [Zr,xr,yr] = demresize(Z,x,y,sc) 
%  [Zr,xr,yr] = demresize(...,'method') 
%  [Zr,xr,yr] = demresize(...,'Name',Value,...) 
%
%% Description 
%
% [Zr,xr,yr] = demresize(Z,x,y,sc) resizes Z using imresize, and corresponding
% vector or 2D grid coordinates x and y to a scalar scale sc. 
% 
% [Zr,xr,yr] = demresize(...,'method') specifies an interpolation method. Default
% is 'bicubic'. 
% 
% [Zr,xr,yr] = demresize(...,'Name',Value,...) specifies any input name-value
% pairs accepted by imresize. 
%
%% Example 
% For examples type 
% 
%   cdt demresize
% 
%% Author Info
% This function was written by Chad A. Greene of NASA's
% Jet Propulsion Laboratory, April 2020. 
% http://www.chadagreene.com 
% 
% This is part of the Climate Data Toolbox for Matlab (Greene et al., 2019).
% Please cite it accordingly. 
% 
% See also: imresize and georesize. 

%% Input checks

narginchk(4,Inf) 
assert(ismatrix(Z) & size(Z,1)>1 & size(Z,2)>1,'Z must be a 2D matrix')

gridin = false; 
if size(x,1)>1 & size(x,2)>1 
   % ...then assume input was created by [X,Y] = meshgrid(x,y); 
   gridin = true; 
   x = x(1,:); 
   y = y(:,1); 
end

assert(isscalar(sc),'Input sc must be a scalar.') 

%% 

% Resize the DEM: 
Zr = imresize(Z,sc,varargin{:}); 

% Input resolution: 
xres = median(diff(x),'omitnan');
yres = median(diff(y),'omitnan'); 

% Resized resolution: 
xresr = (x(end)-x(1) + xres)/size(Zr,2); 
yresr = (y(end)-y(1) + yres)/size(Zr,1);

% New arrays: 
% (original pixel centers minus half an original pixel to get the full extent of the grid,
% then plus half a new pixel to get to the new pixel center):
xr = (x(1)-xres/2+xresr/2):xresr:(x(end)+xres/2-xresr/2); 
yr = (y(1)-yres/2+yresr/2):yresr:(y(end)+yres/2-yresr/2); 

% If the input coordinates were 2D, ouput them in 2D as well: 
if gridin 
   [xr,yr] = meshgrid(xr,yr); 
end

end