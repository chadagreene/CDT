function [dt, unit, refdate] = cftime(t, tunit, fmt)
%CFTIME Convert climate forecast time to datetime
%
% [dt, unit, refdate] = cftime(t, tunit)
% [dt, unit, refdate] = cftime(t, tunit, fmt)
%
% Climate forecast (CF) conventions specify that time should be specified
% as "time-unit since timestamp".  This function parses the unit string
% associated with a CF time and converts the associated values to
% datetimes.
%
% Input variables:
%
%   t:          matrix of time values
%
%   tunit:      string or character array describing the units of the t
%               array. Should be of the format 'time-unit since timestamp' 
%
%   fmt:        reference date format.  By default, this function will
%               attempt to parse the time automatically using the datetime
%               function.  If a custom input format would be required to
%               read the date via datetime, provide it here.
%
% Output variables:
%
%   dt:         array of datetimes, same size as t
%
%   unit:       character array, time unit parsed from tunit
%
%   refdate:    scalar datetime, reference date (timestamp) parsed from
%               tunit.

% Copyright 2019 Kelly Kearney


if nargin > 2
    tparts = textscan(tunit, '%s since %s', 1);
    tparts{2} = datetime(tparts{2}, 'inputformat', fmt);
else
    tparts = textscan(tunit, '%s since %D', 1);
end

switch lower(tparts{1}{1})
    case {'microseconds', 'microsecond'}
        dt = tparts{2} + seconds(t/1e6);
    case {'milliseconds', 'millisecond'}
        dt = tparts{2} + seconds(t/1000);
    case {'seconds', 'second'}
        dt = tparts{2} + seconds(t);
    case {'minutes', 'minute'}
        dt = tparts{2} + minutes(t);
    case {'hours', 'hour'}
        dt = tparts{2} + hours(t);
    case {'days', 'day'}
        dt = tparts{2} + days(t);
    otherwise
        warning('Could not parse reference time');
        dt = [];
end

if nargout > 1
    unit = tparts{1}{1};
end
if nargout > 2
    refdate = tparts{2};
end
