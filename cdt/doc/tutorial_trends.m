%% Linear trends
% <CDT_Contents.html Back to Climate Data Tools Contents>
% 
% <https://en.wikipedia.org/wiki/Least_squares Least-squares linear regression> is one of the most common types of 
% analysis in the Earth sciences, and Matlab's <https://en.wikipedia.org/wiki/Division_(mathematics)#Left_and_right_division 
% left-divide operator> which enables efficient least-squares computation is a big reason Matlab originally gained 
% popularity among geoscientists. The mathematics of least squares and
% matrix multiplication is well covered online and in many textbooks, so
% this tutorial just covers the mechanics of how to calculate least squares
% regressions using the Climate Data Toolbox for Matlab. 

%% The |trend| function 
% For this example we'll make some random data with a known trend, and then
% we'll use the <trend_documentation.html |trend|> function to fit a linear
% least-squares regression to the data. First, generate the data: 

x = 1:1000; 
y = 5*x + 500*randn(size(x)) + 300; 

%% 
% Above, we imposed a trend of y = 5*x, then added some noise and a
% y-intercept of 300. Here's the data: 

plot(x,y,'o')

%% 
% Use <polyplot_documentation.html |polyplot|> to quickly plot the first-order least-squares trend: 

hold on
polyplot(x,y,1,'linewidth',2) 

%% 
% Most often in the geosciences, the question is, what's the slope of that
% line? How does y vary with x? We know that the slope should be about
% y=5*x, but what does least squares say? Use the <trend_documentation.html
% |trend|> function to find out: 

trend(y,x) 

%% 
% About 5. That's exactly the answer we expected. 

%% The |polyfit| and |polyval| functions
% The |trend| function is convenient due to its simplicity, but you may
% wish for more information than just the slope of the trend line. For
% example, you might want to know the y-intercept or some higher-order
% least-squares fit. For such occasions, the standard Matlab function
% |polyfit| may come in handy. 
% 
% The |polyfit| function fits any order polynomial to a dataset by least
% squares. Fitting a first-order polynomial to the x,y data with |polyfit|
% looks like this: 

P = polyfit(x,y,1)

%% 
% Above, |P| contains the coefficients of the polynomials, starting with
% the highest order. Since this is a first-order least squares fit, the
% contents of |P| are |[P_1 P_0]|, or the slope and the intercept,
% respectively. So it is not surprising that the slope |P_1| is about 5 and
% the intercept |P_0| is about 300. Those are the values we imposed when we
% created |y|. If we wanted to get the coefficients of a second-order fit, we'd use

P = polyfit(x,y,2) 

%% 
% However, fitting a second order or higher to this particular dataset
% would not be appropriate, and we know it, because when we defined |y| we
% said that it has a slope, a y-intercept, and noise, and nothing else.
% That means to fit even a second-order polynomial |y| would be fitting the
% model to noise. That's sometimes called over-fitting. 
% 
% To illustrate overfitting, let's fit a 25th-order polynomial to |y|: 

P = polyfit(x,y,25); 

%% 
% Now use the |polyval| function to evaluate the 25th-order |P| for every
% |x| and plot it as a thick black line: 

y_overfit = polyval(P,x); 

plot(x,y_overfit,'k','linewidth',2) 

legend('raw data','1^{st} order fit','25^{th} order fit',...
   'location','northwest')

%% Trends in atmospheric C02
% Now let's apply the method above to assess changes in atmospheric C02
% measured at Mauna Loa, Hawaii. Start by loading the data and plotting: 

load mlo_daily_c02.mat

figure
plot(t,C02)
axis tight 
datetick('x','keeplimits') % formats x ticks as dates
ylabel('atmospheric C02 (ppm)')

%% 
% Throughout this time of measurement, at what rate has atmospheric C02
% increased? Find out using the <trend_documentation.html |trend|>
% function: 

trend(C02,t)

%% 
% |NaN| means not-a-number. That's because the C02 dataset contains some |NaN| values.
% This is common in real datasets, which sometimes have gaps or missing
% data, but there's an easy way to deal with it. Just determine which
% elements of the |C02| datasets are finite, and only analyze those. 

% Determine which C02 indices are not NaN: 
isf = isfinite(C02); 

% Calculate the trend among finite values: 
trend(C02(isf),t(isf))

%% 
% A trend of about zero does not seem like much of a trend at all. But
% note, the |trend| function calculated the changes in C02 per unit of
% time, and the time units are datenum, which are days. (Read more about
% date formats in <tutorial_dates_and_times.html this tutorial>.) So it is
% not surprising that the trend in C02 (ppm) per day is close to zero. A
% more meaningful measure might be the trend per decade. 
% 
% To convert the C02 trend from ppm/day to ppm/decade, just multiply by
% 365.25 days per year, and then multiply that by 10 years per decade: 

trend(C02(isf),t(isf))*365.25*10

%% 
% The trend in atmospheric C02 is about 17 ppm per decade in this dataset. 
% Use <polyplot_documentation.html |polyplot|> to show the trend line on
% the plot: 

hold on
polyplot(t,C02,1) 

%% 
% In the plot above, we see that the first-order fit of about 17 ppm per
% decade matches the overall trend of course, but it doesn't fully capture
% the long-term shape of the curve. Here's where it may be appropriate to
% use a higher-order fit. Let's show a second-order fit: 

polyplot(t,C02,2)
legend('raw data','1^{st} order fit','2^{nd} order fit',...
   'location','northwest') 

%% 
% The corresponding polynomial constants can be found with the |polyfit|
% function: 

P = polyfit(t(isf),C02(isf),2);

%% 
% The warning message occurred because the units of |t| (datenum) are very
% different from the units of C02 (ppm). You see, the values of t are very
% large compared to the values of C02. To illustrate this point, look at
% the first element of |t|: 

t(1) 

%% 
% That's a very big number. It's the number of days since New Years Day of the 
% year 0. A quick and easy way to deal with this big number is to convert
% it to decimal year using the <doy_documentation.html |doy|> function: 

yr = doy(t,'decimalyear'); 

%% 
% Now the first date looks like this: 

yr(1)

%% 
% And that number is small enough that we can fit a polynomial to it and
% the C02 data. Divide |yr| by 10 to get polynomials relative to decades
% rather than years: 

P = polyfit(yr(isf)/10,C02(isf),2)

%% 
% The positive value in the first element |P| tells us something we already
% knew: Atmospheric C02 is not just increasing, it is _accelerating._

%% 3D datasets
% The examples above looked at 1D arrays, each representing a single time
% series. In climate science, we often work with thousands of such time
% series all at once, in the form of gridded data. In these kinds of 3D
% grids, the first two dimensions are typically spatial, like longitude and
% latude, and the third dimension corresponds to time. Each grid cell
% contains its own time series, and one way to work with those time series
% is to loop through each grid cell, performing 1D analysis on the time
% series of each grid cell. We'll cover that method a bit farther down in
% this tutorial, but first we will use the <trend_documentation.html
% |trend|> function to calculate the trend of the 3D dataset.
% 
% Begin by loading the data 

load pacific_sst

whos lat lon sst t % displays variable sizes

%% 
% The pacific_sst sample dataset contains 802 monthly sea surface temperatures
% on a 60x55 grid. The grid resolution is quite coarse, and it only covers
% part of the Pacific, but it's worth noting that even this small dataset
% contains 60x55=3300 individual time series. While it may be tempting to
% loop through each grid cell, computing the trend of each grid cell's time 
% series individually, we should think of that method as the last resort,
% because it's a mighty slow way of going about things. So whenever you
% can, try to avoid loops and just operate once. 
% 
% The |trend| function does the whole operation at once. Here's how to use
% it:  

% Calculate the trend per year, for 12 samples per year (monthly data):
tr = trend(sst,12); 

% Plot the linear trend: 
figure
imagescn(lon,lat,tr) 
cb = colorbar; 
ylabel(cb,'SST trend (\circC yr^{-1})') 
cmocean('balance','pivot') % sets the colormap with zero in the middle

%% 
% The |trend| calculation above was fast, because it only had to do the
% calculation once, not 3300 times. (It uses <cube2rect_documentation.html
% |cube2rect|> to reshape the sst dataset, then performs the least squares
% fit, then uses <rect2cube_documentation.html |rect2cube|> to "un-reshape"
% the results.) 
% 
%% Dealing with NaNs in a 3D dataset
% In some instances, you may have no choice but to use loops to calculate
% trends in a 3D gridded dataset. For example, if there are some scattered
% |NaN| values in the data. In such cases, loop through each row and column
% of the 3D dataset, determine which time indices are finite in each grid
% cell, and calculate the trend accordingly. Don't forget to <https://www.mathworks.com/help/matlab/matlab_prog/preallocating-arrays.html
% preallocate> before starting the loops. 

% Preallocate: 
sst_trend = nan(60,55); 

% Loop through each row: 
for row = 1:60
   
   % Loop through each column: 
   for col = 1:55
      
      % Get the time indices of finite data in this grid cell: 
      ind = isfinite(sst(row,col,:)); 
      
      % Only calculate the trend if there are at least two finite indices:
      if sum(ind)>=2
         sst_trend(row,col) = trend(squeeze(sst(row,col,ind)),t(ind))*365.25; 
      end
   end
end
     
%% 
% Note the |squeeze| command above, which converts the 1x1xN arrays into
% Nx1 arrays. 
% 
% Now plot the sst_trend which we just calculated on a per-grid-cell basis,
% just confirm that it matches the results of using |trend| on the whole
% dataset at once: 

figure
imagescn(lon,lat,sst_trend) 
cb = colorbar; 
ylabel(cb,'SST trend (\circC yr^{-1})') 
cmocean('balance','pivot') % sets the colormap with zero in the middle

%% Author Info 
% This tutorial was written by Chad A. Greene for the Climate Data Toolbox 
% for Matlab, February 2019. 