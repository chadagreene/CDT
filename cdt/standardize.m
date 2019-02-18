function [Xs,mu] = standardize(X,varargin) 
% standardize removes the mean of a variable and scales it such that its
% standard deviation is 1. This operation is sometimes known as "centering
% and scaling". 
% 
%% Syntax
% 
%  Xs = standardize(X) 
%  Xs = standardize(...,dim)
%  Xs = standardize(...,nanflag) 
%  Xs = standardize(...,'weighting',w)
%  [Xs,mu] = standardize(...)
%  
%% Description 
% 
% Xs = standardize(X) subtracts the mean of X from X, then divides by the 
% standard deviation of X. 
% 
% Xs = standardize(...,dim) specifies a dimension along which to operate.
% Standardization is along the first nonsingleton dimension by default.
% 
% Xs = standardize(...,nanflag) specifies whether to include or omit NaN values from the 
% calculation for any of the previous syntaxes. standardize(X,'includenan') includes 
% all NaN values in the calculation while standardize(X,'omitnan') ignores
% them. Default behavior is 'includenan'. 
% 
% Xs = standardize(...,'weighting',w) specifies a weighting scheme w for the  
% calculation of the standard deviation. When w = 0 (default), S is normalized by N-1.
% When w = 1, S is normalized by the number of observations, N. w also can be a
% weight vector containing nonnegative elements. In this case, the length of w
% must equal the length of the dimension over which std is operating. 
% 
% [Xs,mu] = standardize(...) returns mu mean and standard deviation of X.
% If X is a vector, mu(1) is the mean of X and mu(2) is the standard
% deviation of X. If X is multidimensional, the mean is the first entry
% in the direction of operation and std is the second entry. In other
% words, if X is three dimensional and is standardized alnog the third
% dimension, mu(:,:,1) is the mean and mu(:,:,2) is the standard deviation
% of X. 
% 
%% Examples
% For examples, type 
% 
%   cdt standardize 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin, 2018. 
% 
% See also: mean, std, and bsxfun. 

%% Error checks: 

narginchk(1,Inf) 
assert(isnumeric(X),'First input must be numeric.') 

%% Parse inputs: 

% NaN option: 
tmp = strncmpi(varargin,'omitnan',4); 
if any(tmp) 
   NaNflag = 'omitnan'; 
else
   NaNflag = 'includenan'; 
end

% Check for weighting: 
tmp = strncmpi(varargin,'weighting',5); 
if any(tmp)
   w = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(tmp); 
else
   w = 0; % the default in std
end

% Determine default dimension: 
if isscalar(X) 
   dim = 1; 
else
   dim = find(size(X)>1,1,'first'); % first nonsingleton dimension
end

% Overwrite default dimension w/ user-defined dimension: 
tmp = cellfun(@isscalar,varargin);
if any(tmp)
   dim = varargin{tmp}; 
end

%% Do math: 

% Determine mean and std: 
Xmean = mean(X,dim,NaNflag); 
Xstd = std(X,w,dim,NaNflag); 

% Remove the mean: 
X = bsxfun(@minus,X,Xmean); 

% Scale by std: 
Xs = bsxfun(@rdivide,X,Xstd); 

%% Package output: 

if nargout>1
   mu = cat(dim,Xmean,Xstd); 
end


end