%% |globegraticule| documentation
% The |globegraticule| function plots a graticule globe. Optional inputs
% control the appearance and behavior of the graticule.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  globegraticule
%  globegraticule(lat,lon)
%  globegraticule(...,LineProperty,LineValue)
%  globegraticule(...,'radius',GlobeRadius) 
%  h = globegraticule(...)
% 
%% Description
% 
% |globegraticule| plots a graticule or grid on an empty globe. 
%
% |globegraticule(lat,lon)| specifies latitudes and longitudes depicted by
% the graticule.
% 
% |globegraticule(...,LineProperty,LineValue)| plots a graticule with
% user-specified line properties to control appearance and behavior. 
% 
% |globegraticule(...,'radius',GlobeRadius)| specifies the radius of the
% graticule as |GlobeRadius|. Default |GlobeRadius| is 6371. 
% 
% |h = globegraticule(...)| returns the handle |h| of the plotted objects. 
% 
%% Example 1
% Plot a simple, gray graticule on a globe: 

figure
globegraticule

%% 
% The globe above is an empty wire frame. Fill it in with
% <globefill_documentation.html |globefill|>:

globefill

%% Example 2
% Plot a red graticule: 

figure
globegraticule('color','r')
globefill 

%% Example 3
% Add a thick, blue, dashed line along the equator:

globegraticule(0,[],'color','b','linestyle','--','linewidth',4)

%% Example 4
% Plot a graticule with $$10^{\circ} {\times} 10^{\circ}$ latitude and lonitude bins:

figure
globegraticule(-90:10:90,0:10:360)

%% Example 5
% Plot a graticule on top of other data and specify viewing geometry: 

[lat,lon] = cdtgrid; 
z = topo_interp(lat,lon); 

figure
globepcolor(lat,lon,z)
hold on
axis tight
view(30,40) % defines viewing angle (azimuth,elevation)

globegraticule('linestyle',':')

camlight % adjusts lighting
material dull % adjusts the reflectance

%%
% Draw the equator and prime meridian: 

globegraticule(0,[],'color','k','linewidth',1) % equator 
globegraticule([],0,'color',[0 0.5 0],'linewidth',1) % prime meridian

%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for the Climate Data Toolbox for Matlab, 2019. 