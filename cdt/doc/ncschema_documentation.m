%% The |ncschema_| family of functions 
%
% These functions assist in the process of building a netCDF file schema
% structure that can be used to create new netCDF files.  
% 
% File schemas can be particularly useful when building large and complex
% netCDF files where you want to fully define the characteristics of the
% new file prior to adding any data to it.  These functions help to either
% build the schema from scratch or to append new data to an existing schema
% (for example, one returned by
% <https://www.mathworks.com/help/matlab/ref/ncinfo.html |ncinfo|>).
% Schemas can be used by
% <https://www.mathworks.com/help/matlab/ref/ncwriteschema.html
% |ncwriteschema|> to create new files or to extend the properties of
% existing files.
%
% See also <https://www.mathworks.com/help/matlab/ref/ncwriteschema.html
% |ncwriteschema|>, <https://www.mathworks.com/help/matlab/ref/ncinfo.html
% |ncinfo|>.
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Library
%
% The primary functions included in this family of functions are:
%
% * |ncschema_init|: Create netCDF file schema structure
% * |ncschema_addatts|: Add global attribute info to a netCDF file schema
% * |ncschema_adddims|: Add dimension info to a netCDF file schema
% * |ncschema_addvars|: Add variable info to a netCDF file schema
%
% These functions also call some lower-level helper functions that can be
% also be accessed by users:
%
% * |attribstruct|: Create Attributes structure for netCDF file schema
% * |dimstruct|: Create Dimensions structure for netCDF file schema
% * |varstruct|: Create Variable structure for netCDF file schema
% * |updatencschema|: Checks (and updates) netCDF schema for consistency
%
%% Description
%
% |Nc = ncschema_init(format)| initializes a netCDF file schema |Nc| with
% the file format |format| (see
% <https://www.mathworks.com/help/matlab/ref/nccreate.html |nccreate|>
% 'Format' property for options and details).  Default is 'classic'.
%
% |Nc = ncschema_addatts(Nc, name, value, ...)| adds global file attribute
% information to a netCDF file schema |Nc|.  Attributes are passed as
% name/value pairs, where each |name| input is a character array or scalar
% string that will be used as the name of the attribute and |value| is a
% character array, scalar string, or numeric vector.  Note that this
% function is only for adding file attributes; for variable attributes, see
% |ncschema_addvars| below.
%
% |Nc = ncschema_adddims(Nc, name, length, unlim, ...)| adds dimension
% information to a netCDF file schema |Nc|.  Dimensions are passed as
% name/length/unlim triplets, where |name| is a character array or scalar
% string indicating the dimension name, |length| is a numeric scalar
% indicating the dimension length, and |unlim| is a logical scalar
% indicating whether the dimension is unlimited.
%
% |Nc = ncschema_addvars(Nc, vname, dimnames, atts, type, len)| adds the
% variable information for a single variable to a netCDF file
% schema |Nc|. Along with the name, |vname|, which should be a character
% array or scalar string, the user provides a list of dimension names
% corresponding to the variable's dimensions as a cell array of strings,
% |dimnames|; attributes as a list name/value pairs in a cell array,
% |atts|; and variable type |type| (see nccreate Datatype input for options
% and details).  Occasionally, a user may need to pass a variable length
% option, |len|; this is typically only needed for scalar variables without
% dimensions, where the length will be 1.  In almost all other cases, the
% appropriate dimension length values will be automatically inherited based
% on the assigned dimension names.
% 
%% Example
%
% In this example, we build a similar file as in the
% <nbcuild_documentation.html |ncbuild|> documentation, starting with the
% same sample data:

x = 1:10;
y = 1:8;
Z1 = rand(8,10);

%%
% We can then incrementally build the file schema by setting the format,
% then adding desired file attributes, dimensions, and variables.

Nc = ncschema_init('classic');
Nc = ncschema_addatts(Nc, ...
    'author', 'Jane Doe', ...
    'history', sprintf('%s: created in Matlab as part of ncbuild_tutorial', datetime('today')));
Nc = ncschema_adddims(Nc, 'x', length(x), false, 'y', length(y), false);
Nc = ncschema_addvars(Nc, 'x', {'x'}, {'long_name', 'x data', 'units', 'x-units'}, 'double');
Nc = ncschema_addvars(Nc, 'y', {'y'}, {'long_name', 'y data', 'units', 'y-units'}, 'double');
Nc = ncschema_addvars(Nc, 'Z1', {'y','x'}, {'long_name', 'Z1 data', 'units', 'z-units'}, 'double');
Nc = ncschema_addvars(Nc, 'Z2', {'y','x'}, {'long_name', 'Z1+pi',   'units', 'z-units'}, 'single');

%%
% The code above only creates the schema structure.  It takes care of some
% of the behind-the-scenes bookkeeping that is expected in a netCDF schema
% structure, such as copying the appropriate Dimensions structure
% information to each Variables structure elements.  Once the structure is
% complete, you can double-check that all the details look correct before
% creating the file.  While adding to netCDF files can be pretty
% straightforward, removing things is less so, so allowing this
% double-check can be useful before commiting anything to disk. 

disp('The top level structure:')
Nc
disp('File Attributes:')
struct2table(Nc.Attributes)
disp('Dimensions:')
struct2table(Nc.Dimensions)
disp('Variables:')
struct2table(Nc.Variables)

%%
% To write to file, use the <https://www.mathworks.com/help/matlab/ref/ncwriteschema.html
% |ncwriteschema|> function:

ncwriteschema('test4.nc', Nc);
ncdisp('test4.nc')

%%
% Note that at this point, the file does _not_ hold any data, only
% placeholder fill values: 

system('ncdump -v Z1 test4.nc');

%%
% (When read into Matlab, these placeholder values may show up as large
% values, since Matlab doesn't always properly interpret the default
% _FillValue...)

ncread('test4.nc', 'Z1')

%%
% You will need to add the actual data to the file using
% <https://www.mathworks.com/help/matlab/ref/ncwrite.html |ncwrite|>.

ncwrite('test4.nc', 'x', x);
ncwrite('test4.nc', 'y', y);
ncwrite('test4.nc', 'Z1', Z1);

%%
% Depending on the size of your data, it may make sense to add this data
% incrementally.  For example, here we add the Z2 variable data by
% iterating over the y dimension:

for iy = 1:length(y)
    ncwrite('test4.nc', 'Z2', Z1(iy,:)+pi, [iy 1]);
end

%%
% This flexibility, as well as the ability to contruct the full file spec
% before writing anything to a file, is the primary advantage to using this
% method instead of <ncbuild_documentation.html |ncbuild|>.

%% Author Info
%
% This function and supporting documentation were written by Kelly Kearney
% for the Climate Data Toolbox for Matlab. 

