%% |polycenter| documentation 
% The |polycenter| function finds coordinates at the center of the largest section of a
% polygon. This is similar to the centroid, but ensures the coordinates are
% in the interior of the polygon (centroids may be outside of a cresecent
% shape, for example). 
%
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  [xc,yc] = polycenter(P)
%  [xc,yc] = polycenter(S)
%  [lonc,latc] = polycenter(S)
%  [xc,yc] = polycenter(x,y)
%
%% Description
% 
% |[xc,yc] = polycenter(P)| returns the "center" coordinate(s) |xc,yc| of any
% polyshape(s) |P|. 
%
% |[xc,yc] = polycenter(S)| returns the "center" coordinate(s) |xc,yc of| each
% row in the shapefile structure |S|. This syntax assumes the shapefile
% structure S contains the fields |S.X| and |S.Y|. 
%
% |[lonc,latc] = polycenter(S)| returns the "center" longitude and latitude 
% if the shapefile structure S does not contain |S.X| or |S.Y|, but does contain
% |S.Lat| and |S.Lon|.
%
% |[xc,yc] = polycenter(x,y)| returns the "center" coordinate(s) |xc,yc|
% for the inputs coordinates |x,y|. If |x,y| are 1d arrays, the outputs
% |xc,yc| are scalars. If input |x,y| are cell arrays, outputs |xc,yc| will contain a center
% coordinate for the polygons bound by the arrays in each cell. 
% 
%% Example 1
% Start by loading the state outlines (requires Matab's Mapping Toolbox): 

S = shaperead('usastatehi','UseGeoCoords',true); 

%%
% What's wrong with labelling centroids of weird-shaped polygons? Well, the
% centroid isn't always inside the polygon it describes. Consider the case
% of Hawaii: 

% Convert the outline of Hawaii to a polyshape object: 
P = polyshape(S(11).Lon,S(11).Lat); 

% Find the centroid: 
[xcent,ycent] = centroid(P); 

figure
plot(P,'facecolor',rgb('tan'))
hold on
plot(xcent,ycent,'ro')
text(xcent,ycent,'centroid','horiz','center','vert','top')
axis([-160 -154   18.5   22.5])

%% 
% The |polycenter| function finds a better center coordinate than the
% centroid: 

[xc,yc] = polycenter(P); 

plot(xc,yc,'kx') 
text(xc,yc,'polycenter','horiz','center','vert','top')

%% Example 2
% Now find the "center" coordinates of all the states, directly from the
% shapefile structure S: 

[lonc,latc] = polycenter(S);

figure
plot([S.Lon],[S.Lat])
hold on
plot(lonc,latc,'x') 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Kelly Kearney
% and Chad Greene.