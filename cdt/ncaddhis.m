function ncaddhis(file, hisstr)
%NCADDHIS Append to history attribute in netCDF file
% 
% ncaddhis(file, hisstr)
%
% This function provides a quick shortcut to prepend a dated string to a
% file's history attribute.  The format used is similar to that used by
% netCDF operators (NCO).
%
% Input variables:
%
%   file:   path to netCDF file
%
%   hisstr: string, to be appended to the top of the file's global history
%           attribute.  The string will be prepended with a date.

h = ncreadatt(file, '/', 'history');

newstr = sprintf('%s: %s\n%s', ...
    datestr(now, 'ddd mmm dd HH:MM:SS yyyy'), ...
    hisstr, ...
    h);

ncwriteatt(file, '/', 'history', newstr);
