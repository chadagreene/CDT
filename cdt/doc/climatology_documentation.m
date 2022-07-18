%% |climatology| documentation 
% The |climatology| function gives typical values of a variable as it varies 
% throughout the year. The output of this function includes the overall mean 
% (whereas the output of the season function does not.)
% 
% See also:  <season_documentation.html |season|>, <deseason_documentation.html |deseason|>, <sinefit_documentation.html |sinefit|>, 
% <sineval_documentation.html |sineval|>, and <sinefit_bootstrap_documentation.html |sinefit_bootstrap|>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  [Ac,tc] = climatology(A,t) 
%  [Ac,tc] = climatology(...,'daily')  
%  [Ac,tc] = climatology(...,'monthly') 
%  [Ac,tc] = climatology(...,'detrend',DetrendOption) 
%  [Ac,tc] = climatology(...,'dim',dimension) 
%  Ac = climatology(...,'full') 
% 
%% Description 
% 
% |[Ac,tc] = climatology(A,t)| gives the typical values of variable |A| as it changes throughout the year.
% Times times |t| are in datenum or datetime format. If |t| is daily, output |tc| is 1 to 366 and |Ac| will contain average values
% for each of the 366 days of the year. If inputs are monthly, |tc| is |1:12| and |Ac| will contain average values
% for each of the 12 months of the year. 
%
% |[Ac,tc] = climatology(...,'daily')| specifies directly that inputs are daily resolution. The climatology function
% will typically figure this out automatically, but if you have large missing gaps in your data you may wish
% to ensure correct results by specifying daily. 
% 
% |[Ac,tc] = climatology(...,'monthly')| as above, but forces monthly solution. 
%
% |[Ac,tc] = climatology(...,'detrend',DetrendOption) specifies a baseline relative to which seasonal anomalies are 
% determined. Options are |'linear'|, |'quadratic'|, |'mean'|, or |'none'|. By default, anomalies are calculated after 
% removing the linear least squares trend, but if, for example, warming is strongly nonlinear, you may prefer
% the |'quadratic'| option. Default is |'linear'|. 
%
% |[Ac,tc] = climatology(...,'dim',dimension)| specifies a dimension along which to assess seasons. By default, 
% if |A| is 1D, seasonal cycle is returned along the nonsingleton dimension; if |A| is 2D, climatology is performed
% along dimension 1 (time marches down the rows); if |A| is 3D, climatology is performed along dimension 3. 
% 
% |Ac = climatology(...,'full')| returns |Ac| for the entire time series |A|. This is a convenient option for looking
% at the components of a long time series separately. 
%
%% Example 1: Daily sea ice extent
% Here's some sea ice data that is _mostly_ daily. Before 1988 there is only data for every other
% day, but that's fine--the |climatology| function will figure it out. Start by loading and plotting
% the data. Also add a least-squares trend line with <polyplot_documentation.html |polyplot|>.

load seaice_extent

plot(t,extent_N)
box off
ylabel 'sea ice extent (\times10^6 km^2)'

hold on
polyplot(t,extent_N)

%%
% The climatology is then: 

extent_N_clim = climatology(extent_N,t,'full'); 

plot(t,extent_N_clim)

%% 
% In the plot above, you'll notice that the climatology has the same mean
% value as the original sea ice extent time series, but it does not have any trend
% through time. Its only variablity is that with the seasons. 
% 
% Removing the climatology from the original signal produces the same result
% as removing the mean and the seasonal cycle--the only parts left would be the 
% long-term trends, interannual variability, and noise. 

%% Example 2: Gridded data
% For this example, load the pacific_sst example dataset, which contains
% gridded data for 802 months of gridded sea surface temperatures. Use these
% 66.8 years of data to get a sense of how SSTs tend to vary throughout the
% year, like this: 

load pacific_sst

sst_c = climatology(sst,t); 

%% 
% Now, |sst_c| is a 60x55x12 grid of sea surface temperatures. That third 
% dimension indicates sea surface temperatures for each month of the typical
% year. Animate them and make a <gif_documentation.html |gif|> like this, 
% starting by plotting the first frame: 
% 
%  figure
%  h = imagescn(lon,lat,sst_c(:,:,1)); 
%  cb = colorbar; 
%  ylabel(cb,'sea surface temperature (\circC)')
%  cmocean thermal % sets the colormap
%  title(datestr(datenum(0,1,1),'mmmm')) % converts "1" to "January"
%  caxis([2 29])
%  
%  % Add a silly earth image: 
%  hold on
%  he = earthimage; 
%  uistack(he,'bottom') % puts the earth image below SST data
%  
%  % Write the first frame: 
%  gif('pacific_sst_climatology.gif','frame',gcf,'delaytime',1/12,'nodither')
%  
%  % Write frames for all the other months: 
%  for k = 2:12
%     h.CData = sst_c(:,:,k);               % updates monthly values
%     title(datestr(datenum(0,k,1),'mmmm')) % updates title
%     gif                                   % adds this frame to the gif                         
%  end
% 
%% 
% ...and that produces this nice animation: 
% 
% <<pacific_sst_climatology.gif>>
% 
%% Seasons vs Climatology
% CDT has a function called |climatology| and another function called <season_documentation.html |season|>. 
% The only difference is that the output of |climatology| includes the mean of the variable, 
% whereas the output of |season| will always have a 0 mean value. Accordingly, the <deseason_documentation.html |deseason|>
% function removes the seasonal component of variability while preserving the overall mean
% and trends. 
% 
% In general, CDT assumes that a multi-year record of a variable sampled at 
% subannual resolution can described by 
% 
%  y = y_0 + y_tr + y_season + y_var + y_noise
% 
%% 
% where 
% 
% * |y_0| is the long-term |mean|, 
% * |y_trend| is the long-term <trend_documentation.html |trend|>, 
% * |y_season| is the typical seasonal anomaly, which the |season| function obtains after detrending and removing the mean, 
% * |y_var| represents interannual variability, and 
% * |y_noise| is everything else 
% 
% In this model, 
% 
%  y_climatology = y_0 + y_season
% 
%% Other ways to define seasonality 
% For yet another way to define seasonality, see <sinefit_documentation.html |sinefit|>, 
% <sineval_documentation.html |sineval|>, and <sinefit_bootstrap_documentation.html |sinefit_bootstrap|>. 
%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 