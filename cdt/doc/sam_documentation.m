%% |sam| documentation 
% |sam| computes a version of the Southern Annular Mode index, also known as
% the Antarctic Oscillation.
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax 
% 
%  idx = sam(slp40,slp65,t) 
% 
%% Description 
% 
% |idx = sam(slp40,slp65,t)| calculates the Southern Annular Mode index 
% from two time series of sea-level pressures at two latitudes (40S and 65S) 
% and their corresponding times |t|. 
% 
%% Example
% Here, we'll recreate Figure 7 from Marshall's classic 2003 paper, 
% Trends in the Southern Annular Mode from observations and reanalyses 
% (Marshall, <https://journals.ametsoc.org/doi/pdf/10.1175/1520-0442%282003%29016%3C4134%3ATITSAM%3E2.0.CO%3B2 
% 2003>), which depicts the monthly SAM index.

%% Load Data 
% We can load data containing zonal-mean SLP at 40S and 65S calculated
% from observations from 1957 January to 2018 December.

load sam_slp_data.mat

%% Plot pressure data
% The sam_slp_data.mat file contains monthly zonal mean pressures from 1957
% to 2018. (A note on how to get these types of zonal mean pressures from
% gridded data appears at the bottom of this page.) Here is the pressure
% data we'll use to calculate SAM:

figure
plot(t,slp40); 
hold on
plot(t,slp65)
axis tight
legend('mean SLP at 40\circS','mean SLP at 65\circS') 

%% Calculate SAM index
% The |sam| function normalizes each time series relative to a 1971-2000
% baseline, and differences the two pressure anomaly time series to yield the
% SAM index. 

% Calculate SAM index: 
sam_idx = sam(slp40,slp65,t);

figure
plot(t,sam_idx,':','color',rgb('gray'));
hold on
plot(t,movmean(sam_idx,12),'k','linewidth',1)
ylabel('SAM Index')
xlabel('Year')
xlim([datetime(1955,1,1) datetime(2005,1,1)]) % sets date limits
ylim([-8 8])                                  % sets vertical limits
hline(0,'k--')                                % draws horizontal line 

%% 
% Above, the built-in Matlab function |movmean| was used to calculate the
% 12 month moving mean, and a horizontal dashed line was drawn with
% <hline_documentation.html |hline|> to match Marshall's Figure 7. 

%% Getting zonal mean pressures
% The example above begins by loading zonal mean pressures from 40S and
% 65S. If you're working with gridded data you'll need to calculate the
% zonal means at 40S and 65S. Do that like this. Start by loading some
% example data: (using <ncdateread_documentation.html |ncdateread|> to read
% the date time). 

lat = double(ncread('ERA_Interim_2017.nc','latitude'));
lon = double(ncread('ERA_Interim_2017.nc','longitude'));
t = ncdateread('ERA_Interim_2017.nc','time');
sp = ncread('ERA_Interim_2017.nc','sp');

%% 
% A brute force way to get the zonal means at 40S and 65S is to interpolate
% to 40S and 65S at each unique longitude in the grid, and then average the
% results, for each timestep. Begin by preallocating the outputs, then loop
% through each time step, interpolating to 40S and 65S

% Preallocate zonal mean pressure time series: 
slp40 = NaN(size(t)); 
slp65 = NaN(size(t)); 

% Loop through each time step: 
for k = 1:length(t)
   
   % Take the mean of SLPs at all longitides, interpolated to 40S:
   slp40(k) = mean(interp2(lat,lon,sp(:,:,k),-40*ones(size(lon)),lon)); 
   
   % Take the mean of SLPs at all longitides, interpolated to 65S:
   slp65(k) = mean(interp2(lat,lon,sp(:,:,k),-65*ones(size(lon)),lon)); 
end

figure
plot(t,slp40)
hold on
plot(t,slp65)

legend('mean SLP at 40\circS','mean SLP at 65\circS') 

%% Reference
% 
% Marshall, G. J., 2003: Trends in the Southern Annular Mode 
% from observations and reanalyses. J. Clim., 16, 4134-4143.

%% Author Info
% The |enso| function and supporting documentation were written by <Kaustubh Thirumalai http://www.kaustubh.info> 