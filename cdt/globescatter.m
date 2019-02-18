function h = globescatter(lat,lon,varargin) 
% globescatter plots georeferenced data as color-scaled spheres on a globe. 
% 
%% Syntax 
% 
%  globescatter(lat,lon)
%  globescatter(lat,lon,sz)
%  globescatter(lat,lon,sz,c)
%  globescatter(...,PropertyName,PropertyValue,...)
%  globescatter(...,'radius',GlobeRadius)
%  h = globescatter(...)
% 
%% Description
% 
% globescatter(lat,lon) creates a 3D scatter plot of the georeferenced data
% points specified by latitude and longitude on a globe with radius of
% 6371, where 6371 corresponds to the average radius of the Earth in
% kilometers. 
% 
% globescatter(lat,lon,sz) specifies the size of the spheres as a percentage
% of the globe radius. For a scalar s, spheres are plotted the same size.
% For a vector s, spheres are plotted with specified sizes.
%
% 
% globescatter(...,PropertyName,PropertyValue,...) specifies the surface
% properties of the 3D scatter plot.
% 
% globescatter(...,'radius',GlobeRadius) specifies the radius of the globe
% as GlobeRadius.
% 
% h = globescatter(...) returns the handle h of the plotted objects. 
% 
%% Examples
% For examples type 
% 
%  cdt globescatter
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for Climate Data Tools for Matlab, 2019. 
% 
% See also: globeplot. 
%
%% Error checks: 

narginchk(2,Inf) % asserts at least two inputs. 
assert(islatlon(lat,lon),'The first two inputs in globescatter must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')

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

% if isempty(varargin)
%     s = 0.01*radius; % Default sphere size is one percent of the globe radius
% else
%     s = varargin{1}; % extracts sphere size
%     s = (s/100)*radius;
%     if isempty(s)  
%         s = 0.01*radius; % Default sphere size is one percent of the globe radius
%     end
%     varargin(1) = [];
% end
% 
% if isempty(varargin)
%     varargin{1} = 'FaceColor';
%     varargin{2} = 'k'; % Default sphere color is black
% end

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius);

%% Plot: (scatter plot of circles not spheres...) 

if ~ishold
   view(3)
   hold on
end

h = scatter3(x,y,z,varargin{:}); 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Plot: (This plots spheres, but it's slow for big datasets and the syntax doesn't match scatter.
% % Adapted from  Walter Roberson's answer in:
% % https://www.mathworks.com/matlabcentral/answers/254961-3d-plot-points-as-spheres-instead-of-dots
% 
% if length(s) == 1
%     s = repmat(s,length(x),1);
% end
% n = 42; % the meaning of life, universe, and everything
% [sx,sy,sz] = sphere(n);
% 
% 
% if ~ishold
%    view(3)
% end
% 
% hold on;
% for k = 1 : length(x)
%     h = surf(sx*s(k) + x(k), sy*s(k) + y(k), sz*s(k) + z(k), varargin{:});
%     h.EdgeColor = 'none';
% end
% 
% daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
% axis off

%% Clean up: 

if nargout==0
   clear h
end

end