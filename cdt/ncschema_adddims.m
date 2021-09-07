function Nc = ncschema_adddims(Nc, varargin)
%NCSCHEMA_ADDDIMS Add dimension info to a netCDF file schema
%
% Nc = ncshema_adddims(Nc, name, length, unlim);
% Nc = ncshema_adddims(Nc, name1, length1, unlim1, name2, length2, unlim2, ...);
% 
% Input variables:
%
%   Nc:     netCDF file schema structure (see ncinfo, ncschema_init)
%
%   name:   character array or string, dimension name.
%
%   length: scalar, dimension length
%
%   unlim:  logical scalar, true if the dimension is unlimited and false
%           otherwise. 
%
% Output variables:
%
%   Nc:     copy of input netCDF file schema structure with the Dimensions
%           structure expanded to include the new inputs

% Copyright 2021 Kelly Kearney

NewDim = dimstruct(varargin{:});

if isempty(Nc.Dimensions)
    Nc.Dimensions = NewDim;
else
    Nc.Dimensions = cat(1, Nc.Dimensions, NewDim);
end


