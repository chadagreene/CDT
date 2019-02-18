function [r,p] = corr3(X,y,varargin) 
% corr3 computes linear or rank correlation for a time series and a 3D dataset. 
% 
%% Syntax 
% 
%  r = corr3(X,y) 
%  r = corr3(...,'detrend') 
%  r = corr3(...,'Name',Value)
%  [r,p] = corr3(...)
% 
%% Description 
% 
% r = corr3(X,y) returns a matrix of the pairwise linear correlation coefficient 
% between each pair of columns in the input matrix X.
% 
% r = corr3(...,'detrend') removes the linear trends from X and y before calculating
% the correlation coefficient. 
% 
% r = corr3(...,'Name',Value) specifies options using one or more name-value pair 
% arguments in addition to the input arguments in the previous syntaxes. For example, 
% 'Type','Kendall' specifies computing Kendall's tau correlation coefficient.
% 
% [r,p] = corr3(...) also returns pval, a matrix of p-values for testing the hypothesis
% of no correlation against the alternative hypothesis of a nonzero correlation.
% 
%% Examples
% For examples, type 
% 
%  cdt corr3
% 
%% Author Info
% This function and supporting documentation were written by Chad A. Greene.
% 
% See also: corr, cov3, xcorr3, and corrcoef. 

%% Initial error checks: 

narginchk(2,Inf)
assert(license('test','statistics_toolbox')==1,'License error: Sorry, the corr3 function requires the Statistics Toolbox.') 
assert(ndims(X)==3,'Input error: Input X must be 3 dimensional. For other size inputs use the corr function.') 
assert(isvector(y),'Error: Input y must be a vector.') 
assert(length(y)==size(X,3),'Error: The length of y must match the third dimension of X.') 

%% Parse optional inputs: 

tmp = strncmpi(varargin,'detrend',3); 
if any(tmp)
   detr = true; 
   varargin = varargin(~tmp); 
else
   detr = false; 
end   

%% Reshape inputs:

mask = all(isfinite(X),3); 
X = cube2rect(X,mask); 

% Columnate y: 
y = y(:); 

%% Do the mathy bits: 

if detr
   X = detrend(X); 
   y = detrend(y); 
end

[r,p] = corr(X,y,varargin{:}); 

%% Unreshape: 

r = rect2cube(r',mask); 

if nargout>1
   p = rect2cube(p',mask); 
end

end