function h = globepcolor(lat,lon,C,varargin) 
% globepcolor plots georeferenced data on a globe where color is scaled
% by the data value.
% 
%% Syntax 
% 
%  globepcolor(lat,lon,C)
%  globepcolor(...,'radius',GlobeRadius)
%  h = globepcolor(...)
% 
%% Description
% 
% globepcolor(lat,lon,C)  creates a pseudocolor globe plot of the gridded 
% values given by C. The inputs lat and lon are the same size as C
% and can be defined for arbitrary domains using the meshgrid function.
% 
% globepcolor(...,'radius',GlobeRadius) specifies the radius of the globe.
% The Default GlobeRadius is 6371, the standard radius of the Earth in kilometers.
% 
% h = globepcolor(...) returns the handle h of the plotted objects. 
%
%% Examples
% For examples type 
% 
%  cdt globepcolor
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globesurf and globepcontour. 
%
%% Error checks: 

narginchk(3,Inf) % asserts at least two inputs. 
assert(islatlon(lat,lon),'The first two inputs in globepcolor must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')
assert(isequal(size(lat),size(lon),size(C)),'Dimensions of lat, lon, and C must all agree.') 

%% Parse Inputs: 

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
else
   radius = 6371; % the default radius, corresponding to Earth's average radius in kilometers.
end

%% Wrap the seam: 

if diff(lon(1:2))==0
   lon = [lon(:,end)-360 lon lon(:,1)+360]; 
   lat = [lat(:,end) lat lat(:,1)]; 
   C = [C(:,end) C C(:,1)]; 
else
   lon = [lon(end,:)-360;lon;lon(1,:)+360]; 
   lat = [lat(end,:);lat;lat(1,:)]; 
   C = [C(end,:);C;C(1,:)];    
end

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius);

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