function S = catstruct(dim, varargin)
%CATSTRUCT Concatenate structures with dissimilar fields
%
%  S = catstruct(dim, A1, A2, A3, ...)
%
% This function concatenates the input structures along the dimension dim.
% The resulting structures contains all fields found in any of the input
% structures.  If an input structure did not originally have that field,
% the new field is left empty.

% Copyright 2008 Kelly Kearney

dims = cell2mat(cellfun(@size, varargin, 'uni', 0)');

ndim = length(dims);
checkdim = dims;
checkdim(:,dim) = [];
if length(unique(checkdim, 'rows')) ~= 1
    error('Inconsistent dimensions along concatenation');
end


allfields = cellfun(@fieldnames, varargin, 'uni', 0);
allfields = unique(cat(1, allfields{:}));

for istruct = 1:length(varargin)
    s{istruct} = varargin{istruct};
    for ifield = 1:length(allfields)
        if ~isfield(s{istruct},allfields{ifield})
            [s{istruct}.(allfields{ifield})] = deal([]);
        end
    end
end
        
S = cat(dim, s{:});

        