%% |globeplot| documentation 
% The |globeplot| function plots georeferenced data on a globe.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
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
% |globeplot(lat,lon)| creates a 2D line plot of the georeferenced
% data points specified by latitude and longitude. 
% 
% |globeplot(lat,lon,LineSpec)| specifies the line style, marker symbol,
% and/or color of the 2D line plot. 
% 
% |globeplot(...,PropertyName,PropertyValue,...)| specifies the line or
% marker properties of the 2D line plot.
% 
% |globeplot(...,'radius',GlobeRadius)| specifies the radius of the globe
% as |GlobeRadius|.
% 
% |h = globeplot(...)| returns the handle |h| of the plotted objects. 
% 
%% Example 1
% Plot randomly distributed red dots on a globe:

N = 1000; 
lat = 180*rand(N,1)-90; 
lon = 360*rand(N,1)-180; 

figure
globeplot(lat,lon,'r.')
axis tight

%% 
% Add an equator to the globe by defining a 1000 element array of zero latitudes
% (this could similarly be accomplished with <globegraticule_documentation.html |globegraticule|>.)

lon = linspace(-180,180,1000); 
lat = zeros(1,1000); 

globeplot(lat,lon)

%% 
% Plot a thick, black line which spirals around the world once from the
% South Pole to the North Pole:

lat = linspace(-90,90,1000); 
lon = linspace(-180,180,1000);

globeplot(lat,lon,'linewidth',4,'color','k')

%% 
% The globe is currently transparent. To fill it in, use <globefill_documentation.html |globefill|>: 

globefill

%% 
% Need more context? Add political boundaries with <globeborders_documentation.html |globeborders|>: 

globeborders

%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
