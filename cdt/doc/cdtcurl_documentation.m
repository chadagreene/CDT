%% |cdtcurl| documentation 
% |cdtcurl| calculates the z component of curl for gridded vectors on an ellipsoidal Earth.
% 
% See also: <cdtgradient_documentation.html |cdtgradient|>, <cdtdivergence_documentation.html |cdtdivergence|>
% and <ekman_documentation.html |ekman|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  Cz = cdtcurl(lat,lon,U,V)
% 
%% Description
% 
% |Cz = cdtcurl(lat,lon,U,V)| uses <cdtdim_documentation.html |cdtdim|> to estimate the dimensions of each grid cell in the 
% |lat,lon| grid, then computes the curl of the gridded vectors |U,V|. 
%
%% Example
% Load this sample of 10-meter winds |u| and |v|. Note that when we load the wind data, we're
% just taking the mean winds for this example. 

filename = 'ERA_Interim_2017.nc';
u = mean(ncread(filename,'u10'),3);
v = mean(ncread(filename,'v10'),3);
lat = double(ncread(filename,'latitude'));
lon = double(ncread(filename,'longitude'));
[Lat,Lon] = meshgrid(lat,lon);

%%
% The raw data are on a grid that goes from 0 to 360 longitude. I'd rather put the prime
% meridian in the middle of the map, so let's <recenter_documentation.html |recenter|> the 
% grids. This step isn't necessary, but it's a preference: 

[Lat,Lon,u,v] = recenter(Lat,Lon,u,v); 

%%
% Here are the winds on a global map:  

figure
earthimage 
hold on

q = quiversc(Lon,Lat,u,v,'density',75);

legend(q,'wind speed')

%% 
% To illustrate the use of the |cdtcurl| function, we can recreate <http://booksite.academicpress.com/DPO/chapterS11.html 
% Figure S11.03a> of the Sixth Edition of Talley et al.'s book, <https://doi.org/10.1016/B978-0-7506-4552-2.10023-X
% Descriptive Physical Oceanography>.
% 
% Start by using the <windstress_documentation.html |windstress|> function to convert the 10 meter wind 
% speed vectors to wind stress in N/m^2: 

[Taux,Tauy] = windstress(u,v);

%% 
% Now use |cdtcurl| to get the global wind stress curl: 

C = cdtcurl(Lat,Lon,Taux,Tauy); 

%% 
% Use <island_documentation.html |island|> to mask out the grid cells corresponding to land, 
% and following Talley et al., multiply southern hemisphere curls by negative 1: 

% Mask out land: 
land = island(Lat,Lon); 
C(land) = NaN;
Taux(land) = NaN; 
Tauy(land) = NaN; 

% Multiply southern hemisphere curl by negative 1: 
C = C.*sign(Lat); 

%% 
% Now we're ready to recreate Talley et al.'s map relating wind stress to wind stress
% curl: 

figure
pcolor(Lon,Lat,C)
shading flat
hold on

% Overlay continents: 
borders('countries','facecolor',rgb('gray'),'edgecolor','none'); 

% Overlay wind stress vectors: 
quiversc(Lon,Lat,Taux,Tauy,'k','density',100)

% Jet is never a good idea, but we'll do it to mimic the published figure:
colormap(jet(20)) 

% Set the color axis limits and make a colorbar: 
caxis([-2 2]*1e-7) 
cb = colorbar('location','southoutside'); 
xlabel(cb,'wind stress curl x sign(lat) (\times10^{-7} N/m^3)')

% Set map extents: 
axis([10 150 -60 30])

% Format tick labels as degrees: 
xtickformat('degrees')
ytickformat('degrees')

%% 
% In case you're curious, here's the same figure with a more appropriate, divergent 
% colormap from <cmocean_documentation.html |cmocean|> (Thyng et al., 2016)

cmocean bal

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 
