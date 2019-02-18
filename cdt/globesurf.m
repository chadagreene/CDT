function h = globesurf(lat,lon,Z,varargin) 
% globesurf plots georeferenced data on a globe where values in matrix Z
% are plotted as heights above the globe.
% 
%% Syntax 
% 
%  globesurf(lat,lon,Z)
%  globesurf(lat,lon,Z,C)
%  globesurf(...,'exaggeration',exaggerationFactor)
%  globesurf(...,'radius',GlobeRadius)
%  h = globesurf(...)
% 
%% Description
% 
% globesurf(lat,lon,Z) plots the georeferenced values given by Z at heights
% above a globe of radius 6371, where 6371 corresponds to the average
% radius of the Earth in kilometers. The inputs lat and lon are the same
% size as Z and can be defined for arbitrary domains using the meshgrid
% function.
% 
% globesurf(lat,lon,Z,C) specifies the colors of the georeferenced values
% either by a matrix the same size as Z or as an m-by-n-by-3 array of RGB
% triplets, where Z is m-by-n.
%
% globesurf(...,'exaggeration',exaggerationFactor) scales the plotted
% height of the georeferenced values by a factor specified by
% exaggerationFactor.
% 
% globesurf(...,'radius',GlobeRadius) plots the georeferenced values as
% heights above a globe of radius specified by GlobeRadius. 
% 
% h = globesurf(...) returns the handle h of the plotted objects. 
% 
%% Examples
% For examples type 
% 
%  cdt globesurf
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for Climate Data Tools for Matlab, 2019. 
% 
% See also: globepcolor and globecontour. 
%
%% Error checks: 

narginchk(3,Inf) % asserts at least two inputs. 
assert(islatlon(lat,lon),'The first two inputs in globesurf must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')
assert(isequal(size(lat),size(lon),size(Z)),'Dimensions of lat, lon, and Z must all agree.') 

%% Parse Inputs: 

C = Z; % by default
if nargin>3
   if isnumeric(varargin{1}) && isequal(size(Z),size(varargin{1})); 
      C = varargin{1}; 
      tmp = true(size(varargin)); 
      tmp(1) = false; 
      varargin = varargin(tmp); 
   end
end

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
else
   radius = 6371; % (km) the default Earth radius.
end

tmp = strncmpi(varargin,'exaggeration',3); % checks for optional inputs matching exa
if any(tmp)
   exaggeration = varargin{find(tmp)+1}; 
   assert(isscalar(exaggeration),'Exaggeration factor must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
else
   exaggeration = 1; % (m) the default Earth radius.
end

%% Wrap the seam: 

if diff(lon(1:2))==0
   lon = [lon(:,end)-360 lon lon(:,1)+360]; 
   lat = [lat(:,end) lat lat(:,1)]; 
   C = [C(:,end) C C(:,1)]; 
   Z = [Z(:,end) Z Z(:,1)]; 
else
   lon = [lon(end,:)-360;lon;lon(1,:)+360]; 
   lat = [lat(end,:);lat;lat(1,:)]; 
   C = [C(end,:);C;C(1,:)];  
   Z = [Z(end,:);Z;Z(1,:)];      
end

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius + Z*exaggeration/1000); 

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = surface(x,y,z,C,varargin{:}); 

shading flat 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Clean up: 

if nargout==0
   clear h
end

end