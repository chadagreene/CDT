%% |near1| documentation
% |near1| finds the linear index of the point in an array closest to a 
% specified coordinate. 
% 
% See also <near2_documentation.html |near2|>, <geomask_documentation.html
% |geomask|>, and <local_documentation.html |local|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  ind = near1(x,xi) 
%  [ind,dst] = near1(x,xi) 
% 
%% Description 
% 
% |ind = near1(x,xi)| returns the index |ind| of the point in |x| closest to |xi|. 
% If |xi| is equidistant between two |x| values, |ind| corresponds to the first
% of the two. 
% 
% |[ind,dst] = near1(x,xi)| also returns the ditance |dst| between |x(ind)| and |xi|. 
% 
%% Example 1
% For this array of |x| values, which point in the array is closest to
% |xi=51|? 

x = 10:10:100
xi = 51; 

%%
% The index of the x value closest to 51 is: 

ind = near1(x,xi)

%%
% If you also want to know the distance from |x(ind)| and |xi|, get the
% second ouput from |near1|: 

[ind,dst] = near1(x,xi); 
dst

%%
% That is, the value |x(ind)=50| is one unit lower than the query value
% |xi=51|. 

%% 
% What if a query point is halfway between two x values? The way that 55 is
% halfway between 50 and 60? 

ind = near1(x,55)

%% 
% In the case of multiple equally valid answers, |near1| only returns the
% first valid index. 

%% Example: Climate data application
% The |near1| function can be useful for finding the row and column of a
% grid point closest to a location of interest in a gridded climate time
% series. This example is similar to examples in the documentation for <near2_documentation.html
% |near2|> to <geomask_documentation.html |geomask|>, but is applied
% slightly differently. 
% 

load pacific_sst   % loads example data

whos lat lon sst t % displays the size of these variables

%%
% Those linear arrays |lat| and |lon| correspond to the first two
% dimensions of the 3D SST array. We can use |near1| to get the time series 
% of SSTs close to Honolulu, Hawaii (21.3 N, 157.8 W).

row = near1(lat,21.3); 
col = near1(lon,-157.8); 

%%
% And the SST time series can be plotted like this. Just remember to use
% |squeeze| to get the resulting 1x1x802 array into an 802x1 shape so
% |plot| will be able to handle it: 

sst1 = sst(row,col,:); 

plot(t,squeeze(sst1))
axis tight
datetick('x','keeplimits') 
xlabel date
ylabel 'temperature \circC' 

%% 
% Just to be sure, verify that the row and column actually correspond to
% latitudes and longitudes close to Honolulu: 

[lat(row) lon(col)]

%% 
% Yep, that's about as close as we can get to (21.3 N, 157.8 W). 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 