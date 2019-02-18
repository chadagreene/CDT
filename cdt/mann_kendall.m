function [h,p] = mann_kendall(y,varargin)
% mann_kendall performs a standard simple Mann-Kendall test to determine the 
% presence of a significant trend. (Requires the Statistics Toolbox)
% 
%% Syntax
% 
%  h = mann_kendall(y)
%  h = mann_kendall(y,alpha)
%  h = mann_kendall(...,'dim',dim)
%  [h,p] = mann_kendall(...)
% 
%% Description
% 
% h = mann_kendall(y) performs a standard simple Mann-Kendall test on the
% time series y to determine the presence of a significant trend. If h is
% true, the trend is present; if h is false, you can reject the hypothesis
% of a trend. This function assumes y is equally sampled in time. 
% 
% h = mann_kendall(y,alpha) specifies the alpha significance level in the
% range 0 to 1. Default alpha is 0.05, which corresponds to the 5% significance 
% level
% 
% h = mann_kendall(...,'dim',dim) specifies the dimension along which the
% trend is calculated. By default, if y is a 1D array, the trend is calculated
% along the first nonsingleton dimension of y; if y is a 2D matrix, the trend
% is calcaulated down the rows (dimension 1) of y; if y is a 3D matrix, the 
% trend is calculated down dimension 3. 
% 
% [h,p] = mann_kendall(...) also returns the p-value of the trend. 
% 
%% Examples 
% For examples, type 
% 
%  cdt mann_kendall
% 
%% References 
% 
% Mann, H. B. (1945), Nonparametric tests against trend, Econometrica, 13, 
% 245-259.
% 
% Kendall, M. G. (1975), Rank Correlation Methods, Griffin, London.
% 
%% Author Info 
% This function was written by Chad A. Greene for the Climate Data Toolbox
% for Matlab, February 2019. Adapted from the Mann_Kendall function by Simone 
% Fatichi (https://www.mathworks.com/matlabcentral/fileexchange/25531).
% 
% See also: trend.

%% Initial Error checks: 

narginchk(1,4)
assert(isnumeric(y),'Input y must be numeric.') 
assert(license('test','statistics_toolbox')==1,'Sorry, the mann_kendall function requires Matlab''s Statistics Toolbox.') 

%% Set defaults: 

alpha = 0.05; 

%% Input parsing: 

% Dimension of operation: 
tmp = strncmpi(varargin,'dimension',3); 
if any(tmp)
   dim = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
   assert(ismember(dim,[1 2 3]),'Error: mann_kendall can only operate along dimension 1, 2, or 3.')
else
   if ndims(y)==3 % if it's a 3D matrix, operate down dim 3
      dim = 3; 
   else
      dim = find(size(y)>1,1,'first'); % if it's 2D, operate down the first nonsingleton dimension. 
   end
end

% Determine user-defined alpha: 
tmp = cellfun(@isscalar,varargin);
if any(tmp)
   alpha = varargin{1}; 
   assert(isscalar(alpha),'Input Error: alpha must be a scalar value between 0 and 1.') 
   assert(alpha>=0,'Error: alpha cannot be less than zero.') 
   assert(alpha<=1,'Error: alpha cannot be greater than one.') 
   assert(length(varargin)==1,'Unrecognized inputs.') 
end

%% Reshape:
      
switch dim
   case 1
      % do nothing
   case 2
      y = permute(y,[2 1]); 
   case 3
      mask = all(isfinite(y),3); 
      y = cube2rect(y,mask); 
   otherwise
      error('There''s really no way we should have gotten here.') 
end

n = size(y,1); % number of timesteps 

%% Do statistics: 

S = zeros(1,size(y,2)); 
for i=1:n-1
   for j= i+1:n 
      S = S + sign(y(j,:)-y(i,:)); 
   end
end

VarS=(n*(n-1)*(2*n+5))/18;
StdS=sqrt(VarS); 

% Preallocate Z: ( ties are not considered )
Z = NaN(size(S)); 

% Get indices where S is greater than or equal to zero: 
ind = S>=0; 

Z(ind) = ((S(ind)-1)/StdS).*(S(ind)); 
Z(~ind) = (S(~ind)+1)/StdS; 

p = 2*(1-normcdf(abs(Z),0,1)); %% two-tailed test 

h = abs(Z) > norminv(1-alpha/2,0,1);

%% Un-reshape: 

switch dim
   case 1
      % do nothing
      
   case 2
      h = ipermute(h,[2 1]); 
      if nargout>1 
         p = ipermute(p,[2 1]); 
      end
      
   case 3
      h = rect2cube(h,mask); 
      h(isnan(h)) = 0; 
      h = logical(h); 
      
      if nargout>1 
         p = rect2cube(p,mask); 
      end
      
   otherwise
      error('It''s even more confounding this time.') 
end

end