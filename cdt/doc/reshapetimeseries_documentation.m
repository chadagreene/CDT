%% |reshapetimeseries| documentation 
%
% The |rehspaetimeseries| function reshapes a vector of timeseries data
% onto a grid, accounting for messiness associated with leap days or
% unevenly-spaced data.
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Syntax
%
%  [xg, yr] = reshapetimeseries(t, x)
%  [xg, yr] = reshapetimeseries(t, x, 'bin', bin)
%  [xg, yr] = reshapetimeseries(t, x, 'func', func)
%  [xg, yr] = reshapetimeseries(t, x, 'yrlim', yrlim)
%  [xg, yr] = reshapetimeseries(t, x, 'pivotdate, [mon day])

%% Description

%% Example
%
% When working with timeseries data, one often wants to analyze or plot
% things by time of year.  For example, let's look at the sea ice extent
% example:

load seaice_extent;

plot(t, extent_N);

%%
% We can use <doy_documentation.html |doy|) to put this data on a
% day-of-year axis rather than datetimes:

cla;
plot(doy(t), extent_N);

%%
% But ugh, that wrapping from one year to the next prevents any quick and
% easy plotting. And we can calculate statistics across years by using
% |splitapply| or |accumarray|: 

[g, tdoy] = findgroups(floor(doy(t)));
iceavg = splitapply(@nanmean, extent_N, g);

%%
% But that syntax gets awfully clunky when you want to do more in-depth
% analysis.  Both of these tasks would be a lot simpler if we could just
% reshape the data into matrix.  The problem, of course, is those pesky
% leap days, always leading to uneven numbers of datapoints in different
% years and throwing off attempts to reshape.  The |reshapetimeseries|
% function cleans up that messiness:

[ice, yr, tmid] = reshapetimeseries(t, extent_N);

plot(tmid, ice, 'b')
hold on

%%
% By default, it uses date bins, which makes sure to keep calendar dates
% aligned from one year to the next, and averages Feb 28-29 data in leap
% years.  Monthly binning can also be achieved by setting the 'bin' input
% appropriately. (Note that the first year in this dataset started
% mid-October, which leads to the outlier-like point in the monthly
% averages).  

[icem, yr, tmidm] = reshapetimeseries(t, extent_N, 'bin', 'month');

plot(tmidm, icem, 'r')

%%
% While Jan 1 is usually a good place to place the year-to-year wrap,
% sometimes your dataset may call for a different placement.  For example,
% we can place the wrap near the low point of this timeries, in October.
% In this example, we choose 52 evenly-spaced bins per year, which is
% approximately a weekly average:

[ice, yr, tmid] = reshapetimeseries(t, extent_N, ...
    'pivotdate', [9 15], 'bin', 52);

cla
plot(tmid, ice, 'b')
hold on


%%
% One thing to be aware of with this function is that it will add a NaN
% placeholder for any bins where no data existed in the original
% timeseries.  Most of the time this will correspond to larger gaps in your
% timeseries, e.g. at the beginning or end if the timeseries doesn't
% start and end on the same calendar day.  However, this can also occur if
% you choose a binning interval on a finer scale than your original data.
% For example, in this dataset, the early data is sampled every 2 days.  If
% we try binning this on a daily basis, we end up with sparse data,
% staggered every other year:

isearly = t < datetime(1988,1,1);
[ice, yr, tmid] = reshapetimeseries(t(isearly), extent_N(isearly));

tlbl = doy(tmid, 'decimalyear')- year(tmid(1));

figure;
imagesc(yr, tlbl, ice);
shading flat;
cmocean('ice');
xlabel('Year');
ylabel('Year fraction');

%%
% In this case, we'd want to make sure we chose a larger interval when
% doing any real analysis:

[ice, yr, tmid] = reshapetimeseries(t(isearly), extent_N(isearly), 'bin', floor(365/2));

figure;
imagesc(yr, tlbl, ice);
shading flat;
cmocean('ice');
xlabel('Year');
ylabel('Year fraction');



