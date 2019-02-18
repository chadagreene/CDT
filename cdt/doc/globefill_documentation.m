%% |globefill| documentation
% The |globefill| function plots a filled globe. Optional inputs control
% the appearance and behavior of the globe.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  globefill
%  globefill(...,'color',ColorSpec)
%  globefill(...,'radius',GlobeRadius)
%  h = globefill(...)
% 
%% Description
% 
% |globefill| creates a white globe that can be used to fill the empty
% space of such plots as |globeplot|. 
%
% |globefill(...,'color',ColorSpec)| specifies the color of the filled
% globe.
% 
% |globefill(...,'radius',Radius)| specifies the radius of the sphere as
% |Radius|. By default, the radius is 6307.3, which is 99 percent of the standard
% Earth 6371 km Earth radius. The globefill radius is slightly smaller than 
% the standard radius used by other |globe*| functions to prevent unwanted 
% interactions. 
% 
% |h = globefill(...)| returns the handle |h| of the plotted objects. 
%
%% Example 1
% Plot a simple white globe:

figure
globefill

camlight
material dull 

%% 
% (For the figure above we had to turn on |camlight| because without the 
% fancy lighting, a white globe on a white background would be invisible.)
%
% Add a graticule:

globegraticule('linestyle','--')

%% Example 2
% Plot a reddish brown globe of radius 2500 km, and then add a black <globegraticule_documentation.html
% |globegraticule|> at the default Earth radius:

figure
globefill('color',rgb('reddish brown'),'radius',2500)
globegraticule('color','k')
camlight

%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger for the Climate Data Toolbox for Matlab, 2019. 