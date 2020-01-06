function dt = ncdatelim(files, var)
%NCDATELIM Read first and last date from a netcdf file
%
%  tlim = ncdatelim(files, var) 
%
% Input variables:
%
%   files:  string/char array or cell array of strings, file name(s)
%
%   var:    string, name of time variable
%
% Output variables:
%
%   tlim:   n x 2 datetime array, where n is number of files

% Copyright 2018 Kelly Kearney

if ischar(files)
    files = {files};
end
nfile = length(files);

t = nan(nfile,2);
for ii = 1:nfile
   
    I = ncinfo(files{ii}, var);
    if I.Size > 0
        t(ii,1) = ncread(files{ii}, var, 1, 1);
        t(ii,2) = ncread(files{ii}, var, I.Size, 1);
    end
end

tunit = ncreadatt(files{1}, var, 'units');

dt = cftime(t, tunit);

