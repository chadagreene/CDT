%% |cftime| documentation 
%
% The |cftime| function converts between Climate Forecast (CF) convention
% times and Matlab datetimes.
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Syntax
%
%  [dt, unit, refdate] = cftime(t, tunit)
%  [dt, unit, refdate] = cftime(t, tunit, fmt)
%  [dt, unit, refdate] = cftime(t, tunit, fmt, mode)
%
%% Description
%
% |[dt, unit, refdate] = cftime(t, tunit)| converts a matrix of numeric CF
% times |t| with units described by the reference string or character array
% |tunit| to a matrix of datetimes, |dt|, with the same dimensions as |t|.
% |tunit| should be specified as "time-unit since timestamp"; see 
% the <https://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/build/ch04s04.html
% CF Conventions time coordinate documentation> for more information.  The
% |unit| and |refdate| output variables are optional, and will parse the
% |tunit| string into a character array with the time unit and a scalar
% datetime holding the reference date, respectively.
%
% |[dt, unit, refdate] = cftime(t, tunit, fmt)| allows the user to specify
% the format of the reference date portion of the |tunit| string.  This
% string should follow the same format as the |'InputFormat'| option for
% <https://www.mathworks.com/help/matlab/ref/datetime.html |datetime|>. 
% If not included, |cftime| will attempt to parse the string automatically
% using the same rules as |datetime|.
%
% |t = cftime(dt, tunit, fmt, 'reverse')| converts a matrix of datetimes to
% numeric CF times |t|.  The optional |fmt| specifier can be an empty array
% to allow for default reference date parsing within the |tunit| string.
%
%% Example 1: Converting from CF time to datetime
%
% Most data files used in climate science try to abide by the Climate
% Forecast standards for metadata; for time variables, these standards
% specify dates as a time duration since a reference date.  We can see this
% in the example ERA Interim data:

ncdisp('ERA_Interim_2017.nc', 'time');
t = ncread('ERA_Interim_2017.nc', 'time')

%%
% We can convert this data to a more user-friendly datetime via |cftime|:

tunit = 'hours since 1900-01-01 00:00:00.0';
dt = cftime(t, tunit)

%%
% (In this case, we could also simply read directly from the file with the
% <ncdateread_documentation.html |ncdateread|> function, which also reads
% the time data and time unit string directly from the file and then calls
% |cftime| internally.) 

%% Example 2: Converting from datetime to CF time
%
% The reverse calculation will often be useful if you want to write new
% data to your own netCDF file and follow the recommended CF standards.
% First, we calculate the conversion:

tnew = datetime(2018,1:12,1)';
tcf = cftime(tnew, tunit, [], 'reverse')

%%
% Next, write to a file (see <ncbuild_documentation.html |ncbuild|> for
% details of this process):

ncbuild('testcffile.nc', tcf, ...
    'name', 'time', ...
    'dimname', {'time'}, ...
    'varatts', {'units', tunit});

%%
% We can now check and see that these units are properly interpreted by
% standard netCDF utilities like the command-line ncdump function:

system('ncdump -v time -t testcffile.nc')

%% Author Info
%
% This function and supporting documentation were written by Kelly Kearney
% for the Climate Data Toolbox for Matlab.  
