function Nc = ncschema_addatts(Nc, varargin)
%NCSCHEMA_ADDATTS Add global attribute info to a netCDF file schema
%
% Nc = ncshema_addatts(Nc, name, value);
% Nc = ncshema_addatts(Nc, name1, value1, name2, value2, ...);
% 
% This function adds global (file) attribute information to a netCDF file
% schema. 
%
% Input variables:
%
%   Nc:     netCDF file schema structure (see ncinfo, ncschema_init)
%
%   name:   character array or scalar string, attribute name.
%
%   length: character array, scalar string, or numeric vector. attribute
%           value
%
% Output variables:
%
%   Nc:     copy of input netCDF file schema structure with the Attributes
%           structure expanded to include the new inputs

NewAtt = attribstruct(varargin{:});

if isempty(Nc.Attributes)
    Nc.Attributes = NewAtt;
else
    Nc.Attributes = cat(1, Nc.Attributes, NewAtt);
end
