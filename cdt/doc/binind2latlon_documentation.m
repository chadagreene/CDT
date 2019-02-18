%% |binind2latlon| documentation 
% |binind2latlon| converts binned index values of a sinusoidal grid to geocoordinates. 
% 
% More information on the sinusoidal grid <https://oceancolor.gsfc.nasa.gov/docs/format/l3bins here>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  [lat,lon] = binind2latlon(binind) 
%  [lat,lon] = binind2latlon(...,'rows',NumberOfRows) 
% 
%% Description 
% 
% |[lat,lon] = binind2latlon(binind)| gives the geo coordinates for the bin indices |binind|. 
% 
% |[lat,lon] = binind2latlon(...,'rows',NumberOfRows)| specifies the number of rows in the 
% grid. By default, binind2latlon will try to figure out the number of rows automatically, 
% but there's no guarantee it'll work. If you know the number of rows, specify them just
% to be sure. According to the Resolutions table <https://oceancolor.gsfc.nasa.gov/docs/format/l3bins/ here>, 
% common numbers of rows are as follows: 
% 
% * 180 rows for 1 a degree grid
% * 2160 rows for 5 minute grid
% * 4320 rows for a 1.5 minute grid
% 
%% Example 1: A small grid
% Let's recreate the simple 18 row example seen <https://oceancolor.gsfc.nasa.gov/docs/format/l3bins/ here>. 
% Start by plotting national borders with my <https://www.mathworks.com/matlabcentral/fileexchange/50390-borders |borders|>
% function: 

borders('countries','k-') 
axis tight
xlabel 'longitude'
ylabel 'latitude' 

%%
% The example on the NASA site contains 412 bins that span 18 rows of latitude: 

% List of bin numbers: 
bins = (1:412)'; 

% What geocoordinates correspond to each bin number? 
[lat,lon] = binind2latlon(bins,'rows',18); 

% Label each bin centered on its geocoordinate: 
text(lon,lat,num2str(bins),'color','r','horiz','center','fontsize',6) 

%% Example 2: Actual data
% This example uses some monthly CHL data found <https://oceandata.sci.gsfc.nasa.gov/MODIS-Aqua/Binned/Monthly/CHL here>.
% Start by reading in the data. Although these files end in .nc, the <https://www.mathworks.com/help/matlab/ref/ncread.html |ncread|>
% function does not recognize the datatype for the variables we want to plot. So we have to use <https://www.mathworks.com/help/matlab/ref/h5read.html
% |h5read|> instead: 

A = h5read('A20021822002212.L3b_MO_CHL.nc','/level-3_binned_data/chlor_a');
B = h5read('A20021822002212.L3b_MO_CHL.nc','/level-3_binned_data/BinList');

% For convenience, assign z and bins as variables: 
z = double(A.sum_squared); 
bins = B.bin_num; 

%%
% The geocoordinates of each of those |z| values can be found quite easily:

[lat,lon] = binind2latlon(bins); 

%% 
% Notice there are over 11 million measurements here, so we might want to look at just the 
% measurements in a small area, say the Indian Ocean, in the region (40S-20N, 35E-110E).
% Get the indices corresponding to these coordinates with <geomask_documentation |geomask|>: 

ind = geomask(lat,lon,[-40 20],[35 110]); 

%% 
% There are 1625033 datapoints in that geographic region, and unfortunately they don't make a perfect grid, so if you want gridded data you'll have to use 
% <https://www.mathworks.com/help/matlab/ref/griddata.html |griddata|> or <https://www.mathworks.com/help/matlab/ref/scatteredinterpolant-object.html |scatteredInterpolant|>. 
% Or you can make a scatterplot of the data. Old versions of Matlab like the one I'm using choke when 
% you give |scatter| a lot of data points, so below I'm using Aslak Grinsted's <https://www.mathworks.com/matlabcentral/fileexchange/47205-fastscatter-m
% |fastscatter|> function. I'm also using the <cmocean_documentation.html |cmocean|> colormap (Thyng et al., 2016). 
 
figure
fastscatter(lon(ind),lat(ind),z(ind),'markersize',.1) 
axis tight
caxis([0 4])
cb = colorbar; 
ylabel(cb,'sum squared') 
cmocean algae
borders('countries','facecolor',0.6*[1 1 1]) 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% This function and supporting documentation were written by Chad A. Greene of the University of Texas at Austin. 