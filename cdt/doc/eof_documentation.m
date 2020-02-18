%% |eof| documentation
% The |eof| function gives eigenmode maps of variability and corresponding principal component
% time series for spatiotemporal data analysis. This function is designed specifically for 3D matricies
% of data such as sea surface temperatures where dimensions 1 and 2 are spatial dimensions 
% (e.g., lat and lon; lon and lat; x and y, etc.), and the third dimension represents different 
% slices or snapshots of data in time.  
% 
% See also: <reof_documentation.html |reof|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  eof_maps = eof(A) 
%  eof_maps = eof(A,n) 
%  eof_maps = eof(...,'mask',mask) 
%  [eof_maps,pc,expvar] = eof(...)
% 
%% Description 
% 
% |eof_maps = eof(A)| calculates all modes of variability in |A|, where |A| is a 3D matrix whose
% first two dimensions are spatial, the third dimension is temporal, and data are assumed to be 
% equally spaced in time. Output |eof_maps| have the same dimensions as |A|, where each map along 
% the third dimension represents a mode of variability order of importance. 
% 
% |eof_maps = eof(A,n)| only calculates the first |n| modes of variability. For large datasets, 
% it's computationally faster to only calculate the number of modes you'll need. If |n| is not
% specified, all EOFs are calculated (one for each time slice). 
% 
% |eof_maps = eof(...,'mask',mask)| only performs EOF analysis on the grid cells represented by 
% ones in a logical |mask| whose dimensions correspond to dimensions 1 and 2 of |A|. This option
% is provided to prevent solving for things that don't need to be solved, or to let you do analysis
% on one region separately from another. By default, any grid cells in |A| which contain _any_ NaNs 
% are masked out.  
% 
% |[eof_maps,pc,expvar] = eof(...)| returns the principal component time series |pc| whose rows
% each represent a different mode from 1 to |n| and columns correspond to time steps. For example, 
% |pc(1,:)| is the time series of the first (dominant) mode of varibility.  The third output |expvar| 
% is the percent of variance explained by each mode. See the note below on interpreting |expvar|. 
% 
%% A simple example
% Here's a quick example of how to use the |eof| function. Proper EOF analysis requires detrending
% and deseasoning the data before calculating EOFs, and those steps are described in the tutorial 
% below, but for now let's just pretend this sample dataset is ready to be analyzed.  Load
% the sample data, then calculate the first EOF.  
% 
% Here I'm plotting the first EOF map using the <cmocean_documentation.html |cmocean|> _delta_ colormap 
% (Thyng et al., 2016) with the |'pivot'| argument to ensure it's centered about zero. 

% Load sample data: 
load pacific_sst.mat

% Calculate the first EOF of sea surface temperatures and its 
% principal component time series: 
[eofmap,pc] = eof(sst,1); 

% Plot the first EOF map: 
imagescn(lon,lat,eofmap); 
axis xy image off

% Optional: Use a cmocean colormap:
cmocean('delta','pivot',0)

%% 
% That's the first EOF of the SST dataset, but since we haven't removed the seasonal cycle, 
% the first EOF primarily represents seasonal variability.  As evidence that the pattern
% above is associated with the seasonal cycle, take a look at the corresponding principal component 
% time series.
 
figure
anomaly(t,pc) 
axis tight
xlim([datenum('jan 1, 1990') datenum('jan 1, 1995')])
datetick('x','keeplimits')

%% 
% That looks pretty seasonal to me. 

%% TUTORIAL: From raw climate reanalysis data to ENSO, PDO, etc.
% CDT comes with a sample dataset called |pacific_sst.mat|, which is a downsampled subset 
% of the Hadley Centre's HadISST sea surface temperature dataset.  At the end of this tutorial there's 
% a section which describes how I imported the raw NetCDF data into Matlab and the process I used 
% to subset it.  If you follow along with this tutorial from top to bottom you should be able to 
% apply EOF analysis to any similar dataset.  
% 
% If you haven't already loaded the sample dataset, load it now and get an idea of its contents
% by checking the names and sizes of the variables: 

load pacific_sst.mat
whos

%% 
% So we have a 3D |sst| matrix whose dimensions correspond to lat x lon x time.  What time range, 
% and what are the time steps, you ask?  Let's take a look at the first and last date, and the
% average time step: 

datestr(t([1 end]))
mean(diff(t))

%% Average sea surface temperature
% Okay, so this is monthly data, centered on about the 15th of each month, from 1950 to 2016. To get
% a sense of what the dataset looks like, display the mean temperature over that time.  I'm using
% <imagescn_documentation.html |imagescn|>, which automatically makes NaN values transparent, but
% you can use |imagesc|, |pcolor|, or any equivalent mapping toolbox functions if you prefer. I'm
% also using the <cmocean_documentation.html |cmocean|> _thermal_ colormap (Thyng et al., 2016): 

figure
imagescn(lon,lat,mean(sst,3)); 
axis xy off
cb = colorbar; 
ylabel(cb,' mean temperature {\circ}C ') 
cmocean thermal

%% Global warming
% Is global warming real?  The <trend_documentation.html |trend|> function
% lets us easily get the linear trend of temperature from 1950 to 2016. Be sure to multiply the trend by 10*365.25
% to convert from degrees per day to degrees per decade: 

imagescn(lon,lat,10*365.25*trend(sst,t,3))
axis xy off
cb = colorbar; 
ylabel(cb,' temperature trend {\circ}C per decade ') 
cmocean('balance','pivot') 

%% Remove the global warming signal
% The global warming trend is interesting, but EOF analysis is all about variablity, not long-term trends, so
% we must remove the trend by <detrend3_documentation |detrend3|>: 

sst = detrend3(sst,t); 

%% Remove seasonal cycles 
% If you plot the temperature trend again, you'll see that it's all been reduced to zero, with perhaps a few eps 
% of numerical noise. Now that's an SST dataset that even Anthony Watts would approve of.  
% 
% We have now detrended the SST dataset (which also removed the mean), but it still contains quite a bit of seasonal 
% variability that should be removed before EOF analysis because we're not interested in seasonal signals. 

sst = deseason(sst,t); 

%% 
% So now our |sst| dataset has been detrended, the mean removed, and the seasonal cycle removed. 
% All that's left in |sst| are the anomalies--things that change, but are not long-term trends
% or short-term annual cycles.  Here's the remaining variance of our |sst| anomaly dataset: 

figure
imagescn(lon,lat,var(sst,[],3)); 
axis xy off
colorbar
title('variance of temperature') 
colormap(jet) % jet is inexcusable except when recreating old plots
caxis([0 1])

%% 
% The map above lines up quite well with Figure 2a of <http://dx.doi.org/10.1175/2011JCLI3941.1 Messie and Chavez (2011)>, 
% which tells us we're on the right track. 

%% Calculate EOFs
% EOF analysis lets us understand not only where things vary, but how often, and what regions tend to vary together
% or out of phase with each other.  With our detrended, deseasoned |sst| dataset, EOF analysis is
% this simple with the |eof| function: 

[eof_maps,pc,expv] = eof(sst);

% Plot the first mode: 
figure
imagesc(lon,lat,eof_maps(:,:,1))
axis xy image
cmocean('curl','pivot')
title 'The first EOF mode!'

%% 
% Eigenvector analysis has a funny behavior that can produce EOF maps which are positive 
% or negative, and the solutions can come up different every time using the same exact inputs. 
% Positive and negative solutions are equally valid -- think of the modes of vibration of a 
% drum head where some regions of the drum head go up while other regions go down, and then 
% they switch -- and likewise the eigenvalue solutions of SST variability might be positive
% or negative.  The only thing that matters is that when we reconstruct a time series from 
% an EOF solution, we multiply each EOF map by its corresponding principal component (|pc|). 
% 
% The |eof| function is written to produce consistent results each time you run it with 
% the same data, but don't worry if the sign of a solution does not match the sign of someone 
% else's results if they used a different program to calculate EOFs--that just means their program
% picked the opposite-sign solution, and that's perfectly fine.  
% 
% Just as EOF maps can have positive or negative solutions and both are equally valid, there's
% some flexibility in how the magnitudes of EOF maps are displayed. You can multiply the magnitude
% of an EOF map by any value you want, just as long as you divide the corresponding principal component
% time series by the same value.  Let's take a look at the time series of the first three modes
% of variability, plotting with <subsubplot_documentation.html |subsubplot|>:

figure
subsubplot(3,1,1)
plot(t,pc(1,:))
box off 
axis tight
ylabel 'pc1'
title 'The first three principal components'

subsubplot(3,1,2)
plot(t,pc(2,:))
box off 
axis tight
set(gca,'yaxislocation','right')
ylabel 'pc2'

subsubplot(3,1,3)
plot(t,pc(3,:))
box off 
axis tight
ylabel 'pc3'
datetick('x','keeplimits')

%% Optional scaling of Principal Components and EOF maps
% Those principal component time series are fine just the way they are, but some folks prefer
% to scale each time series to span a desired range. Looking at Figure 5 of <http://dx.doi.org/10.1175/2011JCLI3941.1 Messie and Chavez (2011)>, 
% it seems they chose to scale each principal component time series such that it spans the
% range -1 to 1.  Let's do the same thing, divide each principal component time series by its
% maximum value and don't forget to multiply the corresponding EOF map by the same value: 

for k = 1:size(pc,1) 
   
   % Find the the maximum value in the time series of each principal component: 
   maxval = max(abs(pc(k,:))); 
   
   % Divide the time series by its maximum value: 
   pc(k,:) = pc(k,:)/maxval; 
   
   % Multiply the corresponding EOF map: 
   eof_maps(:,:,k) = eof_maps(:,:,k)*maxval; 
end

%% El Niño Southern Oscillation (ENSO) time series
% The first mode of detrended, deseasoned SSTs is assoiciated with ENSO. We can plot the 
% time series again as a simple line plot, but anomaly plots are often filled in. Let's use 
% <anomaly_documentation.html |anomaly|> to plot the first mode, and multiply by -1 to match 
% the sign of Figure 5 of <http://dx.doi.org/10.1175/2011JCLI3941.1 Messie and Chavez (2011)>. 

figure('pos',[100 100 600 250]) 
anomaly(t,-pc(1,:),'topcolor',rgb('bubblegum'),...
   'bottomcolor',rgb('periwinkle blue')) % First principal component is enso
box off
axis tight
datetick('x','keeplimits') 
text([724316 729713 736290],[.95 .99 .81],'El Nino','horiz','center')

%%
% Sure enough, some of the <https://en.wikipedia.org/wiki/El_Ni%C3%B1o strongest El Nino events on record>
% took place in 1982-1983, 1997-1998, and 2014-2016. For more ways to investigate ENSO, 
% check out the <enso_documentation.html |enso|> function. 

%% ENSO in the frequency domain
% Sometimes we hear that El Nino has a characteristic frequency of once every five years, or five to seven years, 
% or sometimes you hear it's every two to seven years.  It's hard to see that in the time series, so we plot the first principal component in 
% the frequency domain with <plotpsd_documentation.html |plotpsd|>, 
% specifying a sampling frequency of 12 samples per year, plotted on a log x axis, with x values in 
% units of lambda (years) rather than frequency: 

figure
plotpsd(pc(1,:),12,'logx','lambda')
xlabel 'periodicity (years)'
set(gca,'xtick',[1:7 33])

%% 
% As you can see, the ENSO signal does not have a sharply defined resonance frequency, 
% but there's energy in that whole two-to-seven year range. I also labeled the 33 year
% periodicity because that's Nyquist for this particular dataset--any energy with a longer
% period than Nyquist (or anywhere near it) should probably be considered junk. 

%% Maps of variability
% EOFs aren't just about time series--they're about spatial patterns of variability through time. Each mode
% has a characteristic pattern of variability just like the different modes of vibration of a drum head. At 
% any given time, the different modes can be summed to create a total picture of temperature anomalies at 
% that time. The _orthogonal_ part of Empirical Orthogonal Function means each of the modes tend to do their
% own thing, independent of the other modes.  Let's look at the first six modes by recreating Figure 4 of 
% <http://dx.doi.org/10.1175/2011JCLI3941.1 Messie and Chavez (2011)> .  I'm multiplying some of the modes
% by negative one because I want to match their signs, and remember, we're allowed to do that. 

s = [-1 1 -1 1 -1 1]; % (sign multiplier to match Messie and Chavez 2011)

figure('pos',[100 100 500 700])
for k = 1:6
   subplot(3,2,k) 
   imagescn(lon,lat,eof_maps(:,:,k)*s(k)); 
   axis xy off
   title(['Mode ',num2str(k),' (',num2str(expv(k),'%0.1f'),'%)'])
   caxis([-2 2]) 
end

colormap jet 

%% 
% The percent variance explained by each mode does not match Messie and Chavez because we're using a much shorter
% time series than they did and we're also using a spatial subset of the world data.  Nonetheless, 
% patterns generally agree.  
% 
% The |jet| colormap is not exactly the same one used by Messie and Chavez, which explains why some of the patterns
% above may look slightly different from Messie and Chavez. But since we're talking about colormaps, rainbows are 
% actually quite bad at representing numerical data (<https://doi.org/10.5670/oceanog.2016.66 Thyng et al, 2016>). 
% It's also a shame for science that we can't exactly replicate the plot without knowing exactly what colors were used
% in the published version, but I digress... 
% 
% Given that these maps represent anomalies, they should be represented by a divergent colormap that gives equal 
% weight to each side of zero. Let's set the colormaps of all the subplots in this figure to something a little
% more balanced: 

colormap(gcf,cmocean('balance'))

%% Make a movie of SST variability from EOFs
% At any given time, a snapshot of sea surface temperature anomalies associated with 
% ENSO can be obtained by plotting the map of mode 1 shown above, multiplied by its
% corresponding principal component (the vector |pc(1,:)|) at that time.  Similarly, 
% you can get a picture of worldwide sea surface temperature anomalies at a given time
% by summing all the EOF maps, each multiplied by their corresponding principal component
% at that time.  In this way we can build a more-and-more complete movie of SST anomalies
% as we include more and more more modes of variability. 
% 
% For example, a map of SST anomalies associated with the first three modes of variability, 
% for a specified time, can be obtained by summing the eof maps of each of those 
% modes, multiplied by their corresponding pc values for that time. You can do
% the summing manually, say, for the 1990's like this: 
% 
%  % Indices of start and end dates for the movie: 
%  startind = find(t>=datenum('jan 1, 1990'),1,'first'); 
%  endind = find(t<=datenum('dec 31, 1999'),1,'last'); 
%  
%  % A map of SST anomalies from first three modes at start:
%  map = eof_maps(:,:,1)*pc(1,startind) + ... % Mode 1, Jan 1990
%        eof_maps(:,:,2)*pc(2,startind) + ... % Mode 2, Jan 1990
%        eof_maps(:,:,3)*pc(3,startind);      % Mode 3, Jan 1990
%  
%% 
% However, that's more complicated than necessary, because the <reof_documentation.html 
% |reof|> function is designed to do the summing for us. Make an sst anomaly 
% time series for the first three modes like this: 

sst_f = reof(eof_maps,pc,1:3); 

%% 
% Now plot the January 1990 map as the first frame in a movie: 
% 
%  ind_1990s = 481:3:600; % (every third value to cut down on gif size)
%  
%  figure
%  h = imagescn(sst_f(:,:,ind_1990s(1))); 
%  caxis([-2 2]) 
%  cmocean balance
%  cb = colorbar; 
%  ylabel(cb,'temperature anomaly (modes 1-3)')
%  title(datestr(t(ind_1990s(1)),'yyyy')) 
%  
%  
%  gif('SSTs_1990s.gif','frame',gcf) % writes the first frame
%  
%  for k = 2:length(ind_1990s)
%     h.CData = sst_f(:,:,ind_1990s(k)); 
%     title(datestr(t(ind_1990s(k)),'yyyy')) 
%     gif % adds this frame to the gif 
%  end
%  
% <<SSTs_1990s.gif>>
% 
%% 
% The first thing you probably notice is that the 1990s SST anomaly time series is dominated by ENSO, 
% and check out that 1997-1998 signal!  No wonder it was such a hot topic in the <https://www.nbc.com/saturday-night-live/video/el-nino/2861308
% news> that year. Nonetheless, it's important to remember that the movie above is not a complete reconstruction of 
% the SST anomalies, but rather only the first three modes, which together account for 

sum(expv(1:3))

%% 
% ...just over half of the total variance of the SST dataset. To reconstruct the absolute temperature field rather than 
% just anomalies from the first three modes, you'd need to include all the EOF maps, and you'd also 
% have to add back in the mean SST map, the trend, and the seasonal cycle.  

%% How I got the sample data
% The example dataset shown above comes from the Hadley Center HadISST, found <http://www.metoffice.gov.uk/hadobs/hadisst/data/download.html here>
% (Rayner et al., 2003) which in full exceeds 200 MB.  If you'd like to perform the the same kind of analysis on a different region of the world,
% you can download the HadISST_sst.nc dataset and import it into Matlab like this.  Downsampling or subsetting the dataset are up to you: 
%  
%  % Load the full SST dataset: 
%  lat = double(ncread('HadISST_sst.nc','latitude')); 
%  lon = double(ncread('HadISST_sst.nc','longitude')); 
%  t = double(ncread('HadISST_sst.nc','time')+datenum(1870,1,0)); 
%  sst = ncread('HadISST_sst.nc','sst'); 
%  
%  % To quarter the size of the sample dataset, I crudely downsample to every other grid point: 
%  sst = sst(1:2:end,1:2:end,:); 
%  lat = lat(1:2:end); 
%  lon = lon(1:2:end); 
%  
%  % To further reduce size, I clipped to a range of lats and lons and kept only post-1950 data: 
%  rows = lon<-70; 
%  lon = lon(rows); 
%  cols = lat>=-60 & lat<=60; 
%  lat = lat(cols); 
%  times = t>=datenum('jan 1, 1950'); 
%  t = t(times); 
%  sst = sst(rows,cols,times); 
%  sst(sst<-50) = NaN; 
%  
%  % I find it easier to rearrange as lat x lon x time:
%  sst = permute(sst,[2 1 3]); 
%  
%  % Save the sample data:
%  save('PacOcean.mat','lat','lon','t','sst') 
% 
%% References 
% 
% Messié, Monique, and Francisco Chavez. "Global modes of sea surface temperature variability in relation to regional 
% climate indices." Journal of Climate 24.16 (2011): 4314-4331. <http://dx.doi.org/10.1175/2011JCLI3941.1 doi:10.1175/2011JCLI3941.1>.
%
% Rayner, N. A., Parker, D. E., Horton, E. B., Folland, C. K., Alexander, L. V., Rowell, D. P., Kent, E. C., Kaplan, A.  
% (2003). Global analyses of sea surface temperature, sea ice, and night marine air temperature since the late nineteenth century. 
% J. Geophys. Res.Vol. 108, No. D14, 4407 <http://dx.doi.org/10.1029/2002JD002670 doi:10.1029/2002JD002670>.
% 
% Thyng, K.M., C.A. Greene, R.D. Hetland, H.M. Zimmerle, and S.F. DiMarco. 2016. True colors of oceanography: Guidelines for
% effective and accurate colormap selection. Oceanography 29(3):9-13, <http://dx.doi.org/10.5670/oceanog.2016.66 doi:10.5670/oceanog.2016.66>.
% 
%% Author Info 
% The |eof| function was written by <http://www.chadagreene.com Chad A. Greene> of the University of Texas 
% Institute for Geophysics (UTIG) in January 2017, but leans heavily on Guillame MAZE's |caleof| function
% from his <https://www.mathworks.com/matlabcentral/fileexchange/17915 PCATool> contribution. This tutorial
% was written by Chad Greene with help from <https://www.kaustubh.info/ Kaustubh Thirumalai>. 