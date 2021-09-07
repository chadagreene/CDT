function A = attribstruct(varargin)
%ATTRIBSTRUCT Create Attributes structure for netCDF file schema
%
% A = attribstruct(name1, value1, name2, value2, ...);
%
% Input variables:
%
%   name:   character array or scalar string, attribute name
%
%   value:  character array, scalar string, or numeric vector, attribute
%           value
%
% Output variables:
%
%   A:      n x 1 Attributes structure, where n is the number of
%           name/value pairs passed as input

% Copyright 2021 Kelly Kearney

if mod(nargin, 2)
    error('Inputs must be passed as name/value pairs');
end

atts = reshape(varargin, 2, []);

cellfun(@(x) validateattributes(x, {'char','string'}, {'scalartext'}, 'attribstruct', 'name'), atts(1,:));
cellfun(@(x) validateattributes(x, {'char','string','numeric'}, {'vector'}, 'attribstruct', 'value'), atts(2,:));

A = struct('Name', atts(1,:), 'Value', atts(2,:));


