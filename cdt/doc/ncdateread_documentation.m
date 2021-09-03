%% |ncdateread| documentation 
%
% This function reads in a time variable from a netCDF file into a datetime
% array, assuming that the variable conforms to CF standards with a ' _time
% units_ since _reference time_' units attribute. 
%
% See also <cftime_documentation.html |cftime|>
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Syntax
%
%  tdt = ncdateread(file, var)
%  [tdt, tnum, unit, refdate] = ncdateread(file, var)
%
%% Description
%
% |tdt = ncdateread(file, var)| reads values from the time variable |var|
% in the netCDF file (or files) |file| into the datetime array |tdt|,
% assuming that variable uses a standard (i.e. gregorian) calendar and
% includes a units attribute in the form of ' _time units_ since _reference
% time_'. The supported time units are microseconds, milliseconds, seconds,
% hours, minutes, and days (or day).  |file| can be either a
% string/character array holding the path of a single file, or a cell array
% of strings holding a set of files that share a single unlimited time
% dimension.
%
% |[tdt, tnum, unit, refdate] = ncdateread(file, var)| also returns the
% original file time values |tnum| in their unconverted form, the |unit|
% character array, and a datetime |refdate| that matches the reference date
% in the units attribute.
%
% |[...] = ncdateread(file, var, tnum)| provides an option to convert
% numeric-time values in a variable using the same unit properties in the
% indicated by the file and variable name. 
%
% NOTE: Options for year or month units are intentionally not included here
% due to the possibility for incorrect translation related to these units.
% CF standards define a year to be exactly 365.242198781 days, rather than
% a calendar year; similarly, a month is 1/12 of this value.  This is
% rarely a useful way of counting time, and files that do use months
% or years as a counter may intend to imply calendar months/years instead.
% Therefore, we leave it to the user to determine whether a file using
% these units intends the calendar year interpretation or the strict
% interpretation and to manually parse the date themselves.
%
%% Example
%
% The example ERA Interim file follows typical climate data standards for
% its time attribute:

ncdisp('ERA_Interim_2017.nc', 'time');

%%
% Here, we can read that time data directly from the file without needing
% to know ahead of time what the units or reference date are:

[tdt, tnum, unit, refdate] = ncdateread('ERA_Interim_2017.nc', 'time')

%% 
%
% If the time variables were already in our workspace (for example, if the
% data had been read in using some of the more flexible hyperslab
% subsetting options available in |<ncstruct_documentation.html ncstruct>|,
% we can convert the values after the fact by pointing to a file with the
% necessary conversion units data:

A = ncstruct('ERA_Interim_2017.nc', struct('time', [1 5 2]));
A.time

%%
A.time = ncdateread('ERA_Interim_2017.nc', 'time', A.time);
A.time

%% Author Info
%
% This function and supporting documentation was written by Kelly Kearney
% for the Climate Data Toolbox for Matlab, 2019.  The |ncstruct| function
% merges the capabilities of the older |ncreads| and |ncreadsseries|
% functions, which can still be found on
% <https://github.com/kakearney/ncreads-pkg GitHub>; however, this earlier
% package is no longer being updated.


