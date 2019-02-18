function h = globefill(varargin)
% globefill plots a filled globe. Optional inputs control the appearance
% and behavior of the globe.
%
%% Syntax
% 
%  globefill
%  globefill(...,'color',ColorSpec)
%  globefill(...,'radius',GlobeRadius)
%  h = globefill(...)
% 
%% Description
% 
% globefill creates a white globe that can be used to fill the empty
% space of such plots as |globeplot|. 
%
% globefill(...,'color',ColorSpec) specifies the color of the filled
% globe.
% 
% globefill(...,'radius',Radius) specifies the radius of the sphere as
% Radius. By default, the radius is 6307.3, which is 99 percent of the standard
% Earth 6371 km Earth radius. The globefill radius is slightly smaller than 
% the standard radius used by other globe* functions to prevent unwanted 
% interactions. 
% 
% h = globefill(...) returns the handle h of the plotted objects. 
%
%% Examples
% For examples type 
% 
%  cdt globefill
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globegraticule and globeplot. 
%
%% Set Defaults: 

color = 'w'; 
radius = 0.99*6371; % the default radius, corresponding to 99% of the average Earth radius in kilometers.
N = 500; % resolution of sphere (not a function input, but you can change it here).

%% Parse Inputs: 

% Check for user-defined globe radius: 
tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp);
end

tmp = strncmpi(varargin,'color',3); % checks for optional inputs matching "rad" 
if any(tmp)
   color = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp);
end

%% Do math: 

[X,Y,Z] = sphere(N); 

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = surf(X*radius,Y*radius,Z*radius,'facecolor',color,'edgecolor','none');

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Clean up: 

if nargout == 0 
   clear h
end

end