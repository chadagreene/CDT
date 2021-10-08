%% |isoverlapping| documentation 
% The |isoverlapping| function determines whether geographic boundingboxes overlap.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  tf = isoverlapping(S,S0)
%  tf = isoverlapping(BoundingBoxes,BoundingBox)
% 
%% Description 
% 
% |tf = isoverlapping(S,S0)| returns true for any of the BoundingBoxes in 
% the shapefile structure S that overlap with the BoundingBox identified by
% the shapefile structure S0. 
% 
% |tf = isoverlapping(BoundingBoxes,BoundingBox)| returns true for any of the 
% BoundingBoxes that overlap with BoundingBox. Here, BoundingBoxes must have
% the dimensions 2x2xN, which can be obtained by cat(3,S.BoundingBox). The 
% reference BoundingBox must have the dimensions 2x2. 
% 
%% Example 
% Start by loading these example shapefiles (requires Matlab's Mapping
% Toolbox): 

Sr = shaperead('concord_roads.shp');
Sa = shaperead('concord_hydro_area.shp');

% Convert Sa to a polyshape (for no particular reason, except that we can):  
P = polyshape([Sa.X],[Sa.Y]);

%% 
% Plot the data for context

% Plot the hydo areas as blue water: 
figure
plot(P,'facecolor',rgb('water blue'),'edgecolor','none')
axis image

% Add roads: 
hold on
plot([Sr.X],[Sr.Y],'color',rgb('gray'))

%% 
% Now consider this section of water: 

plot(Sa(98).X,Sa(98).Y,'r','linewidth',2)

%% 
% Which sections of road have bounding box coordinates that overlap with
% the bounding box of that section of water? 

tf = isoverlapping(Sr,Sa(98)); 

plot([Sr(tf).X],[Sr(tf).Y],'color',rgb('orange'),'linewidth',2)

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of NASA's Jet Propulsion Laboratory. 