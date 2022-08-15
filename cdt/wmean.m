function M = wmean(A,weights,varargin)
% wmean computes the weighted average or weighted mean value. 
% 
%% Syntax
% 
%  M = wmean(A,weights)
%  M = wmean(...,'all')
%  M = wmean(...,'dim',dim)
%  M = wmean(...,'nanflag') 
% 
%% Description
% 
% M = wmean(A,weights) returns the weighted mean of the elements of A along the first
% array dimension whose size does not equal 1. Dimensions of A must match the 
% dimensions of weights. 
%   * If A is a vector, then wmean(A,weights) returns the weighted mean of the elements. 
%   * If A is a matrix, then wmean(A,weights) returns a row vector containing the weighted 
%     mean of each column.
%   * If A is a multidimensional array, then wmean(A,weights) operates along the first 
%     array dimension whose size does not equal 1, treating the elements as vectors.
%     This dimension becomes 1 while the sizes of all other dimensions remain the same.
% 
% M = wmean(...,'all') computes the weighted mean over all elements. (Requires
% Matlab R2018b or later.) 
% 
% M = wmean(...,'dim',dim) returns the mean along dimension dim. For example, if A 
% is a matrix, then wmean(A,weights,'dim',2) is a column vector containing the
% weighted mean of each row.
% 
% M = wmean(...,'nanflag') specifies whether to include or omit NaN values from the 
% calculation for any of the previous syntaxes. wmean(A,weights,'includenan') includes 
% all NaN values in the calculation while wmean(A,weights,'omitnan') ignores them.
% 
%% Examples 
% For examples type 
% 
%   cdt wmean
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG). 
% 
% See also: mean and local. 

%% Initial error checks:

narginchk(2,Inf) 
assert(isequal(size(A),size(weights)),'Error: Dimensions of A and weights must agree.') 
assert(any(weights(:)~=0),'Error: all weights are zero and that does not make sense.') 

if (any(weights(:)<0))
    warning('Some of the weights are negative. I''ll do the math on the numbers you gave me, but I wonder if this is what you want to be doing?');
end

%% Parse optional inputs:

% Set defaults: 
dim = max([1 find(size(A)~=1,1,'first')]); % operate along the first non-singleton array (or dim 1 if find turns up empty). 

tmp = strncmpi(varargin,'dimension',3); 
if any(tmp)
   dim = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
end

% It's possible the user wants the dimension to be 'all': 
tmp = strcmpi(varargin,'all'); 
if any(tmp)
   dim = varargin{tmp}; 
   varargin = varargin(~tmp); 
end
   
%% Perform mathematics: 

% Set weights to zero where they correspond to NaN
if any(strcmpi(varargin,'omitnan'))
   weights(isnan(A)) = 0; 
end

M = sum(weights.*A,dim,varargin{:})./sum(weights,dim,varargin{:});
