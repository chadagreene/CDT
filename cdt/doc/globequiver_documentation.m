%% |globequiver| documentation 
% The |globequiver| function plots georeferenced vectors with components
% |(u,v)| in a East-North coordinate system on a globe.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  globequiver(lat,lon,u,v)
%  globequiver(...,scale)
%  globequiver(...,LineSpec)
%  globequiver(...,LineSpec,'filled')
%  globequiver(...,'PropertyName',PropertyValue,...)
%  globequiver(...,'radius',GlobeRadius)
%  globequiver(...,'density',DensityValue)
%  h = globequiver(...)
% 
%% Description
% 
% |globequiver(lat,lon,u,v)| plots the georeferenced vector values |(u,v)|
% on a globe. The inputs |lat| and |lon| are the same size as |u| and
% |v| and can be defined using |meshgrid| or |cdtgrid|.
%
% |globequiver(...,scale)| scales the size of the arrows which represent
% the vector values |(u,v)| automatically to fit the globe and then
% stretches them by |S|.
%
% |globequiver(...,LineSpec)| specifies line style, marker symbol, and
% color.
%
% |globequiver(...,LineSpec,'filled')| fills markers specified by
% |LineSpec|.
%
% |globequiver(...,'PropertyName',PropertyValue,...)| specifies property
% name and property value pairs for the created objects.
%
% |globequiver(...,'radius',GlobeRadius)| specifies the radius of the globe
% as |GlobeRadius|. Default |GlobeRadius| is 6371. 
%
% |globequiver(...,'density',DensityValue)| specifies density of the
% vectors displayed on the globe. Default density is simply the density of
% the raw data.
%
% |h = globequiver(...)| returns the handle |h| of the plotted objects. 
% 
%% Example 1
% Plot northward vectors, and use <globefill_documentation.html |globefill|> to fill 
% the inside of the globe: 

[lat,lon] = cdtgrid(10); 
u = zeros(size(lat)); 
v = ones(size(lat)); 

figure
globequiver(lat,lon,u,v)
globefill 
axis tight

%% Example 2
% Plot red eastward vectors on a globe:

[lat,lon] = cdtgrid(10); 

u = ones(size(lat)); 
v = zeros(size(lat));

figure
globequiver(lat,lon,u,v,'r')
globefill 
axis tight

%% Example 3
% Plot anomalies from January 2017 derived from ERA-Interim products:  

filename = 'ERA_Interim_2017.nc'; 
u10 = ncread(filename,'u10'); % 10 metre U wind component
v10 = ncread(filename,'v10'); % 10 metre V wind component
sp = ncread(filename,'sp'); % surface pressure
T = ncread(filename,'t2m'); % 2 metre temperature
lat = double(ncread(filename,'latitude')); 
lon = double(ncread(filename,'longitude')); 

% Calculate anomalies for January: 
mo = 1; 
Ta = T(:,:,mo)-mean(T,3); 
spa = sp(:,:,mo)-mean(sp,3); 
ua = u10(:,:,mo) - mean(u10,3); 
va = v10(:,:,mo) - mean(v10,3); 

[lat,lon] = meshgrid(lat,lon);

%%
% Start by plotting the temperature anomaly using <globepcolor_documentation.html
% |globepcolor|> and adjust colormap using using <cmocean_documentation.html |cmocean|>:
% Add national borders using <globeborders_documentation.html |globeborders|>:

figure
globepcolor(lat,lon,Ta)
globeborders('color',rgb('gray'))
axis tight
cmocean('balance','pivot') 

%% 
% Now plot wind anomalies: 

q = globequiver(lat,lon,ua,va,'k'); 

%% 
% Is that wind vector grid too dense? Delete it and try again, specifying vector
% density and scale length: 

delete(q) % deletes the quiver arrows we just plotted above

globequiver(lat,lon,ua,va,2,'density',100,'k')

%%
% For added context, plot surface pressure anomaly as contour lines using
% <globecontour_documentation.html |globecontour|>. Also change the viewing angle: 

globecontour(lat,lon,spa,10,'color',rgb('orange'))
view(-140,22)

%%
% 

%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 