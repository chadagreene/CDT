%% |ncstruct| documentation 
% The |ncstruct| function provides an easy syntax to read one or more
% variables from a netCDF file, either in their entirety or smaller
% hyperslabs.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Syntax
%
%  Data = ncstruct(file)
%  Data = ncstruct(file, var1, var2, ...)
%  Data = ncstruct(file, Scs, ...)
%
%% Description
%
% |Data = ncstruct(file)| reads all variable data from the indicated netCDF
% file into a structure |Data|; the field names of |Data| correspond to the
% variable names from the file.
%
% |Data = ncstruct(file, var1, var2, ...)| reads only the specified variable
% data.  The special string 'dimensions' indicates that all dimension
% variables should be read in; a dimension variable is any variable whose
% name and size corresponds to one of the file dimensions.
%
% |Data = ncstruct(file, Scs, ...)| reads data using the dimension
% hyperslabs in the structure |Scs|.  The field names in |Scs| should match
% the dimension names in the file, and each field holds a 1 x 3 array of
% |[start count stride]|, indicating that data should be read along the
% specified dimension starting at index |start|, reading |count| elements,
% with inter-element spacing |stride|.

%% Example 1: Reading variables from a single file
%
% A small simple file can be read in in its entirety:

A = ncstruct('example.nc')

%%
% For a larger file, you probably don't want or need to read in all the
% variables.  Here, we read in only wind speed variables, along with the
% dimension variables:

B = ncstruct('ERA_Interim_2017.nc', 'u10', 'v10', 'dimensions')

%% Example 2: Subsetting dimensions
%
% The |ncread| function allows you to read hyperslabs of variables;
% however, its syntax requires you to provide start, count, and stride
% parameters for all dimensions of that variable in the proper order;
% determining the dimension names and order of dimensions for each variable
% you want to read can become tedious.  The |ncstruct| function simplfies
% things by determining which variables include a particular dimension, and
% in what order, for you.
%
% Returning to the ERA Interim 2017 dataset, we can read data from all
% variables but only at a single location, and every other time:

Scs = struct('latitude', [1 1 1], 'longitude', [1 1 1], 'time', [1 Inf 2]);
C = ncstruct('ERA_Interim_2017.nc', Scs)

%% Example 3: Reading from multiple files
%
% Multi-file datasets are common in climate model output or other
% long-running datasets, where data is split into separate files for each
% day/month/year/etc. to keep file sizes manageable and to allow the
% dataset to grow as time passes without needing to edit existing files.
% The following set of files hold one time slice each from the ERA Interim
% dataset used in the previous examples:

files = {...
    'ERA_Interim_2017a.nc'
    'ERA_Interim_2017b.nc'
    'ERA_Interim_2017c.nc'};

%%
% We can read data from this set of files using the same syntax as with
% a single file.  Variables that are repeated across the files, such as the
% dimension variables, will only be read once, while the variables that
% include the time dimension will be read from each file and concatenated.

D = ncstruct(files, 'u10', 'v10', 'dimensions')

%% Author Info
% This function and supporting documentation was written by Kelly Kearney
% for the Climate Data Toolbox for Matlab, 2019.


