%% |cdtdivergence| documentation 
% |cdtdivergence| calculates the divergence of gridded vectors on the ellipsoidal
% Earth's surface. 
% 
% See also: <cdtgradient_documentation.html |cdtgradient|>, <cdtcurl_documentation.html |cdtcurl|>
% and <ekman_documentation.html |ekman|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  D = cdtdivergence(lat,lon,U,V)
% 
%% Description
% 
% |D = cdtdivergence(lat,lon,U,V)| uses <cdtdim_documentation.html |cdtdim|> to estimate the 
% dimensions of each grid cell in the |lat,lon| grid, then computes the divergence of the 
% gridded vectors |U,V|. Units of D are the units of U and V divided by meters. 
%
%% Example 1: Theory 
% Here's a simple field of purely zonal wind with a uniform velocity of 1 m/s
% everywhere around the globe. Use <cdtgrid_documentation.html |cdtgrid|>
% to make a quarter-degree grid and then define the wind field: 

[lat,lon] = cdtgrid(0.25); % quarter degree grid
u = ones(size(lat));       % purely zonal wind
v = zeros(size(lat));      % no meridional component. 

%% 
% Here's what the wind vectors and divergence look like for a purely zonal
% wind of uniform velocity: 

D = cdtdivergence(lat,lon,u,v); 

figure
imagescn(lon,lat,D)
hold on 
borders('countries','color',rgb('gray'))
quiversc(lon,lat,u,v,'k')
cb = colorbar; 
ylabel(cb,'divergence (s^{-1})')
cmocean('balance','pivot')

%% 
% In the figure above, we see that the divergence is zero everywhere.
% That's because as a parcel of air moves from one grid cell eastward to
% the next grid cell over, the wind does not change speed or direction, and
% the neighboring grid cell is exactly the same size as the grid cell it
% just came from. Everything stays perfectly the same, so there is no
% divergence. 
% 
% What about a purely meridional wind? Can we expect the same kind of zero
% divergence everywhere around the globe? 
% 
% Using the same quarter degree lat,lon grid from above, define a purely
% meridional wind of uniform velocity everywhere: 

u = zeros(size(lat)); % no zonal component
v = ones(size(lat));  % 1 m/s northward everywhere

% compute the divergence: 
D = cdtdivergence(lat,lon,u,v); 

figure
imagescn(lon,lat,D)
hold on 
borders('countries','color',rgb('gray'))
quiversc(lon,lat,u,v,'k')
cb = colorbar; 
ylabel(cb,'divergence (s^{-1})')
cmocean('balance','pivot')

%% 
% Above, what we get is _not_ zero divergence everywhere. Rather, there
% seems to be divergence in the northern hemisphere and convergence in the
% southern hemisphere. That's because the Earth is not a perfect sphere, but
% is an ellipsoid whose lines of latitude are spaced at near-but-not-quite-equal 
% distances from each other. Play around with the <earth_radius.html |earth_radius|> 
% function, and you'll see that in a trip from the South Pole to the
% equator, lines of latitude get closer together. Keeping going, and from
% the equator to the North Pole the lines of latitude will begin to spread
% apart again. Check the scale on the colorbar above, and you'll see that
% while latitude spacing does affect divergence, its role here is still
% quite small. 

%% 
% Putting together the two examples above, what if the wind is uniform
% zonally and meridionally everywhere? 

u = ones(size(lat)); 
v = ones(size(lat)); 

D = cdtdivergence(lat,lon,u,v); 

figure
imagescn(lon,lat,D)
hold on 
borders('countries','color',rgb('gray'))
quiversc(lon,lat,u,v,'k')
cb = colorbar; 
ylabel(cb,'divergence (s^{-1})')
cmocean('balance','pivot')

%%
% Above we see that adding zero zonal divergence to a small amount of
% meridional divergence produces the same result as just looking at the
% meridional divergence. I suppose that's no big surprise. 
% 
% Now consider a case where wind speed varies with longitude. Make it 

u = lon.^2; 
v = zeros(size(lat)); 

D = cdtdivergence(lat,lon,u,v); 

figure
imagescn(lon,lat,D)
hold on 
borders('countries','color',rgb('gray'))
quiversc(lon,lat,u,v,'k')
cb = colorbar; 
ylabel(cb,'divergence (s^{-1})')
cmocean('balance','pivot')

caxis([-1 1]*1e-2)

%% 
% Above, in the Western Hemisphere the wind converges as it goes from
% very strong at the international date line, to zero velocity at the prime
% meridian. There, at the prime meridian, the wind begins to pick up speed
% again, making it divergent as the wind begins to effectively pull itself
% apart. 
% 
% Also note in the map above that the magnitude of convergence and
% divergene intensifies close to the poles because at high latitudes the
% wind accelerations from one grid cell to the next occur over a smaller
% distance. If you're curious about how grid cell spacing varies around the
% world, explore the effect with the <cdtdim_documentation.html |cdtdim|>
% function. 

%% Example 2: Reality and the ITCZ
% For this example load some global surface wind data that comes with CDT. 
% Load the 10-meter wind speeds |u10| and |v10|, and keep it simple by just
% taking the mean surface winds for 2017:

filename = 'ERA_Interim_2017.nc';
u10 = mean(ncread(filename,'u10'),3);
v10 = mean(ncread(filename,'v10'),3);
lat = double(ncread(filename,'latitude'));
lon = double(ncread(filename,'longitude'));
[Lat,Lon] = meshgrid(lat,lon);

%%
% The raw data are on a grid that goes from 0 to 360 longitude. I'd rather put the prime
% meridian in the middle of the map, so let's <recenter_documentation.html |recenter|> the 
% grids. This step isn't necessary, but it's a preference: 

[Lat,Lon,u10,v10] = recenter(Lat,Lon,u10,v10); 

%%
% Calculating wind divergence is just as simple with real data as it is
% with the synthetic data we created in Example 1. The only adjustment
% we'll make here, for aesthetic purposes, is to mask out land grid cells
% using the <island_documentation.html |island|> function: 

% Calculate wind divergence: 
D = cdtdivergence(Lat,Lon,u10,v10); 

% Mask out land: 
land = island(Lat,Lon); 
D(land) = NaN; 
u10(land) = NaN; 
v10(land) = NaN; 

%%
% Now we can plot wind vectors and their divergence just as in Example 1,
% but this time we'll start with an <earthimage_documentation.html
% |earthimage|> base map for context: 

figure
earthimage;
hold on
pcolor(Lon,Lat,D)
shading interp
hold on 
quiversc(Lon,Lat,u10,v10,'k','density',100)
cb = colorbar; 
ylabel(cb,'surface wind divergence (s^{-1})')
caxis([-1 1]*1e-5)
cmocean balance

%% 
% The map above shows how 10 meter wind vectors converge and diverge around
% the world. It shows a blue region of convergence just north of the
% Equator in the eastern Pacific, and that coincides with the Intertropical 
% Convergence Zone (ITCZ), however, the ITCZ is seasonally migratory, so
% this whole-year average wind field may have the effect of reducing the
% true intensity of the ITCZ at any given time. 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 
