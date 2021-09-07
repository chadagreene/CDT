function Nc = ncschema_init(varargin)
%NCSCHEMA_INIT Create netCDF file schema structure
%
% Nc = ncschema_init;
% Nc = ncschema_init(format)
%
% This function initialized a simple netCDF schema structure.
%
% Input variables:
%
%   format: string or character array specifying the file format; can be
%           either 'classic', '64bit', 'netcdf4_classic', or 'netcdf4'.
%           ['classic']
%
% Output variables:
%
%   Nc:     netCDF file schema (see ncinfo, ncwriteschema) with empty
%           Attributes, Dimensions, Variables fields and the appropriate
%           Format and Name fields. 

% Copyright 2021 Kelly Kearney

p = inputParser;
p.addOptional('format', 'classic', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));

p.parse();
Opt = p.Results;

validatestring(Opt.format, {'classic', '64bit', 'netcdf4_classic', 'netcdf4'});

Nc.Name = '/';
Nc.Format = Opt.format;
Nc.Attributes = [];
Nc.Dimensions = [];
Nc.Variables = [];






