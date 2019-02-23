%% |solar_radiation| documentation 
% The |solar_radiation| function computes modern daily total extraterrestrial solar radiation
% received at the top of Earth's atmosphere.
% 
% This function is quite similar to the <daily_insolation_documentation.html |daily_insolation|> function, and one 
% may suit your needs better than the other. The |daily_insolation| function
% is best suited for investigations involving orbital changes over tousands 
% to millions of years, whereas |solar_radiation| may be easier to use
% for applications such as present-day precipitation/drought research.
%
% <CDT_Contents.html Back to Climate Data Tools Contents>. 
%% Syntax
%
%  Ra = solar_radiation(t,lat)
%   
%% Description
% 
% |Ra = solar_radiation(t,lat)| calculates the extraterrestrial radiation (MJ m^(-2)
% day^(-1)) based on the dates |t| and latitude |lat|. Dates |t| can be in datetime, 
% datenum, or datestr format, but must be a 1D array or a scalar. lat can be scalar, 
% vector, or grid. If |lat| is a vector or array with size nrows and ncols
% then |Ra| has the size |[nrows,ncols,length(t)]|.
% 
%% Example: A solar panel in Berlin
% Let's assume you have a 1 square meter solar panel in Berlin, Germany (52.5N,13.4E).
% If there were no atmosphere, how many joules of energy would it receive per day
% from March 1, 2017 to March 1, 2019? 

% define an array of dates: 
t = datetime('march 1, 2017'):datetime('march 1, 2019'); 

% define the latitude of Berlin:
lat = 52.5; 

% Calculate daily total radiation: 
Ra = solar_radiation(t,lat); 

% Plot the time series: 
figure
plot(t,Ra)
axis tight
box off % removes frame
ylabel 'daily radiation MJ m^{-2}'

%% References
% The |solar_radiation| function computes the equation by 
% 
% * Allen et al. (1998), 
% * McMahon, T. A., et al. "Estimating actual, potential, reference crop and pan 
% evaporation using standard meteorological data: a pragmatic synthesis." Hydrology 
% and Earth System Sciences 17.4 (2013): 1331-1363 <https://doi.org/10.5194/hess-17-1331-2013>.
% * McCullough and Porter (1971) 
% * McCullough (1968)
% 
% See also the supplement to McMahon et al 2013  
% <https://www.hydrol-earth-syst-sci.net/17/1331/2013/hess-17-1331-2013-supplement.pdf here.>
% 
%% Author Info
% The |solar_radiation| function was written by José Delgado and Wolfgang Schwanghart 
% (University of Potsdam). February 2019. Climate Data Toolbox for Matlab.