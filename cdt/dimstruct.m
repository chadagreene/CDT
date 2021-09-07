function D = dimstruct(varargin)
%DIMSTRUCT Create Dimensions structure for netCDF file schema
%
% D = dimstruct(name1, length1, unlimited1, name2, length2, unlimited2)
%
% Input variables:
%
%   name:       character array or string, dimension name
%
%   length:     scalar, dimension length
%
%   unlimited:  logical scalar, true if the dimension is unlimited and
%               false otherwise.
%
% Ouptut variables:
%
%   D:          n x 1 Dimensions structure, where n is the number of
%               name/length/unlimited triplets passed as input

% Copyright 2021 Kelly Kearney

if mod(nargin, 3)
    error('Inputs must be passed as name/length/unlimited triplets');
end

dinfo = reshape(varargin, 3, [])';

cellfun(@(x) validateattributes(x, {'char','string'}, {'scalartext'}, 'dimstruct', 'name'), dinfo(:,1));
cellfun(@(x) validateattributes(x, {'numeric'}, {'integer','scalar'}, 'dimstruct', 'length'), dinfo(:,2));
cellfun(@(x) validateattributes(x, {'logical'}, {'scalar'}, 'dimstruct', 'unlimited'), dinfo(:,3));

D =  struct('Name', dinfo(:,1)', 'Length', dinfo(:,2)', 'Unlimited', dinfo(:,3)');
    
