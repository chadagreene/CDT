%% |ncdatelim| documentation 
%
% This function reads the first and last time value from a time variable in
% one or more netCDF files, and converts these values to datetimes. 
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
%
%  tlim = ncdatelim(files, var) 
%
%% Description
%
% |tlim = ncdatelim(files, var)| reads data from the file or files indicated
% by the string/character array or cell array of strings |files|.  It reads
% the first and last value of the time variable |var|, assuming that
% variable uses a standard (i.e. gregorian) calendar and includes a CF
% standard units attribute (see <ncdateread_documentation.m ncdateread> for
% more details).  The returned |tlim| variable is an n x 2 datetime array,
% where n is the number of files queried.
%
%% Example
%
% Read date limits in each of the example netCDF files included with this
% toolbox:

cdtpath = fileparts(which('cdt'));

files = {...
    fullfile(cdtpath, 'cdt_data', 'ERA_Interim_2017.nc')
    fullfile(cdtpath, 'cdt_data', 'ERA_Interim_2017a.nc')
    fullfile(cdtpath, 'cdt_data', 'ERA_Interim_2017b.nc')
    fullfile(cdtpath, 'cdt_data', 'ERA_Interim_2017c.nc')};

tlim = ncdatelim(files, 'time')

%% Author Info
% This function and supporting documentation was written by Kelly Kearney
% for the Climate Data Toolbox for Matlab, 2019.  It is available as part
% of this toolbox, and can also be downloaded individually from
% <https://github.com/kakearney/ncreads-pkg GitHub>.
