%% |tile| documentation
% |tile| determines indices for dividing a matrix into multiple tiles. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  [row,col] = tile(A,maxsiz) 
%  [row,col] = tile(siz,maxsiz)
%  [row,col] = tile(...,'overlap',overlap)
%  [row,col,h_rect,h_txt] = tile(...,'show')
%  
%% Description
% 
% |[row,col] = tile(A,maxsiz)| returns subscript indices |row| and |col| that can
% be used to divide matrix |A| into tiles, each having a maximum size% |maxsiz|. |maxsiz|
% can be a scalar to describe the side dimenions of a square tile, or
% |maxsiz| can be a two-element array to limit tile sizes to rectangular dimensions.
% Outputs |row| and |col| are cell arrays, each cell containing the range of
% subscript indices of one tile of |A|. |A| can be a 2D or 3D matrix, but
% if |A| is a 3D matrix, only its first two dimensions are considered in the tiling
% calculations. 
% 
% |[row,col] = tile(siz,maxsiz)| tiles a matrix of size |siz| into tiles of
% maximum dimensions |maxsiz|. 
% 
% |[row,col] = tile(...,'overlap',overlap)| specifies the number of rows and
% columns by which the tiles overlap. overlap can be a scalar or a two-element 
% array. 
% 
% |[row,col,h_rect,h_txt] = tile(...,'show')| displays numbered rectangles on
% a plot, showing the tiles. Optional outputs |h_rect| and |h_txt| are handles
% of the plotted rectangles and text labels. 
%
%% Examples
% Suppose you have this 20x20 matrix: 

Y = peaks(20); 

imagesc(Y)
xlabel 'column \rightarrow'
ylabel '\leftarrow row' 

%% 
% But 20x20 is too big for whatever processing algorithm you want to apply to
% |Y|. It would require too much memory to process the entire matrix at
% once, so you want to break it up into smaller, bite-size pieces no bigger
% than 5x5 each. Here's how to do that: 

[row,col] = tile(Y,5);

%%
% Now we have |row| and |col|, which as you can see: 

whos row col

%% 
% are each 4x4 cell arrays. Each cell contains the row or column indices 
% that describe a single tile of |Y|. So for example, the row indices of
% the first tile of |Y| are given by 

row{1}

%% 
% Show all the tiles and their numbers atop the plot of the matrix |Y| by 
% including the |'show'| option when you call |tile|:

tile(20,5,'show');
title 'tile numbers'

%% 
% The figure above shows that as we would expect, breaking the 20x20 matrix
% |Y| into tiles, each no larger than 5 rows by 5 columns, results in 16
% square tiles. Now it's easy to extract a single tile. For example, to
% show tile number 10, use |Y(row{10},col{10})|, like this: 

figure
imagesc(col{10},row{10},Y(row{10},col{10}))

title 'tile 10'
xlabel 'column \rightarrow'
ylabel '\leftarrow row' 

%% Uneven sizes
% What if the size of |Y| isn't perfectly divisible by the maximum tile
% size? In that case, the resulting tiles will have different sizes. 
%
% What if the maximum tile size you want isn't square? In that case, specify
% the maximum tile size in the form |[maxrow maxcol]|. 
% 
% Here's how to specify a maximum tile size that isn't square, and that
% doesn't evenly divide the matrix |Y|: 

figure
imagesc(Y)
xlabel 'column \rightarrow'
ylabel '\leftarrow row' 

tile(Y,[9 4],'show');

%% Specifying overlap 
% For some applications it's necessary to have overlapping tiles. Here's
% how to add an extra row and column to each tile, such that they overlap: 

figure
imagesc(Y)
xlabel 'column \rightarrow'
ylabel '\leftarrow row' 

tile(Y,[9 6],'overlap',1,'show');

%% Process a 2D grid
% Suppose you have a big 2160x4320 dataset and you want to process it in 
% tiles no larger than 300x300. Load the dataset and get the rows |r| and
% columns |c| of each tile: 

load global_topography.mat

[r,c] = tile(Z,300); 

%% 
% To process the 2D matrix |Z| in tiles, we'll loop through each of the
% 8x15=120 tiles, and we'll process each tile individually. In this
% example, let's say the processing we want to do is flip each tile upside
% down. Start by preallocating |Zf|, then operate on each tile:  

% Preallocate the output grid: 
Zf = nan(size(Z)); 

% Loop through each tile: 
for k = 1:numel(r)
   Zf(r{k},c{k}) = flipud(Z(r{k},c{k})); 
end

figure
imagescn(lon,lat,Zf) 
cmocean('topo','pivot')
xlabel 'longitude'
ylabel 'latitude'
title 'each tile flipped upside down'

%% Operate on a 3D matrix
% The |tile| function was designed primarily to help with large 3D gridded
% time series that can sometimes strain the limits of your computer's
% memory. To illustrate how to use this function on such datasets, we'll
% operate on a relatively small gridded time series, the monthly surface
% pressure dataset that comes with CDT:

sp = ncread('ERA_Interim_2017.nc','sp');
lat = ncread('ERA_Interim_2017.nc','latitude');
lon = ncread('ERA_Interim_2017.nc','longitude');

%%
% The surface pressure dataset is 480x241x12. That "12" at the end
% corresponds to each of the 12 months of 2017. 
% 
% What did the median surface pressure look like in 2017? For a small
% dataset like this we can simply do

spm = median(sp,3); 

%% 
% but if the |sp| dataset were much larger we might need to break it into
% tiles. To break it into tiles, say each no larger than 50x50, get the
% rows and columns of each tile like this: 

[r,c] = tile(sp,50); 

%% 
% Then to compute the median of |sp| along its third dimension, do
% something similar to the 2D example above, but add an extra |,:| in the
% indices to indicate "these rows, these columns, and everything along the
% third dimension". 
% 
% Begin by preallocating |spm|, then calculate the median along the third
% dimension of each tile: 

% Preallocate: 
spm = nan(length(lon),length(lat)); 

% Loop through each tile: 
for k = 1:numel(r) 
   spm(r{k},c{k}) = median(sp(r{k},c{k},:),3); 
end

%%
% Plot the 2017 median surface pressure, which we just computed in tiles: 

figure
imagescn(lon,lat,spm')
cmocean tempo % sets the colormap 

%% 
% It looks about right, but we can verify that the tiled solution matches
% the all-at-once solution like this

isequal(spm,median(sp,3))

%% 
% The |1|, or |true| value says yes, the tiled soltuion matches the
% non-tiled solution. 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 