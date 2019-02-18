function h = globeplot(lat,lon,varargin) 
% globeplot plots georeferenced data on a globe. 
% 
%% Syntax 
% 
%  globeplot(lat,lon)
%  globeplot(lat,lon,LineSpec)
%  globeplot(...,PropertyName,PropertyValue,...)
%  globeplot(...,'radius',GlobeRadius)
%  h = globeplot(...)
% 
%% Description
% 
% globeplot(lat,lon) creates a 2D line plot of the georeferenced data
% points specified by latitude and longitude on a globe with radius of
% 6371, where 6371 corresponds to the average radius of the Earth in
% kilometers.
% 
% globeplot(lat,lon,LineSpec) specifies the line style, marker symbol,
% and/or color of the 2D line plot. 
% 
% globeplot(...,PropertyName,PropertyValue,...) specifies the line or
% marker properties of the 2D line plot.
% 
% globeplot(...,'radius',GlobeRadius) specifies the radius of the globe as
% GlobeRadius.
% 
% h = globeplot(...) returns the handle h of the plotted objects. 
% 
%% Examples
% For examples type 
% 
%  cdt globeplot
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globegraticule and globefill. 
%
%% Error checks: 

narginchk(2,Inf) % asserts at least two inputs. 
assert(islatlon(lat,lon),'The first two inputs in globeplot must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')

%% Parse Inputs: 

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
else
   radius = 6371; % the default radius, corresponding to the average Earth radius in kilometers.
end

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius);

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = plot3(x,y,z,varargin{:}); 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Clean up: 

if nargout==0
   clear h
end

end