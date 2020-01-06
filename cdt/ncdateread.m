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

[dt, unit, refdate] = cftime(t, tunit);

