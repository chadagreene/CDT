function Nc = ncschema_addvars(Nc, varargin)
%NCSCHEMA_ADDVARS Add variable info to a netCDF file schema
%
% Nc = ncschema_addvars(Nc, vname, dimnames, atts, type)
% Nc = ncschema_addvars(Nc, vname, dimnames, atts, type, len)
% 
% Input variables:
%
%   Nc:         netCDF file schema structure (see ncinfo, ncschema_init)
%
%   vname:      variable name, character array or scalar string
%
%   dimnames:   cell array of strings, names of dimensions corresponding to
%               variable dimensions
%
%   atts:       cell array of variable attribute name/value pairs.  Each
%               odd-numbered element should be a character array or scalar
%               string holding the attribute name, and the even-numbered
%               elements are the attribute values (character array, scalar
%               string, or numeric vector).
%
%   type:       variable data type (see nccreate Datatype option for
%               details)
%
%   len:        variable length (only required if dimnames is empty,
%               usually 1 in that case) 
%
% Output variables:
%
%   Nc:     copy of input netCDF file schema structure with the Variables
%           structure expanded to include the new inputs


NewVar = varstruct(varargin{:});

if isempty(Nc.Variables)
    Nc.Variables = NewVar;
else
    Nc.Variables = cat(1, Nc.Variables, NewVar);
end

Nc = updatencschema(Nc);