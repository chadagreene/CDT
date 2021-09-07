%% |ncbuild| documentation 
%
% The |ncbuild| function simplifies the process of building netCDF output
% files based on Matlab data variables.
%
% This function writes Matlab data to a new or existing file while also
% defining netCDF file properties, such as variable names, dimension names
% and sizes, and file and variable attributes as appropriate for the data
% being written.  It provides a wrapper around the tasks typically
% performed by |nccreate| and |ncwrite|, while also reducing the amount of
% extra code required to repeat common tasks.
%
% See also <https://www.mathworks.com/help/matlab/ref/nccreate.html |nccreate|>,
% <https://www.mathworks.com/help/matlab/ref/ncwrite.html |ncwrite|>,
% <https://www.mathworks.com/help/matlab/ref/ncwriteatt.html |ncwriteatt|>  
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%
%% Syntax
%
%   ncbuild(file, var)
%   ncbuild(file, var, param1, val1, ...)
%
%% Description
%
% |ncbuild(file, var)| writes the  text or numeric data data in |var| to
% a new variable in the netCDF file |file|.  If |file| does not yet exist,
% it will be created using the classic format.
%
% |ncbuild(..., 'name', name)| uses the specified character array
% |name| as the variable name. If not included, the name of the input
% variable will be used; if the variable input data does not have a
% variable name, 'variableX' will be used, where X is the counter number of
% variables in the file once variableX is added. 
%
% |ncbuild(..., 'dimnames', dimnames)| assigns the dimension names in the
% string array or cell array of strings/char |dimnames| to the
% newly-created netCDF variable.  These dimensions will be created in the
% file if needed.  If not included, dimensions of unique length will be
% labeled 'i', 'j', 'k', etc. 
%
% |ncbuild(..., 'format', format)| specifies the file format.  See
% <https://www.mathworks.com/help/matlab/ref/nccreate.html |nccreate|>
% 'Format' option for options and details.  Default: 'classic'
%
% |ncbuild(..., 'fileatts', fileatts)| adds global file attributes to the
% file.  |fileatts| should be a cell array of name/value attribute pairs
% (see |attribstruct| input description for details)  
%
% |ncbuild(..., 'unlimited', unlim)| indicates the dimensions (passed by
% name in the string array or cell array of strings/char |unlim|) that
% should be unlimited in length.  Note that for classic files, and many
% netCDF conventions, only one dimension can be unlimited. Default: {}
% (i.e., no unlimited dimensions)  
%
% |ncbuild(..., 'varatts', varatts)| supplies variable attributes for the
% newly-created file variable.  |varatts| should be a cell array of
% name/value attribute pairs (see |attribstruct| input description for
% details)  
%
% |ncbuild(..., 'type', type)| specifies the variable data type.  See
% <https://www.mathworks.com/help/matlab/ref/nccreate.html |nccreate|>
% 'Datatype' option for options and details.  If not included, type will be
% inferred from the input variable data.  Note that if a type _is_
% specified and does not match that of |var|, the input data will be
% automatically recast to this type on writing.


%% Example 1: Save variable data to file with minimal metadata
%
% For this example, we start with 3 variables:

x = 1:10;
y = 1:8;
Z1 = rand(8,10);

%%
% We can now use ncbuild to save the |Z1| data to a netCDF file.

ncbuild('test1.nc', Z1);

%%
% When using this minimal syntax, the ncbuild function first recognizes
% that it needs to create a new file, and creates it using the default
% classic format. It assumes that the name of the stored variable should
% match its Matlab variable name, and assigns names to the variable
% dimensions using it's own default scheme, rather than requiring the user
% to supply any of these details.

ncdisp('test1.nc')

%%
% We can continue to use ncbuild to add new variables to the file as well.
% If we continue to provide minimal details, ncbuild will continue trying
% to match up the variable sizes to existing dimensions in the file:  

ncbuild('test1.nc', x);
ncbuild('test1.nc', y);
ncbuild('test1.nc', Z1+pi);
ncdisp('test1.nc')

%%
% Notice that for that last addition, the variable data wasn't passed as a
% single variable, but rather as an expression.  Because |ncbuild| didn't
% have a Matlab variable name to steal for its use, it instead
% fell back on its default variable naming scheme, which simply numbers
% variables based on the order they were added to the file.
%
% The minimal input options do have their limits; if you attempt pass a
% variable to |ncbuild| where the dimensions are ambiguous, it will throw
% an error message.

Z3 = rand(10,10);
try
    ncbuild('test1.nc', Z3);
catch ME
    disp(ME.message);
end

%%
% In this example, |ncbuild| doesn't know whether the first or second
% dimension of Z3 should match up with the existing dimension |j|.  The
% same sort of error will occur if the file already contains multiple
% dimensions with the same length; in this case, |ncbuild| needs some
% clarification from the user in order to figure out which dimensions to
% use.  To be more explicit, we can use the optional |ncbuild| inputs, as
% in the next example.

%% Example 2: Building a netCDF file with explicit metadata
%
% While the minimal syntax option demonstrated above saves a lot of time and
% hassle, often you will want to exert a bit more control over the metadata
% within your new netCDF files.  
%
% This example writes the same data to file as in the above example.
% However, this time around, we provide some explicit detail: 
%
% * We provide meaningful names for the dimensions.  Note that because the
% x and y variables have the same name and size as the x and y dimensions,
% they can now be considered "coordinate variables"; many software programs
% designed to work with netCDF can intelligently recognize and use
% coordinate variables for tasks such as plotting.
% * We assign a meaningful variable name to Z2
% * We provide longer, descriptive names for each variable by giving each
% of them a 'long_name' attribute. The
% <http://cfconventions.org/cf-conventions/cf-conventions.html#long-name
% 'long_name'> attribute is an optional but highly-recommended part of the
% <http://cfconventions.org/ Climate and Forecast (CF) conventions>.
% * We provide units for all variables by giving each of them a 'units'
% attribute.  The
% <http://cfconventions.org/cf-conventions/cf-conventions.html#units
% 'units'> attribute is a CF requirement for variables representing
% dimensional qualities.  
% * We add file attributes listing the author and history of the file.
% These
% <http://cfconventions.org/cf-conventions/cf-conventions.html#description-of-file-contents
% file content> global attributes are very helpful for providing a
% description of where the file data comes from.
% * We specify dimension names for Z3, allowing it to be successfully added
% to the file this time.

ncbuild('test2.nc', x, ...
    'dimnames', {'x'}, ...
    'varatts', {'long_name', 'x data', 'units', 'x-units'}, ...
    'fileatts', {'author', 'Jane Doe', ...
                 'history', sprintf('%s: created in Matlab via ncbuild', datetime('today'))});
ncbuild('test2.nc', y, ...
    'dimnames', {'y'}, ...
    'varatts', {'long_name', 'y data', 'units', 'y-units'});
ncbuild('test2.nc', Z1, ...
    'varatts', {'long_name', 'Z1 data', 'units', 'z-units'});
ncbuild('test2.nc', Z1+pi, ...
    'name', 'Z2', ...
    'varatts', {'long_name', 'Z1+pi', 'units', 'z-units'});
ncbuild('test2.nc', Z3, ...
    'dimnames', {'x','x2'}, ...
    'varatts', {'long_name', 'random numbers', 'units', 'z-units'});
ncdisp('test2.nc')

%%
% This option still allows for less user input than would be needed with
% the |nccreate| function.  For example, we were able to let |ncbuild|
% intuit the correct pre-existing dimensions to use for the Z1 and Z2
% variables.

%% Author Info
%
% This function and supporting documentation were written by Kelly Kearney
% for the Climate Data Toolbox for Matlab.  



