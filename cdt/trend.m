function [tr,p] = trend(A,Fs_or_t,varargin)
% trend calculates the linear trend of a data series by least squares. Data
% do not need to be equally spaced in time. 
%
%% Syntax
% 
%  tr = trend(y) 
%  tr = trend(y,Fs) 
%  tr = trend(y,t) 
%  tr = trend(...,'dim',dim)
%  [tr,p] = trend(...)
%  [tr,p] = trend(...,corrOptions)
% 
%% Description
% 
% tr = trend(y) calculates the linear trend per sample of y. 
% 
% tr = trend(y,Fs) specifies a sampling rate Fs. For example, to obtain a trend
% per year from data collected at monthly resolution, set Fs equal to 12. This
% syntax assumes all values in y are equally spaced in time. 
% 
% tr = trend(y,t) specifies a vector t relative to which the trend is calculated. 
% Each element of t corresponds to a measurement in y, and when this syntax is used, 
% times do *not* need to be equally spaced. Units of the trend are (units y)/units(t)
% so if the units of t are in days (such as datenum), multiply by 365.25 to obtain
% the trend per year. 
% 
% tr = trend(...,'dim',dim) specifies the dimension along which the trend is 
% calculated. By default, if y is a 1D array, the trend is calculated along 
% the first nonsingleton dimension of y; if y is a 2D matrix, the trend is 
% calcaulated down the rows (dimension 1) of y; if y is a 3D matrix, the 
% trend is calculated down dimension 3. 
% 
% [tr,p] = trend(...) returns the p-value of statistical significance of 
% the trend. (Requires the Statistics Toolbox)
% 
% [tr,p] = trend(...,corrOptions) specifies any optional Name-Value pair arguments
% accpted by the corr function. For example, 'Type','Kendall' specifies computing 
% Kendall's tau correlation coefficient.
% 
%% Examples
% For examples, type 
% 
%  cdt trend
% 
%% Author Info 
% Written by Chad A. Greene of the University of Texas at Austin in 2014. 
% Fully rewritten for Climate Data Toolbox in 2019.  
% 
% See also: polyfit, detrend, and detrendn. 

%% Error checks: 

if nargout>1
   assert(license('test','statistics_toolbox')==1,'Error: statistical p values and correlation coefficients require the Statistics Toolbox. The trend function can still return a trend, but try again without requesting the extra outputs.')
end

%% Input parsing: 

if nargin==1
   Fs_or_t = 1; % the default sampling frequency; 
end

if isempty(Fs_or_t)
   Fs_or_t = 1; 
end

% Dimension of operation: 
tmp = strncmpi(varargin,'dimension',3); 
if any(tmp)
   dim = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
   assert(ismember(dim,[1 2 3]),'Error: trend can only operate along dimension 1, 2, or 3.')
else
   if ndims(A)==3 % if it's a 3D matrix, operate down dim 3
      dim = 3; 
   else
      dim = find(size(A)>1,1,'first'); % if it's 2D, operate down the first nonsingleton dimension. 
   end
end

%% Build or reshape inputs as needed

% Did the user declare a sampling rate or a time array?
if isscalar(Fs_or_t)
   t = 0:1/Fs_or_t:(size(A,dim)-1)/Fs_or_t; % for the case where Fs_or_t is declared as sampling frequency.   
else
   t = Fs_or_t; 
end

% Columnate: 
t = t(:); 

switch dim
   case 1
      % do nothing
   case 2
      A = permute(A,[2 1]); 
   case 3
      mask = all(isfinite(A),3); 
      A = cube2rect(A,mask); 
   otherwise
      error('The trend function only works on 1D, 2D, or 3D matrices.') 
end


%% Compute trend
% (It's the slope of the least squares fit)

assert(isequal(size(A,1),length(t)),'Dimension mismatch: length of t must match the size of y along which the trend is being calculated. Specify a different dimension?')
 
coefficients = [t ones(size(t))]\A; 

% Un-reshape: 
switch dim
   case 1
      tr = coefficients(1,:); 
   case 2
      tr = ipermute(coefficients(1,:),[2 1]); 
   case 3
      tr = rect2cube(coefficients(1,:),mask); 
   otherwise
      error('I''m really not sure how we got here.') 
end

%% Compute correlations and statistical significance

if nargout>1
   [~,p] = corr(A,t,varargin{:});    
   
   % Un-reshape: 
   switch dim
      case 1
         p = ipermute(p,[2 1]); 
      case 2
         % do nothing
      case 3
         p = rect2cube(p',mask); 
      otherwise
         error('I''m really, *really* not sure how we got here.') 
   end
end

end

