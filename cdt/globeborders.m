function h = globeborders(varargin)
% globeborders plots political boundaries borders on a globe. 
% 
% Data are compiled from 2013 US Census Bureau 500k data and thematicmapping.org
% TM World Borders 0.3 dataset. 
% https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html
% http://thematicmapping.org/downloads/world_borders.php
%% Syntax
% 
%  globeborders
%  globeborders(LineSpec)
%  globeborders(Property,Value,...)
%  globeborders(...,'radius',GlobeRadius)
%  h = globeborders(...)
%
%% Description
% 
% globeborders plots national borders defined in the file borderdata.mat on
% a globe with radius defined as 6371, where 6371 corresponds to the
% average radius of the Earth in kilometers.
%
% globeborders(LineSpec) specifies the line style, marker symbol,
% and/or color of the borders.
%
% globeborders(Property,Value,...) specifies the line properties to control
% border appearance and behavior.
% 
% globeborders(...,'radius',GlobeRadius) specifies the radius of the globe
% as GlobeRadius.
%
% h = globeborders(...) returns the handle h of the plotted objects. 
%
%% Examples
% For examples type 
% 
%  cdt globeborders
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globeplot and globefill.

%% Parse Inputs: 

% Don't actually need to parse inputs because globeplot will accept them
% just the way they are. 

%% Load data: 

C = load('borderdata.mat');

% Concatentate cell arrays into NaN-separated arrays: 
lat = cell2nancat(C.lat); % This is a function is part of CDT. 
lon = cell2nancat(C.lon); 

%% Plot

h = globeplot(lat,lon,varargin{:}); 

%% Clean up: 

if nargout==0
   clear h
end

end
