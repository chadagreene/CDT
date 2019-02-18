%% |globepcolor| documentation 
% The |globepcolor| function plots georeferenced data on a globe where
% color is scaled by the data value.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  globepcolor(lat,lon,C)
%  globepcolor(...,'radius',GlobeRadius)
%  h = globepcolor(...)
% 
%% Description
% 
% |globepcolor(lat,lon,C)| creates a pseudocolor globe plot of the gridded 
% values given by |C|. The inputs |lat| and |lon| are the same size as |C|
% and can be defined for arbitrary domains using the |meshgrid| function.
% 
% |globepcolor(...,'radius',GlobeRadius)| specifies the radius of the globe.
% The Default |GlobeRadius| is 6371, the standard radius of the Earth in kilometers.
% 
% |h = globepcolor(...)| returns the handle |h| of the plotted objects. 
%
%% Example 1: Global topography
% For this example, plot color-scaled global topography. use <cdtgrid_documentation.html |cdtgrid|>
% to create a quarter-degree grid, and <topo_interp_documentation.html |topo_interp|> to get the corresponding
% topography. Set the colormap with <cmocean_documentation.html |cmocean|>:

[Lat,Lon] = cdtgrid(0.25); 
Z = topo_interp(Lat,Lon); 

globepcolor(Lat,Lon,Z);
cmocean('topo','pivot') 
axis tight % removes whitespace

%% Example 2: Earth radius
% The |globe*| functions in CDT plot the Earth as a sphere, though in reality 
% it's more of an oblate spheroid (aka ellipsoid), or a sphere whose radius is a function 
% of latitude. We can use |globepcolor| to depict the difference between a spherical
% Earth and an ellipsoidal Earth as follows. 
% 
% Use <cdtgrid_documentation.html |cdtgrid|> to make a global grid and use
% <earth_radius_documentation.html |earth_radius|> to get the latitude-dependent radius at
% each grid cell: 

[Lat,Lon] = cdtgrid; 

R = earth_radius(Lat,'km'); 

%% 
% Since Earth's radius is a function of latitude, show where the standard
% Earth radius of 6371 km accurate overestimates versus underestimates
% the true radius of the Earth. Use the |'pivot'| option in <cmocean_documentation.html |cmocean|>
% to make the colors pivot about the 6371 km value: 

figure
globepcolor(Lat,Lon,R);
axis tight

c = colorbar;
set(get(c,'title'),'string','Radius (km)');
cmocean('diff','pivot',6371) % sets the colormap
globeborders % adds political boundaries for context

%%
% In the plot above, wherever the surface is brown, the Earth radius is larger
% than the standard 6371 km, and wherever the surface is blue the distance from 
% the surface to the center of the earth is less than 6371 km.
% 
% Adjust the view from polar to equatorial:

view([0 0])

%% Example 3: Just a slice of Earth
% Plot Earth radius, displaying only longitudes between 0 and 30 degrees:

figure
[Lon,Lat] = meshgrid(0:30,-90:90);
R = earth_radius(Lat,'km'); 

globepcolor(Lat,Lon,R);
c = colorbar;
set(get(c,'title'),'string','Radius (km)');
view([135 0])

%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for the Climate Data Toolbox for Matlab, 2019. 