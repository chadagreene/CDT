%% |detrend3| documentation
% |detrend3| performs linear least squares detrending along the third dimension
% of a matrix.
% 
% See also: <trend_documentation.html |trend|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  Ad = detrend3(A) 
%  Ad = detrend3(A,t)
% 
%% Description
% 
% |Ad = detrend3(A)| removes the linear trend from the third dimension of |A|
% assuming slices of |A| are sampled at constant intervals. 
% 
% |Ad = detrend3(A,t)| specifies times |t| associated with each slice of A. 
% Times |t| do not need to occur at regular intervals in time. 
% 
%% Example 1: A 3D gridded dataset 
% This sample dataset has a trend of 3.2 units/timestep everywhere: 

t = 50:50:1000; 
y = 3.2*t + 0.1*randn(size(t)); % the trend is 3.2*t (plus some random noise)

% Create 5x5 grid w/trend dictated by y: 
Z = expand3(ones(5),y); 

%%
% Here's proof via the <trend_documentation.html |trend|> trend function: 

trend(Z,t)

%% 
% Now let's detrend: 

Z_detrend = detrend3(Z,t); 

%%
% And now what's the trend? 

trend(Z_detrend,t)

%% 
% Just numerical noise (note that it is zero to the level of 1.0e-14). 

%% Example 2: Sea Surface Temperatures 
% This example calculates an area-averaged sea surface temperature anomaly 
% from a gridded time series, then _detrends_ the gridded sst time series 
% and plots the detrended anomaly time series. 
% 
% Begin by loading the sample pacific_sst.mat dataset of monthly SSTs. Use 
% <cdtarea_documentation.html |cdtarea|> to get the area of each grid cell, 
% and then use <local_documentation.html |local|> to get the 1D time series 
% of area-weighted ssts for all ocean grid cells. 

% Load example data: 
load pacific_sst

% Turn lat,lon arrays into grids: 
[Lon,Lat] = meshgrid(lon,lat); 

% Get the area (m^2) of each grid cell: 
A = cdtarea(Lat,Lon); % area of each grid cell (m^2)

% Make a mask of only finite data (to effectively ignore land)
mask = all(isfinite(sst),3); 

% Get 1D time series of area-weighted sst: 
sst_1 = local(sst,mask,'weight',A); 

%% 
% Now plot the area-weighted sst anomaly using the <anomaly_documentation.html |anomaly|> 
% function. For context, plot the linear trend with <polyplot_documentation |polyplot|>: 

figure
anomaly(t,sst_1-mean(sst_1))
axis tight
datetick('x','keeplimits') 
ntitle('sea surface temperature anomaly (not detrended)')

hold on
polyplot(t,sst_1-mean(sst_1),1,'k','linewidth',3)

%% 
% Now detrend the entire 3D sst dataset and plot the same area-averaged 
% time series, but this time using the detrended data: 

% Detrend the full 3d time series: 
sst_dt = detrend3(sst); 

% Get the area-averaged detrended SST time series: 
sst_dt_1 = local(sst_dt,mask,'weight',A); 

figure
anomaly(t,sst_dt_1-mean(sst_dt_1))
axis tight
datetick('x','keeplimits') 
ntitle('DETRENDED sea surface temperature anomaly')

hold on
polyplot(t,sst_dt_1-mean(sst_dt_1),1,'k','linewidth',3)

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 