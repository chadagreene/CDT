%% |globeborders| documentation 
% The |globeborders| function plots georeferenced political boundaries on a
% globe.
% 
% Data are compiled from <https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html
% 2013 US Census Bureau 500k data> and a <http://thematicmapping.org/downloads/world_borders.php
% thematicmapping.org TM World Borders 0.3> dataset. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
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
% |globeborders| plots national borders defined in the file
% |borderdata.mat| on a globe with radius defined as 6371, where 6371
% corresponds to the average radius of the Earth in kilometers.
%
% |globeborders(LineSpec)| specifies the line style, marker symbol, and/or
% color of the borders.
%
% |globeborders(Property,Value,...)| specifies the line properties to
% control border appearance and behavior.
% 
% |globeborders(...,'radius',GlobeRadius)| specifies the radius of the
% globe as |GlobeRadius|.
%
% |h = globeborders(...)| returns the handle |h| of the plotted objects. 
%
%% Example 1
% Plot national borders on a globe:

figure
globeborders
axis tight

%%
% Fill in the empty globe with <globefill_documentation.html |globefill|>:

hold on
globefill
axis tight

%% Example 2
% Plot national borders on a white globe as dashed, red lines:

figure
globefill
hold on
globeborders('--r')
axis tight

%% Example 3
% Plot national borders as thick, deep blue dots on a globe of radius 5 million:

figure
globeborders('color',[0.25 0.25 0.65],'linewidth',2,'linestyle',':','radius',5e6);
axis tight

%% Example 4
% Plot political boundaries over a Blue Marble globe plot: 

figure
globeimage
globeborders
view(45,20)
axis tight

%% Example 5
% Plot national borders as thin, black lines over a globe depicting
% topography:

load topo
[lon,lat] = meshgrid(0:359,-89:90);
figure
globepcolor(lat,lon,topo);
hold on
globeborders('color','k','linewidth',0.5,'linestyle','-')

%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for the Climate Data Toolbox for Matlab, 2019. 