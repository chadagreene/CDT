function V = varstruct(varargin)
%VARSTRUCT Create Variable structure for netCDF file schema
%
% V = varstruct(vname, dimnames, atts, type)
% V = varstruct(vname, dimnames, atts, type, len)
% 
% Input variables:
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
%   V:          1 x 1 Variables structure

% Copyright 2021 Kelly Kearney

p = inputParser;
p.addRequired('vname', @(x) validateattributes(x, {'char','string'}, {'scalartext'}));
p.addRequired('dimnames', @(x) validateattributes(x, {'cell','string'}, {}));
p.addRequired('atts');
p.addRequired('type', @(x) validateattributes(x, {'char','string'}, {'scalartext'}));
p.addOptional('len', [], @(x) validateattributes({'numeric'}, {'scalar','integer'}));

p.parse(varargin{:});
Opt = p.Results;

cellfun(@(x) validateattributes(x, {'char','string'}, {'scalartext'}, 'dimstruct', 'name'), Opt.dimnames);
validatestring(Opt.type, {'double','single','int64','uint64','int32','uint32',...
    'int16','uint16','int8','uint8','char'});

V.Name = Opt.vname;
if isempty(Opt.dimnames)
    V.Dimensions = [];
    V.Size = Opt.len;
else
    V.Dimensions = struct('Name', Opt.dimnames, 'Length', [], 'Unlimited', []);
    V.Size = [];
end
V.Attributes = attribstruct(Opt.atts{:});
V.Datatype = Opt.type;

