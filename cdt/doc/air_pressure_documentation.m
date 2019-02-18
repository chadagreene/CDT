%% |air_pressure| documentation
% |air_pressure| computes pressure from the baromometric forumula for a US Standard Atmosphere. 
% 
% See also <air_density_documentation.html |air_density|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  P = air_pressure(h)
% 
%% Description
%
% |P = air_pressure(h)| returns the pressure |P| in pascals corresponding to
% the heights |h| in geometric meters above sea level.
% 
%% Example 1: Pressure profile
% The US Standard Atmosphere formula is valid to 86 km above sea level, so
% let's look at air pressure from sea level to 85 km: 

h = 0:85e3; 

p = air_pressure(h); 

figure 
plot(p/1000,h/1000)
axis tight
box off 
ylabel 'height above sea level (km)' 
xlabel 'pressure (kPa)' 

%% 
% The formula uses a piecewise function that calculates an equation based
% on different constants for different layers of the atmosphere. The bases
% of those layers are at 0, 11, 20, 32, 47, 51, and 71 km above sea level. 
% For context, we can plot those layer bases as horizontal lines using
% <hline_documentation.html |hline|>:

LayerBases = [0 11 20 32 47 51 71]; 

hline(LayerBases,':','color',rgb('gray'))

%%
% Pro tip: For some applictions it may be helpful to display the x axis on
% a log scale. To do that, we could have plotted the data with |semilogx| instead of
% using the |plot| function above, or we can change the x scale to log like this: 

set(gca,'xscale','log')

%% Example 2: Comparison to reanalysis surface pressure
% Consider this global gridded surface pressure data, and we'll just look
% at the means surface pressure from the year 2017: 

lat = ncread('ERA_Interim_2017.nc','latitude');
lon = ncread('ERA_Interim_2017.nc','longitude');
t = ncread('ERA_Interim_2017.nc','time');
sp = ncread('ERA_Interim_2017.nc','sp');

% Calculate mean surface pressure: 
spm = mean(sp,3); 

% Plot the mean surface pressure: 
figure
imagescn(lon,lat,spm'/1000)

cb = colorbar; 
ylabel(cb,'surface pressure (kPa)')
caxis([50 105])

%% 
% The first thing you may notice in the figure above, is that surface
% pressure roughly corresponds to surface topography. Let's show that by overlaying
% topographic contours. Use <topo_interp_documentation.html |topo_interp|> to 
% get surface and seafloor topography, set underwater topography to zero,
% and overlay contours: 

% Get a Lat,Lon grid from the lat,lon arrays:  
[Lat,Lon] = meshgrid(lat,lon); 

% Get the surface topography: 
z = topo_interp(Lat,Lon); 

% Set underwater values of topography to zero: 
z(z<0) = 0; 

hold on
contour(Lon,Lat,z,'k');

%% 
% Clearly there's a relationship between surface pressure and suface
% topography. Display the relationship as a scatterplot

figure
scatter(spm(:)/1000,z(:),8,Lat(:),'filled') 
cb = colorbar; 
ylabel(cb,'latitude')
cmocean delta
xlabel 'surface pressure (kPa)' 
ylabel 'surface elevation (m)'
axis tight 

%%
% Neat scatterplot, but how does it compare to the theoretical
% elevation-only dependent air pressure from the US Standard Atmosphere? 

p = air_pressure(z); 

hold on
plot(p(:)/1000,z(:),'r.')
legend('ERA-Interim','US Standard Atmosphere')

%% 
% Want a quantitative measure of how well the theory copares to the reanalysis 
% data? There are many ways to quantify that relationship, like correlation
% coefficients and p values. Another measure of mismatch is the the root-mean-square difference
% between the two: 

rms([spm(:) - p(:)],'omitnan')/1000

%% 
% The rms difference is about 1.88 kPa. 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 