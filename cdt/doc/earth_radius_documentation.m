%% |earth_radius| documentation
% |earth_radius| gives the radius of the Earth. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  r = earth_radius
%  r = earth_radius(lat)
%  r = earth_radius(...,'km') 
% 
%% Description
% 
% |r = earth_radius| returns |6371000|, the nominal radius of the Earth in meters. 
%
% |r = earth_radius(lat)| gives the radius of the Earth as a function of latitude.
% 
% |r = earth_radius(...,'km')| returns values in kilometers.
% 
%% Example 1: Nominal radius
% Get the nominal Earth radius in meters: 

earth_radius 

%% 
% ...or in kilometers: 

earth_radius('km')

%% Example 2: Latitude dependence of Earth's radius
% The Earth is more of an ellipsoid than a sphere, meaning its radius depends on latitude.
% Percentage-wise, how far off is the nomonal Earth radius at the Equator? 

100*(earth_radius-earth_radius(0))/earth_radius(0)

%%
% That says the nominal Earth radius of 6371 km is about a tenth of a percent smaller than
% the true radius at the Equator. Should we expect the same error at the North Pole? 

100*(earth_radius-earth_radius(90))/earth_radius(90)

%% 
% In fact, the nominal radius is about _two_ tenths of a percent larger than the true
% radius at the poles. Here's Earth's radius as a function of latitude: 

lat = 0:90; 
r = earth_radius(lat,'km');

plot(lat,r)
axis tight
box off

hline(earth_radius('km')) % the nominal earth radius
xlabel latitude
ylabel 'radius (km)'

legend('latitude dependent','nominal')
legend boxoff

%% Example 3: A grid
% Use <cdtgrid_documentation.html |cdtgrid|> to make a global grid, and |earth_radius| to 
% get Earth's radius at each point on the grid: 

[lat,lon] = cdtgrid; 
r = earth_radius(lat,'km'); 

%% 
% Plot them on a globe with <globepcolor_documentation.html |globepcolor|>: 

figure 
globepcolor(lat,lon,r) 
globeborders   % plots political boundaries 
globegraticule % plots grid lines 
axis tight     % removes empty space
cb = colorbar; 
ylabel(cb,'radius (km)')

%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for the Climate Data Toolbox for Matlab, 2019. 