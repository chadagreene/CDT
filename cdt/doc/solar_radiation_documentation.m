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
%% Example 1: A solar panel in Berlin
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

%% Example 2: Solar energy in the world's oceans
% Before we begin this example, it's important to note that the |solar_radiation| 
% function estimates the top-of-atmosphere radiation, so the following discussion
% ignores all atmospheric effects. With that caveat in mind let's consider how 
% much solar energy hits the Earth's oceans on a given day. 
% 
% To begin, pick a day. How about St. Patrick's Day, March 17. Estimating 
% how much energy hit the Earth's oceans on St. Patrick's Day means we have to 
% make a global grid and calculate the solar radiation at each point in that 
% grid. A very dense grid will be more accurate, but whereas a very coarse grid
% will require less memory. Let's use <cdtgrid_documentation.html |cdtgrid|> 
% to create a half-degree global grid, and calculate the radiation at each 
% point on that grid: 

% Make a half-degree grid: 
[Lat,Lon] = cdtgrid(1/2); 

% Calculate Ra on St. Patrick's Day: 
Ra = solar_radiation('march 17',Lat); 

% Plot
figure
imagescn(Lon,Lat,Ra) 
hold on
earthimage('watercolor','none')
cmocean solar 
cb = colorbar; 
ylabel(cb,'solar radiation MJ m^{-2}')
title 'St. Patricks Day'

%% 
% Above, the land surface was plotted with <earthimage_documentation.html |earthimage|>  
% and the colormap was set with <cmocean_documentation.html |cmocean|>.
% 
% Now you may be wondering, how much energy does the ocean receive compared 
% to land? Answering that question requires us to know the area of each grid cell 
% to compute the total energy received at each grid cell. Use <cdtarea_documentation.html 
% |cdtarea|> to get the area of each grid cell, and multiply |Ra| by area to 
% get the total energy received per grid cell on St. Patrick's Day: 

% Get area of each grid cell: 
A = cdtarea(Lat,Lon);  % (m^2)

% Calculate total energy received per grid cell: 
E = Ra.*A; 

%%
% So which receives more total solar energy--the land or the ocean? 
% use <island_documentation.html |island|> to determine which grid cells correspond, 
% then sum up the solar energy that hits land and ocean: 

% Get a mask of grid cells that are land: 
land = island(Lat,Lon); 

% Total solar energy that hits land on St Patrick's Day: 
sum(E(land)) % MJ

%% 
% That's 4*10^15 MJ of solar energy that hit the land surface on St. Patrick's Day.
% Versus ocean: 

sum(E(~land)) % MJ

%% 
% That's 1*10^16 MJ that hit the ocean. Not surprisingly, the ocean is has a 
% larger surface area than land, so it receives more solar energy. 

%% 
% We can expand this analysis to changes in time by entering |t| as an 
% array of times, like this, where we calculate daily solar radiation 
% for every day in the year 2019: 

t = datetime('jan 1, 2019'):datetime('dec 31, 2019'); 

Ra = solar_radiation(t,Lat); 

%% 
% Above, we entered 1x365 datetime array |t| and a 360x720 grid of latitudes
% |Lat|. The resulting |Ra| is then 360x720x365, which corresponds to a gridded
% solution for each day of the year. 
% 
% Multiply |Ra| by grid cell area |A| to get the gridded time series of energy 
% received at each grid cell, and use the <local_documentation.html |local|> 
% function to get time series of energy incident on land versus ocean: 

% Daily energy is Ra times grid cell area: 
E = Ra.*A; 

% Sums of land and ocean energy: 
E_land = local(E,land,@sum); 
E_ocean = local(E,~land,@sum); 

figure
plot(t,E_land)
hold on
plot(t,E_ocean) 
plot(t,E_land+E_ocean,'k','linewidth',2)
axis tight
box off
legend('land','ocean','total')
ylabel 'Earth''s daily energy received (MJ)' 

%% 
% The plot above shows that at all times of the year, the ocean receives more 
% solar energy than the land surface. That is unsurprising, because the ocean's surface
% is larger than Earth's land surface. But there are some other interesting 
% things that are happening there too. 
% 
% The curve for land may not surprise the majority of Earth's population, who
% live north of the equator. If you live in the northern hemisphere you may 
% see that and think, "yes, the Earth is warmer in the summer." But of course 
% when it's summer in the nothern hemisphere, it's winter in the southern 
% hemisphere, so shouldn't things equal out? 
% 
% No. Because most's of Earth's land area is in the northern hemisphere, so 
% in terms of sums, the Earth's land surface receives more energy in June
% than in December. 
% 
% When we look at how solar energy at the ocean's surface changes throughout the
% year, we see just the opposite of what we see on land. That's partly because
% the ocean has more surface area in the southern hemisphere than the northern
% hemisphere, but that doesn't fully explain the dip in the ocean's energy in June 
% and July. 
% 
% Looking at the total solar energy received, we see that it's not constant 
% throughout the year. In fact, the Earth is farthest away from the Sun
% around <https://simple.wikipedia.org/wiki/Perihelion July 4th> of every 
% year, so on the whole, that's when the Earth receives the least amount of 
% solar energy. 

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