function h = globegraticule(varargin)
% globegraticule plots a graticule globe. Optional inputs control the
% appearance and behavior of the graticule.
%
%% Syntax
% 
%  globegraticule
%  globegraticule(lat,lon)
%  globegraticule(...,LineProperty,LineValue)
%  globegraticule(...,'radius',GlobeRadius) 
%  h = globegraticule(...)
% 
%% Description
% 
% globegraticule plots a graticule on an empty globe. The globe has radius
% of 6371, where 6371 corresponds to the average radius of the Earth in
% kilometers.
%
% globegraticule(lat,lon) specifies latitudes and longitudes depicted by
% the graticule.
% 
% globegraticule(...,LineProperty,LineValue) plots a graticule with
% user-specified line properties to control appearance and behavior.
% 
% globegraticule(...,'radius',GlobeRadius) specifies the radius of the
% graticule as GlobeRadius.
% 
% h = globegraticule(...) returns the handle h of the plotted objects. 
% 
%% Examples
% For examples type 
% 
%  cdt globegraticule
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for Climate Data Tools for Matlab, 2019. 
% 
% See also: globeplot and globefill. 
%
%% Set Defaults: 

LineColor = 0.5*[1 1 1]; 
lons = -180:20:160; 
lats = -90:10:90;
radius = 6371; % the default radius, corresponding to Earth's average radius in kilometers.
Npoints = 1000; % points per line (not a function input, but you can change it here).

%% Parse Inputs: 

% Check for user defined lats and lons: 
if nargin>1
   if all([isnumeric(varargin{1}) isnumeric(varargin{2})])
      lats = varargin{1}; 
      lons = varargin{2}; 
      assert(islatlon(lats,lons),'If the first two inputs are numeric they are assumed to be lat,lon, but the values you have given me are outside the normal range of lats and lons.')
      tmp = true(size(varargin)); 
      tmp(1:2) = false; 
      varargin = varargin(tmp); 
   end
end

% Check for user-defined globe radius: 
tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
end

%% Do math: 

% lines of longitude: 
[lon1,lat1] = meshgrid(lons,linspace(-90,90,Npoints)); 

% lines of latitude: 
[lat2,lon2] = meshgrid(lats,linspace(-180,180,Npoints)); 

% Concatenate and convert: 
[x,y,z] = sph2cart([lon1 lon2]*pi/180,[lat1 lat2]*pi/180,radius); 

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = plot3(x,y,z,'-','color',LineColor,varargin{:}); 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off


%% Clean up: 

if nargout == 0 
   clear h
end

end