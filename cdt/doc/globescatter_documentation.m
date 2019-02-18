%% |globescatter| documentation 
% The |globescatter| function plots georeferenced data as color-scaled spheres on a
% globe.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  globescatter(lat,lon)
%  globescatter(lat,lon,sz)
%  globescatter(lat,lon,sz,c)
%  globescatter(...,'filled')
%  globescatter(...,PropertyName,PropertyValue,...)
%  globescatter(...,'radius',GlobeRadius)
%  h = globescatter(...)
% 
%% Description
% 
% |globescatter(lat,lon)| creates a scatter plot of the georeferenced
% data points specified by lat,lon on a globe.
% 
% |globescatter(lat,lon,sz)| specifies the size of the circles.
%
% |globescatter(lat,lon,sz,c)| draws each circle with the color specified by C.
% 
% * If |c| is a RGB triplet or character vector or string containing a color
% name, then all circles are plotted with the specified color. 
% * If |c| is a three column matrix with the number of rows in |c| equal to the length of
% |lat| and |lon|, then each row of |c| specifies an RGB color value for the corresponding circle. 
% * If |c| is a vector with length equal to the length of |lat| and |lon|, then the values 
% in |c| are linearly mapped to the colors in the current colormap.
% 
% |globescatter(...,'filled')| fills in the circles, using any of the input argument
% combinations in the previous syntaxes.
% 
% |globescatter(...,PropertyName,PropertyValue,...)| modifies the scatter chart using 
% one or more name-value pair arguments.
% 
% |globescatter(...,'radius',GlobeRadius)| specifies the radius of the
% globe as |GlobeRadius|. Default |GlobeRadius| is 6371. 
% 
% |h = globescatter(...)| returns the handle |h| of the plotted objects.
% 
%% Example 1
% Plot the locations of the <https://earthquake.usgs.gov/earthquakes/browse/largest-world.php 
% 20 largest earthquakes> in the world as documented by the USGS:

lat = [-38.14, 60.91, 3.3, 38.3, 52.62, -36.12, 0.96, 51.25, 28.36,...
    2.33, 2.09, 51.5, 53.49, -5.05, -28.29, 44.87, 54.49, -4.44, -16.27, 39.21];
lon = [-73.41, -147.34, 95.98, 142.37, 159.78, -72.9, -79.37, 178.72,...
    96.45, 93.06, 97.11, -175.63, -162.83, 131.61, -69.85, 149.48,...
    160.47, 101.37, -73.64, 144.59];
 
globescatter(lat,lon) 
globefill
globeborders
camlight % adds lighting
material dull % makes it less shiny
axis tight

%% 
% Above, we filled in the inside of the globe with <globefill_documentation.html |globefill|>, 
% plotted political boundaries with <globeborders_documentation.html |globeborders|>, and 
% added a sense of dimension lighting via |camlight|. 
 
%%  
% Now do the same as above, but scale the marker sizes according to earthquake magnitudes: 

% earthquake magnitudes:
m = [9.5, 9.2, 9.1, 9.1, 9, 8.8, 8.8, 8.7, 8.6, 8.6, 8.6, 8.6, 8.6,...
    8.5, 8.5, 8.5, 8.4, 8.4, 8.4, 8.4];

globescatter(lat,lon,10.^m/1e6)

%% Example 2
% Imagine a bunch of drifters scattered about the ocean, like Argo floats. Use <dist2coast_documentation.html 
% |dist2coast|> to get the distance to the nearest land and plot them as scaled colors: 

% Make 10000 randomly distributed datapoints: 
N = 10000; 
lat = 180*rand(N,1)-90; 
lon = 360*rand(N,1)-180; 

% Eliminate land: 
land = island(lat,lon); 
lat(land) = []; 
lon(land) = []; 

% Get distances to land: 
d = dist2coast(lat,lon); 

figure
globescatter(lat,lon,10,d,'filled')
globeimage
cmocean -matter
axis tight
view(50,10)
cb = colorbar; 
ylabel(cb,'distance to land (km)') 
caxis([0 2000]) 

%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for the Climate Data Toolbox for Matlab, 2019. 