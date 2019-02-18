%% |cdtgrid| documentation
% The |cdtgrid| function uses |meshgrid| to easily create a global grid of latitudes and longitudes. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax 
% 
%  [lat,lon] = cdtgrid
%  [lat,lon] = cdtgrid(res) 
%  [lat,lon] = cdtgrid([latres lonres])
%  [lat,lon] = cdtgrid(...,centerLon) 
% 
%% Description 
% 
% |[lat,lon] = cdtgrid| generates a meshgrid-style global grid of latitude and longitude
% values at a resolution of 1 degree. Postings are centered in the middle of grid cells, 
% so a 1 degree resolution grid will have latitude values of 89.5, 88.5, 87.5, etc.  
% 
% |[lat,lon] = cdtgrid(res)| specifies grid resolution |res|, where |res| is a scalar and 
% specifies degrees. Default |res| is |1|.
%
% |[lat,lon] = cdtgrid([latres lonres])| if |res| is a two-element array, the first element 
% specifies latitude resolution and the second element specifies longitude resolution. 
%  
% |[lat,lon] = cdtgrid(...,centerLon)| centers the grid on longitude value |centerLon|. Default
% |centerLon| is the Prime Meridian (|0| degrees). 
% 
%% Example 1: Real simple
% Here's a 1-degree global grid: 

[lat,lon] = cdtgrid; 

plot(lon,lat,'b.')
xlabel('longitude') 
ylabel('latitude')

%% 
% Above, it looks like a big blue rectangle, but zoom in and you'll see 
% that it's actually 180 * 360 = 64,800 blue dots. 

%% Example 2: More complicated
% Now overlay a grid that has 10 degree latitude resolution and 15 degree longitude resolution, 
% centered on 180°E. Plot the new grid as red circles to distinguish them 
% from the blue dots: 

[lat2,lon2] = cdtgrid([10 15],180); 

hold on
plot(lon2,lat2,'ro')

%% 
% The two grids do not line up with each other because we intentionally 
% ensured that the second grid would be centered on 180°E. Use the <recenter_documentation.html |recenter|> 
% function to move them back over if you'd like: 

[lat2_rc,lon2_rc] = recenter(lat2,lon2); 

plot(lon2_rc,lat2_rc,'kx')

%% Author Info
% The |cdtgrid| function and supporting documentation were written by <http://www.chadagreene Chad A. Greene> of the University
% of Texas at Austin, Institute for Geophysics (UTIG), February 2017.  