function A = updatencschema(A)
%UPDATENCSCHEMA Checks (and updates) netCDF schema for consistency
%
% B = updatencschema(A)
%
% This function provides a quick check on a netCDF schema structure to make
% sure the dimensions details of each variable match the dimension details
% of the file.  This allows one to quickly propagate dimension details to
% all variables that require them.
%
% Input variables:
%
%   A:  netCDF file structure (see ncinfo, ncwriteschema)
%
% Output variables:
%
%   B:  same as input A, except the Dimensions fields of all variables will
%       be updated to reflect the details in the main file Dimensions
%       structure.

% Copyright 2017 Kelly Kearney

validateattributes(A, {'struct'}, {'nonempty'});

for iv = 1:length(A.Variables)
    if ~isempty(A.Variables(iv).Dimensions)
        
        % Match up dimensions structures
        
        [tf, loc] = ismember({A.Variables(iv).Dimensions.Name}, {A.Dimensions.Name});
        if ~all(tf)
            str = sprintf('%s, ', A.Variables(iv).Dimensions(~tf).Name);
            
            error('Variable dimension name does not match file dimension names:\n  variable: %s\n  dimensions: %s', ...
                A.Variables(iv).Name, str(1:end-2));
        else
            A.Variables(iv).Dimensions = A.Dimensions(loc);
        end
        
    end
end