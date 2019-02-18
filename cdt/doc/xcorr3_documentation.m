%% |xcorr3| documentation 
% The |xcorr3| function gives a map of correlation coefficients between grid cells of a 3D spatiotemporal dataset 
% and a reference time series. 
% 
% See also: <corr3_documentation.html |corr3|> and <xcov3_documentation.html |xcov|>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  r = xcorr3(A,ref)
%  r = xcorr3(...,'detrend')
%  r = xcorr3(...,'maxlag',maxlag)
%  r = xcorr3(...,'mask',mask)
%  [r,rmax,lags] = xcorr3(...)
% 
%% Description
% 
% |r = xcorr3(A,ref)| gives a 2D correlation map |r|, which has dimensions corresponding to dimensions 1 and 2 of |A|. The 3D matrix
% |A| is assumed to have spatial dimensions 1 and 3 which may correspond to x and y, lat and lon, lon and lat, etc. The third
% dimension of |A| is assumed to correspond to time.  The array |ref| is a time series reference signal against which you're comparing
% each grid cell of |A|. Length of |ref| must match the third dimension of |A|. 
% 
% |r = xcorr3(...,'detrend')| removes the mean and linear trend from each time series before calculating correlation. This is 
% recommended for any type of analysis where data values in |A| or the range of values in |ref| are not centered on zero. 
% 
% |r = xcorr3(...,'maxlag',maxlag)| specifies maximum lag as an integer scalar number of time steps. If you specify |maxlag|, the 
% returned cross-correlation sequence ranges from |-maxlag| to |maxlag|. Default |maxlag| is N-1 time steps.
%
% |r = xcorr3(...,'mask',mask)| only performs analysis on true grid cells in the mask whose dimensions correspond to the first 
% two (spatial) dimensions of A. The option to apply a mask is intended to minimize processing time if |A| is large.  By default, 
% *any* |NaN| value in |A| sets the corresponding grid cell in the default mask to |false|. 
% 
% |[r,rmax,lags] = xcorr3(...)| returns the zero-phase correlation coefficient |r|, the maximum correlation coefficient |rmax|, and
% time lags corresponding to maximum correlation.  A negative |lag| value implies the local time series happens _after_ the reference 
% signal.  A positive |lag| indicates the local phenomena leads the reference signal. 
% 
%% Example 1: Comparison of four artificial signals
% Consider this simple 2x2 grid with 10,000 time steps.  You want to see if which grid cells vary in time with 
% some reference signal |y|: 

% A time vector: 
t = 1:10000; 

% And some reference signal:
y = sind(t); 

% Build A: 
A = nan(2,2,10000); 
A(1,1,:) = 2*y;            % 2x ref signal
A(1,2,:) = sind(t-43);     % ref with lag of 43 time steps
A(2,1,:) = randn(size(t)); % gaussian noise
A(2,2,:) = -y;             % perfectly out of phase 

%% 
% It's not easy to visualize what those four grid cells of |A| are doing, so hopefully 
% this helps: This is a spatial way of looking at what's in |A|: 
% 
%  A = [ 2x ref signal       ref with lag of -43 time steps;
%       gaussian noise            perfectly out of phase   ]
% 
% Now we can see how each grid cell of |A| varies with (or without) |y|: 
 
[r0,rmax,lags] = xcorr3(A,y); 

%% 
% The zero-phase correlation looks like this: 

r0

%% 
% That tells us exactly what we already knew.  The top left grid cell of |A| has 
% values that are two times |y|, so its correlation with |y| is a perfect
% |1.0000|. Similarly, the lower right grid cell of |A| has a time series we defined
% as |-y|, so its correlation with |y| is |-1.0000|.  The lower left of |A| contains
% only noise, so it is not very well correlated with |y| at all.  The tricky one is
% the upper right grid cell of |A|, which has the same signal as |y|, but offset in
% time by 43 time steps.  Here's a snippet of what |y| and |sind(t-43)| look like: 

plot(t(1:400),y(1:400),'b') 
hold on
plot(t(1:400),sind(t(1:400)-43),'r') 
xlabel('time') 
legend('reference signal y','y with 43 time-step lag')

%% 
% In the plot above, it's clear that |y| and the time-lagged version of |y| are often
% going up or down together, but sometimes the time lag means they're not perfectly
% correlated, thus, the correlation coefficient of |0.73| if we don't take the temporal
% offset into account.  However, you can also see that if you shift one of the signals
% by 43 time steps, the two signals would be perfectly correlated.  And in fact, that's
% clear if we look at the maximum correlation coefficients: 

rmax

%% 
% We see that if we shift the |A| values around in time, the upper right grid cell of |A| 
% matches the reference time series with a correlation coefficient of 1 (or close to 1), 
% meaning a perfect match.  The signals line up best with these lags: 

lags

%% 
% And again, this tells us exactly what we already knew.  The upper left grid cell of |A| 
% matches the reference time series perfectly with zero lag; we intentionally applied a 43
% time step lag to the upper right grid cell of |A|; the lower left grid cell is never 
% well-correlated with the reference signal so its lag value is meaningless, and the lower
% right grid cell of |A| matches the reference signal with a 180 time-step offset (because 
% in this example, offsets conveniently correspond to degrees). 

%% Example 2: Sea Surface Temperatures 
% The example above is intended to give a sense of the theory behind how |xcorr3| works, 
% but it doesn't capture the insights of spatiotemporal patterns you can get by applying 
% |xcorr3| to real data.  So let's take a look at a sample reanalysis dataset of sea surface
% temperatures: 

load pacific_sst
whos lat lon t

%% 
% The sample dataset contains an |sst| matrix which has the following resolutions: 

mean(diff(lat))
mean(diff(lon))
mean(diff(t))

%% 
% That is, |sst| is a 2x2 degree grid with monthly temporal resolution.  
% 
% I have a hypothesis that sea surface temperatures vary sinusoidally with the seasons.  
% To compare sea surface temperatures with a sinusoid, first create a reference
% sinusoid that corresponds to months of the year:

[~,month,~] = datevec(t); 
ref = sin((month+1)*pi/6); 

plot(t,ref)
xlim([datenum('jan 1, 1990') datenum('jan 1, 1995')]) 
box off
datetick('x','keeplimits')
title ' reference time series '

%% 
% The reference signal has a maximum value in February of each year. My hypothesis is that
% sea surface temperatures in the southern hemisphere should be positively correlated with the 
% reference signal, meaning sea surface temperatures in the southern hemisphere should reach their
% maximum in February and minimum in August.  The northern hemisphere should exhibit the
% exact opposite pattern, with maxima each August and minima each February. 
% 
% Let's take a look at the correlation between the raw sea surface temperature data and our 
% reference sinusoid.  (Below I'm using <imagescn_documentation.html |imagescn|> 
% to create an |imagesc| plot where NaN values are transparent, but you can use |imagesc| or 
% |pcolor| if you prefer.  I'm also using a <cmocean_documentation.html 
% |cmocean|> colormap (Thyng et al., 2016), which is divergent and perceptually uniform.) 
 
r0 = xcorr3(sst,ref); 

figure
imagescn(lon,lat,r0)
axis xy image
cb = colorbar; 
ylabel(cb,'zero-phase correlation') 
caxis([-1 1]) 
cmocean balance

%% 
% In the map above, we see that sea surface temperatures seem only _slightly_ correlated with
% the reference sinusoid. But we've made an oversight!  We forgot to remove the mean from the 
% |sst| dataset, so of course correlation with the sinusoid is weak.  Here's a map of mean sea
% surface temperature, which contaminated the analysis above: 

figure
imagescn(lon,lat,mean(sst,3))
axis xy image
cb = colorbar; 
ylabel(cb,'mean temperature') 
cmocean thermal

%% 
% Before using |xcorr3| you can remove the mean manually if you'd like, or you can simply use 
% the |'detrend'| option, which will remove the mean for you.  The |'detrend'| option also 
% removes the long-term (global warming) trend, which is convenient because when the mean and
% long-term trend are removed, all that's left is the seasonal cycle and inter-annual variability. 
% 
% So let's see how sea surface temperature _anomalies_ (rather than absolute values) compare to our
% reference sinusoid: 

[r0,rmax,lags] = xcorr3(sst,ref,'detrend'); 

figure
imagescn(lon,lat,r0)
axis xy image
cb = colorbar; 
ylabel(cb,'zero-phase correlation') 
caxis([-1 1]) 
cmocean balance

%%
% Wow! Now that's some clear evidence that sea surface temperatures appear to vary seasonally. And
% as expected, positive correlation with the reference sinusoid is apparent in the southern hemisphere, 
% meaning the southern hemisphere sea surface temperatures reach their maximum around Februrary and minimum
% around August.  The northern hemisphere is almost perfectly anti-correlated with the southern hemisphere.
% Near the equator there is very little correlation with the reference sinusoid.  But perhaps the phase we
% chose for the reference signal does not perfectly match the data.  If we move the reference signal around 
% through time, what's the best match each grid cell can attain with the reference sinusoid?

figure
imagescn(lon,lat,rmax)
axis xy image
cb = colorbar; 
ylabel(cb,'maximum correlation') 
caxis([-1 1]) 
cmocean balance

%% 
% The map above shows us that nearly the whole Pacific Ocean has some sinusoidal variability. We can find
% the phase of the best-matching sinusoid by looking at the lags: 

figure
imagescn(lon,lat,lags)
axis xy image
cb = colorbar; 
ylabel(cb,'lags (months)') 

%% 
% The map above appears to be junk.  That grid cell near (180W,4S) needs about 391 months (32 years) 
% of offset to get the best match with a sinusoid?  Take another look at the maximum correlation 
% map, and you'll see that (180W,4S) is never well correlated with a sinusoid--its sea surface temperatures
% do not appear to have a seasonal cycle.  And given that a negative offset of 6 months is mathematically the 
% same as a positive 6 month offset with our reference signal, we should actually limit the maximum lags
% to 6 time steps, which will keep the lags within +/- 6 months: 

[r0,rmax,lags] = xcorr3(sst,ref,'maxlags',6,'detrend'); 

figure
imagescn(lon,lat,lags)
axis xy image
cb = colorbar; 
ylabel(cb,'lags (months)') 

caxis([-6 6])
cmocean phase

%% 
% The map above shows us that temperature maxima off the coast of Alaska appear to occur at about a six month 
% offset from temperature maxima off the coast of Chile. 
% 
% The map above uses the |cmocean| _phase_ colormap because a negative 6 month lag is the same as a positive 
% six month lag in this case, thus we needed a colormap that is the same at the top and bottom. 
% 
% Just for kicks, let's overlay the maximum correlation |rmax| as contour lines and how about some national 
% <borders_documentation.html |borders|> for context: 

hold on
[C,h] = contour(lon,lat,rmax,'color',0.2*[1 1 1]); 
clabel(C,h,'color',rgb('dark gray'),'fontsize',8,'labelspacing',300); 

borders('countries','facecolor',rgb('tan'))

%% Author Info
% The |xcorr3| function and supporting documentation were written by <http://www.chadagreene.com Chad A. Greene> of the University of Texas
% Institute for Geophysics (UTIG), February 2017. 
