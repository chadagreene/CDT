%% |dist2coast| documentation
% |dist2coast| determines the distance from any geolocation to the nearest coastline.
% 
% See also: <island_documentation.html |island|> and <topo_interp_documentation.html |topo_interp|>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  di = dist2coast(lati,loni)
% 
%% Description 
% 
% |di = dist2coast(lati,loni)| gives the great-circle distance |di| in kilometers from the 
% geolocation(s) |lati,loni| to the nearest coast line. For points on land, |di| is the 
% distance to the nearest ocean. For oceanic locations, |di| is the distance to the nearest
% land. 
% 
%% Example 1: Global grid
% For a quick example, use <cdtgrid_documentation.html |cdtgrid|> to create a quarter-degree global
% grid of Lat,Lon points, and determine how far each point is from the nearest coast line: 

% Quarter degree grid: 
[Lat,Lon] = cdtgrid(0.25); 

% Distances to nearest coastline: 
D = dist2coast(Lat,Lon); 

%% 
% Plot the distances to the nearest coast using <imagescn_documentation.html |imagescn|>: 

imagescn(Lon,Lat,D) 
cb = colorbar('location','southoutside'); 
xlabel(cb,'distance to nearest coastline (km)')

%% 
% The first thing you might notice in the figure above is that some place in the Pacific 
% appears to be more than 5000 km from the nearest land. That's actually false. (See the *Limitations*
% section below for more details on that.)
% 
% The second thing you'll notice is that distances from the coast are positive everywhere, 
% whether on land or in the sea. If you'd like you can use the <island_documentation.html |island|>
% function to dermine which cells are land versus which are ocean, and then set the land
% cells to negative values, like this: 

land = island(Lat,Lon); 

% Make land distances negative: 
D(land) = -D(land); 

figure
imagescn(Lon,Lat,D) 
cb = colorbar('location','southoutside'); 
xlabel(cb,'distance to nearest coastline (km)')
cmocean('diff','pivot') 
borders 

%% 
% Above we set the colormap to <cmocean_documentation.html |cmocean|> _tarn_ (Thyng et al., 2016) 
% and made it "pivot" about the zero value. Also added political boundaries with the 
% <borders_documentation.html |borders|> function. 

%% Example 2: Oceanic floats
% Example 1 looked at a global grid, but now let's consider the case of scattered data. For example, 
% Argo floats in the northern Indian Ocean. Here are some random data points that could be 
% such Argo floats: 

% 1500 random points around the Indian Ocean: 
lat = 40*rand(1500,1)-10; 
lon = 60*rand(1500,1)+40; 

% Limit this random dataset to ocean points: 
land = island(lat,lon); 
lat(land) = []; 
lon(land) = []; 

% Plot the random datapoints: 
figure
plot(lon,lat,'.','color',rgb('gray'))
hold on
he = earthimage;     % adds an earth image
uistack(he,'bottom') % places earth image below dots 

%%
% Find out how far each float is from land and plot the distaces as scattered datapoints:

d = dist2coast(lat,lon); 

scatter(lon,lat,30,d,'filled') 

cb = colorbar; 
ylabel(cb,'distance to nearest land (km)')

cmocean -matter % sets the colormap

%% Masking based on distance to land
% Suppose you're only interested in data that's between 200 and 500 km from
% the coast. Get the indices corresponding to those points and use <rgb_documentation.html 
% |rgb|> to plot them as electric blue x marks: 

ind = d>200 & d<500; 

plot(lon(ind),lat(ind),'x','color',rgb('electric blue'))

%% Contouring
% To make contour lines of distances from the coast, use |meshgrid| or <cdtgrid_documentation.html 
% |cdtgrid|> to make a grid, get the distances of each grid point to the nearest coastline, 
% and use <island_documentation.html |island|> to mask out the land grid cells: 

% Make a grid: 
[Lon,Lat] = meshgrid(40:0.1:100,-10:0.1:30);

% Get distances from grid points to coast: 
D = dist2coast(Lat,Lon); 

% Mask out land: 
D(island(Lat,Lon)) = NaN; 

% Contour and label the contours: 
[C,h] = contour(Lon,Lat,D); 
clabel(C,h,'color','w')

%% Limitations
% In Example 1, one of the first things we see is some place in the Pacific that appears to 
% be more than 5000 km from land. In reality, the farthest point from land is Point Nemo, at
% (37.58S,139.39W) and a mere 2688 km from the nearest land. The reason |dist2coast| is
% so far off on this, is because |dist2coast| uses the same 1/8 degree mask as the <island_documentation.html 
% |island|> function to determine the presence of land. Any land that is not large enough to 
% be present in the 1/8 degree dataset is not represented by |island| or |dist2coast|. 
% Accordingly, this function is probably best suited for mesoscale processes that aren't 
% affected by little islands. 
% 
% Also noteworthy: the |dist2coast| function considers the Great Lakes of North America and other 
% large bodies of freshwater to be not land, but water. As a result, the farthest distance
% from water in North America is in Wyoming, rather than somewhere in Canada where there are 
% lots of big lakes. 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 