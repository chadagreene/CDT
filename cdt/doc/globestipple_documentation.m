%% |globestipple| documentation 
% The |globestipple| function creates a hatch filling or stippling over a
% region of a globe. This function is designed primarily to show regions of
% statistical significance in spatial maps.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  globestipple(lat,lon,mask) 
%  globestipple(...,MarkerProperty,MarkerValue,...)
%  globestipple(...,'radius',GlobeRadius)
%  globestipple(...,'density',DensityValue) 
%  globestipple(...,'resize',false) 
%  h = globestipple(...)
% 
%% Description
% 
% |globestipple(lat,lon,mask)| plots black dots on a globe at locations
% defined by |lat| and |lon| wherever |mask| contains true values. The
% globe has radius of 6371, where 6371 corresponds to the average radius of
% the Earth in kilometers. Dimensions of |lat|, |lon|, and |mask| must all
% match.
% 
% |globestipple(...,MarkerProperty,MarkerValue,...)| specifies any marker
% properties that are accepted by the plot function (e.g., |'Color'|,
% |'Marker'|, |'MarkerSize'|, etc).
%  
% |globestipple(...,'radius',GlobeRadius)| specifies the radius of the
% globe as |GlobeRadius|.
%
% |globestipple(...,'density',DensityValue)| specifies density of stippling
% markers. Default density is 100, but if your plot is too crowded you may
% specify a lower density value (and/or adjust the |'MarkerSize'|).
% 
% |globestipple(...,'resize',false)| overrides the |'density'| option and
% plots stippling at the exact resolution of the input grid. By default,
% the grids are resized because any grid larger than about 100x100 would
% produce so many stippling dots it would black out anything under them.
% 
% |h = globestipple(...)| returns a handle of the plotted stippling
% objects.
% 
%% Example 1
% Plot high-density stippling where topography is above sea level. To do this, 
% we'll use <cdtgrid_documentation.html |cdtgrid|> to create a 1-degree global 
% grid, and <island_documentation.html |island|> to determine which of those 
% grid cells corresponds to land: 

[lat,lon] = cdtgrid; 
mask = island(lat,lon); 

figure
globestipple(lat,lon,mask,'density',300) 
axis tight

% Set the globe color to azure:
globefill('color',rgb('azure'))

%% Example 2
% Most places on Earth tend to change temperature between February and August. 
% Load the example monthly gridded global temperature data from 2017, and 
% we'll figure out where those temperature trends are significant. 

filename = 'ERA_Interim_2017.nc'; 
T = ncread(filename,'t2m'); 
lat = double(ncread(filename,'latitude')); 
lon = double(ncread(filename,'longitude')); 

% Grid the lat,lon arrays: 
[Lat,Lon] = meshgrid(lat,lon); 

% Calculate February-to-August temperature trend:
[tr1,p1] = trend(T(:,:,2:8)); 

%% 
% First, plot the temperature trend with <globepcolor_documentation.html |globepcolor|>
% and set the colormap with <cmocean_documentation.html |cmocean|>: 

figure
globepcolor(Lat,Lon,tr)
axis tight
cmocean('balance','pivot') 
cb = colorbar;
ylabel(cb,'temperature trend (\circC/month)')
globeborders('color',rgb('gray')) % plots political boundaries
view(55,10) % sets viewing angle
title('Feb to Aug temperature trend')

%% 
% Unsurprisingly, the northern hemisphere tends to heat up from February
% to August, while the southern hemisphere does the opposite. But where is 
% the trend significant? 
% 
% Add stippling stippling wherever the trend is significant to p<0.001

globestipple(Lat,Lon,p<0.001,...
   'density',250,...
   'color',rgb('dark green'),...
   'markersize',2)

 %% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for the Climate Data Toolbox for Matlab, 2019. 