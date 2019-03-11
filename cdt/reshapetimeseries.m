function [xg, yr, tmid] = reshapetimeseries(t, x, varargin)
%RESHAPETIMESERIES Reshapes timeseries data to year by time-of-year grid
%
% [xg, yr] = reshapetimeseries(t, x)
% [xg, yr] = reshapetimeseries(t, x, p1, v1, ...)
% [xg, yr, tmid] = reshapetimeseries(t, x, p1, v1, ...)
%
% This function reshapes timeseries data onto a grid, taking care of any
% concatenation issues that would result from leap days or uneven data
% spacing.
%
% Input variables:
% 
%   t:          vector of datetime values
%
%   x:          vector of values corresponding to times in t
%
% Optional input variables, passed as parameter/value pairs:
%
%   bin:        scalar, number of evenly-spaced bin intervals per year.
%               Alternatively, this can be either the folowing strings:
%               'date':  reshape data based on calendar date.  This is
%                    similar to specifying bin = 365, but makes sure to
%                    keep calendar dates aligned (Feb 28-29 of leap years
%                    are combined into a single bin).
%               'month': reshape data based on calendar months.  Again,
%                    this is similar to specifiying bin = 12, but accounts
%                    for the uneven number of days in each month.  
%
%   yrlim:      1 x 2 vector, years corresponding to the first and last
%               column in the output dataset.  By default this is set to be
%               the limit of the input dataset, but can be manually set to
%               expand or truncate the resulting timeseries.   
%
%   func:       scalar function handle, function to apply to data when
%               mutliple data points fall within a single time bin.
%               [@nanmean]  
%
%   pivotdate:  1 x 2 vector of month and day that marks the switch from
%               one year to the next.  By default this is [1 1], i.e. Jan
%               1.
%
% Output variables:
%
%   xg:         x data regridded to a time-of-year x year matrix.  
%               
%   yr:         years corresponding to the columns of the output matrix xg.
%               Note that when a custom pivot date is entered, these years
%               correspond to the dates in the first row of the matrix, but
%               a calendar year change will occur within each column.
%
%   tmid:       datetime from first non-leap year in dataset corresponding
%               to rows of output matrix.

% Copyright 2019 Kelly Kearney

p = inputParser;
p.addParameter('bin', 'date');
p.addParameter('yrlim', [NaN NaN], @(x) validateattributes(x, {'numeric'}, {'integer', 'nondecreasing','size', [1 2]}));
p.addParameter('func', @nanmean, @(x) validateattributes(x, {'function_handle'}, {}));
p.addParameter('pivotdate', [1 1], @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));

p.parse(varargin{:});
Opt = p.Results; 

% Parse and check bin input

if isnumeric(Opt.bin)
    validateattributes(Opt.bin, {'numeric'}, {'scalar', 'positive', 'integer'}, 'reshapetimeseries', 'bin');
    flag = false;
else
    validateattributes(Opt.bin, {'char','string'}, {'scalartext'}, 'reshapetimeseries', 'bin');
    validatestring(Opt.bin, {'date', 'month'});
    flag = true;
end

% Calculate date limits

if isnan(Opt.yrlim(1))
    if min(t) < datetime(min(year(t)), Opt.pivotdate(1), Opt.pivotdate(2))
        Opt.yrlim(1) = min(year(t)) - 1;
    else
        Opt.yrlim(1) = min(year(t));
    end
end
if isnan(Opt.yrlim(2))
    if max(t) > datetime(max(year(t)), Opt.pivotdate(1), Opt.pivotdate(2))
        Opt.yrlim(2) = max(year(t)) + 1;
    else
        Opt.yrlim(2) = max(year(t));
    end
end

t1 = datetime(Opt.yrlim(1),Opt.pivotdate(1),Opt.pivotdate(2));
t2 = datetime(Opt.yrlim(2),Opt.pivotdate(1),Opt.pivotdate(2));

% Bin data

nyr = year(t2)-year(t1);
yr = year(t1):(year(t2)-1);

isleap = @(x) (mod(x,4)==0 & mod(x,100)~=0) | mod(x,400) == 0;
if all(isleap(yr))
    nonleapidx = 1;
else
    nonleapidx = find(~isleap(yr),1);
end

if flag % Special cases
    switch Opt.bin
        case 'date'
            t1 = datetime(Opt.yrlim(1),Opt.pivotdate(1),Opt.pivotdate(2));
            t2 = datetime(Opt.yrlim(2),Opt.pivotdate(1),Opt.pivotdate(2));
            tedge = (t1:t2)';
            
            isleap = month(tedge) == 2 & day(tedge) == 29;
            tedge = tedge(~isleap);
           
            nperyear = 365;
            
            tmid = datetime(yr(nonleapidx),Opt.pivotdate(1),Opt.pivotdate(2)) + days((1:365)+0.5);
            
        case 'month'
            
            if Opt.pivotdate(2) ~= 1
                warning('Monthy binning requires a pivot date on the first of the month; shifting');
                Opt.pivotdate(2) = 1;
            end
            
            t1 = datetime(Opt.yrlim(1),Opt.pivotdate(1),Opt.pivotdate(2));
            t2 = datetime(Opt.yrlim(2),Opt.pivotdate(1),Opt.pivotdate(2));
            
            [yr,mn] = ndgrid(Opt.yrlim(1):Opt.yrlim(2), 1:12);
            tedge = unique(datetime(yr(:), mn(:), ones(numel(yr),1)));
            tedge = tedge(tedge >= t1 & tedge <= t2);
            
            nperyear = 12;
            
            tmid = datetime(yr(nonleapidx), Opt.pivotdate(1)+(0:11), 15);
            
    end
else % Equal intervals per year
    yredge = datetime(year(t1):year(t2), Opt.pivotdate(1),Opt.pivotdate(2));
    tedge = NaT(Opt.bin+1,nyr);
    for iyr = 1:nyr
        tedge(:,iyr) = linspace(yredge(iyr), yredge(iyr+1), Opt.bin+1);
    end
    tmid = tedge(1:end-1,nonleapidx) + diff(tedge(:,nonleapidx))./2;
    tedge = unique(tedge);
    
    nperyear = Opt.bin;
    

end

bins = discretize(t, tedge);
nt = length(tedge) - 1;

[g, binunq] = findgroups(bins);

xg = nan(nt,1);
xg(binunq) = splitapply(Opt.func, x, g);

xg = reshape(xg, nperyear, nyr);




