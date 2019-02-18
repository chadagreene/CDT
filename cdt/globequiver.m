function h = globequiver(lat,lon,u,v,varargin) 
% globequiver plots georeferenced vectors with components (u,v) in a
% East-North coordinate system on a globe.
% 
%% Syntax 
% 
%  globequiver(lat,lon,u,v)
%  globequiver(...,scale)
%  globequiver(...,LineSpec)
%  globequiver(...,LineSpec,'filled')
%  globequiver(...,'PropertyName',PropertyValue,...)
%  globequiver(...,'radius',GlobeRadius)
%  h = globequiver(...)
% 
%% Description
% 
% globequiver(lat,lon,u,v) plots the georeferenced vector values (u,v) on
% a globe. The inputs lat and lon are the same size as u and w and can
% be defined using meshgrid or cdtgrid.
%
% globequiver(...,scale) scales the size of the arrows which represent the
% vector values (u,v) automatically to fit the globe and then stretches
% them by S.
%
% globequiver(...,LineSpec) specifies line style, marker symbol, and color
% using any valid LineSpec.
%
% globequiver(...,LineSpec,'filled') fills markers specified by LineSpec.
%
% globequiver(...,'PropertyName',PropertyValue,...) specifies property name
% and property value pairs for the created objects.
%
% globequiver(...,'radius',GlobeRadius) specifies the radius of the globe
% as GlobeRadius. Default GlobeRadius is 6371.
%
% globequiver(...,'density',DensityValue) specifies density of the vectors
% displayed on the globe. Default density is simply the density of the raw
% data. 
%
% h = globequiver(...) returns the handle h of the plotted objects. 
% 
%% Examples
% For examples type 
% 
%  cdt globequiver
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globeplot and globescatter. 
%
%% Error checks: 

narginchk(4,Inf) % asserts at least four inputs. 
assert(islatlon(lat,lon),'The first two inputs in globeplot must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')


%% Parse Inputs: 

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into quiver3 later. 
else
   radius = 6371; % the default radius, corresponding to the average Earth radius in kilometers.
end

resize = 0;
tmp = strncmpi(varargin,'density',3);
if any(tmp)
   resize = 1;
   density = varargin{find(tmp)+1};
   tmp(find(tmp)+1)=1;
   varargin = varargin(~tmp);
   assert(isscalar(density)==1,'Input error: Density value must be a scalar.')
end

%% Resize the grids: 

if resize 
   InputDensity = hypot(size(lat,1),size(lat,2)); 

   sc = density/InputDensity; % scaling factor to convert InputDensity to desired density.

   % First, scale by nearest-neighbor:
   latn = imresize(lat,sc,'nearest');
   lonn = imresize(lon,sc,'nearest');
   un = imresize(u,sc,'nearest');
   vn = imresize(v,sc,'nearest');

   % For most of the grid we'll use default bicubic though: 
   lat = imresize(lat,sc);
   lon = imresize(lon,sc); 
   u = imresize(u,sc); 
   v = imresize(v,sc); 

   % But fill in NaNs with nearest-neighbor results b/c otherwise coastal areas would be decimated: 
   lat(isnan(lat)) = latn(isnan(lat)); 
   lon(isnan(lon)) = lonn(isnan(lon)); 
   u(isnan(u)) = un(isnan(u)); 
   v(isnan(v)) = vn(isnan(v)); 
end

%% Vectorize Grid Inputs:

lat = lat(:);
lon = lon(:);
u = u(:);
v = v(:);
w = zeros(size(v));

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius);

NED = [v'; u'; w'];
ECEF = zeros(size(NED));

for n = 1:length(w)
    R_ECEFtoNED = [-sind(lat(n))*cosd(lon(n)) -sind(lat(n))*sind(lon(n)) cosd(lat(n));...
        -sind(lon(n)) cosd(lon(n)) 0;...
        -cosd(lat(n))*cosd(lon(n)) -cosd(lat(n))*sind(lon(n)) -sind(lat(n))];
    ECEF(:,n) =  R_ECEFtoNED\NED(:,n);
end

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = quiver3(x,y,z,ECEF(1,:)',ECEF(2,:)',ECEF(3,:)',varargin{:}); 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
view(3)
axis off

%% Clean up: 

if nargout==0
   clear h
end

end