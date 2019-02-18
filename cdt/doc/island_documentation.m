%% |island| documentation
% |island| is a logical function for determing whether a geolocation corresponds
% to land or water. (That's *_is land_*, not island!)
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  tf = island(lat,lon)
% 
%% Description 
% 
% |tf = island(lat,lon)| uses a 1/8 degree resolution global land mask to determine
% whether the geographic location(s) given by |lat,lon| correspond to land or water.
% Output is |true| for land locations, |false| otherwise. 
% 
%% Example
% This example uses <cdtgrid_documentation.html |cdtgrid|> to create a 1x2 degree
% resolution grid, and we'll get some z values from Matlab's built-in example 
% |peaks| function: 

% Create a sample grid, 1 degree (lat) by 2 degree (lon) resolution: 
[lat,lon] = cdtgrid([1 2]); 

% Some sample z data: 
z = topo_interp(lat,lon);

% Plot the full grid: 
imagescn(lon,lat,z)
hold on
borders

%% 
% Mask-out land values by setting them to |NaN|: 

% Determine which grid points correspond to land: 
land = island(lat,lon); 

% Set land values to NaN: 
z(land) = NaN; 

% Plot the masked dataset: 
figure
imagescn(lon,lat,z) 
hold on
borders
%% Author Info