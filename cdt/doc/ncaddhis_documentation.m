%% |ncaddhis| documentation
%
% This function prepends a dated string to a netCDF file's history
% attribute.
%
% NetCDF best practices recommend that all netCDF files contain a history
% attribute that is updated whenever the file contents are modified.  Some
% netCDF software packages perform this task automatically, but Matlab's
% netCDF-writing and modifying utilities do not.  This function simplifies
% the task of adding a new history attribute if one does not yet exist in a
% file, or preprending a new line to it (rather than overwriting existing
% content) if the attribute already exists.
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Syntax
%
%  ncaddhis(file, hisstr)
%
%% Description
%
% |ncaddhis(file, hisstr)| prepends the character array or scalar string
% |hisstr| to the global history attribute within the existing netCDF file
% |file|.  The string will be preceded by the date and time at which this
% function is called.
%
%% Example
%
% For this example, we'll start with the ERA_Interim_2017.nc sample dataset
% that comes with CDT.  Like many climate datasets, this file already
% includes a history attribute that gives us some information aboutthe data
% came from:

ncreadatt('ERA_Interim_2017.nc', '/', 'history')

%% 
% In this case, we can see that the file was created using the
% grib_to_netcdf-2.9.2 software, and was retrieved in December 2018.
%
% Some tools, such as the <http://nco.sourceforge.net netCDF operator
% utilities (NCO)>, automatically add to the history attribute whenever they
% are used.  For example, let's extract a single grid cell (at 0N,0E) of
% data from the ERA file (you will need NCO installed on your system to run this
% command; if not, don't worry about it, because this is just for
% demonstration purposes).

system('ncks -d latitude,0.0 -d longitude,0.0 ../cdt_data/ERA_Interim_2017.nc ERA_Interim_2017_00.nc');

%%
% The newly-created file includes an updated line in the history attribute
% that reflects the command we just use used to extract it:

ncreadatt('ERA_Interim_2017_00.nc', '/', 'history')

%%
% However, if we make changes using Matlab's utilities, those are not
% automatically documented.

oldtemp = ncread('ERA_Interim_2017_00.nc', 't2m');
newtemp = oldtemp + 1;
ncwrite('ERA_Interim_2017_00.nc', 't2m', newtemp);

%%
% We can use |ncaddhis| to quickly document this change.

ncaddhis('ERA_Interim_2017_00.nc', 'Added 1 degK to all t2m values (ncaddhis_documentation.m script)');
ncreadatt('ERA_Interim_2017_00.nc', '/', 'history')

%%
% There are no strict rules about what information to include in a history
% statement.  The
% <https://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/build/ch02s06.html
% Climate and Forecast (CF) standards> suggest that "Well-behaved generic
% netCDF filters will automatically append their name and the parameters
% with which they were invoked to the global history attribute of an input
% netCDF file"; given that Matlab-based manipulations may be a little more
% involved than a simple filter, I like to add a quick description and
% point end users to the script where my calculations were performed.

%% Author Info
%
% This function and supporting documentation were written by Kelly Kearney
% for the Climate Data Toolbox for Matlab.  