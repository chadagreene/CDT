function [dt, t, unit, refdate] = ncdateread(file, var, t)
%NCDATEREAD Reads datetimes from a netcdf time variable
%
% [tdt, tnum] = ncdateread(file, var)
% [tdt, tnum, unit, refdate] = ncdateread(file, var)
%  [...] = ncdateread(file, var, tnum)
% 
% This function reads in a time variable from a netCDF file, assuming that
% the variable conforms to CF standards with a "<time units> since
% <reference time>" units attribute.  
%
% Currently only works for standard (gregorian) calendar.
%
% Input variables:
%
%   file:       netCDF file name
%
%   var:        variable name
%
%   tnum:       numeric array.  If included, rather than read data from the
%               file, these values are converted using the unit data in the
%               file and variable indicated.
%
% Output variables:
%
%   tdt:        datetime array of times read from file
%
%   tnum:       array of numeric time values, as read directly from file
%               without time conversion  
%
%   unit:       character array, time unit
%
%   refdate:    scalar datetime, reference date

% Copyright 2016 Kelly Kearney

if verLessThan('matlab', '8.4.0')
    error('This function requires R2014b or later (relies on datetime and duration objects)');
end

% Check and parse input

if nargin > 2
    validateattributes(t, {'numeric'}, {}, 3);
else
    if iscell(file)
        t = cellfun(@(x) ncread(x, var), file, 'uni', 0);
        t = cat(1, t{:});
        file = file{1};
    else
        t = ncread(file, var);
    end
end

tunit = ncreadatt(file, var, 'units');
tparts = textscan(tunit, '%s since %D', 1);

switch lower(tparts{1}{1})
    case 'microseconds'
        dt = tparts{2} + seconds(t/1e6);
    case 'milliseconds'
        dt = tparts{2} + seconds(t/1000);
    case 'seconds'
        dt = tparts{2} + seconds(t);
    case 'minutes'
        dt = tparts{2} + minutes(t);
    case 'hours'
        dt = tparts{2} + hours(t);
    case {'days', 'day'}
        dt = tparts{2} + days(t);
    otherwise
        warning('Could not parse reference time');
        dt = [];
end

if nargout > 2
    unit = tparts{1}{1};
end
if nargout > 3
    refdate = tparts{2};
end

