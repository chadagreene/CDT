function [tr,p] = trend(y,Fs_or_t,varargin)
% trend calculates the linear trend of a data series by least squares. Data
% do not need to be equally spaced in time. 
%
%% Syntax
% 
%  tr = trend(y) 
%  tr = trend(y,Fs) 
%  tr = trend(y,t) 
%  tr = trend(...,'dim',dim)
%  tr = trend(...,'omitnan')
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
% tr = trend(...,'omitnan') solves the least squares trend, even where not all
% values of y are finite. This option may be somewhat slow if many grid cells 
% contain some, but not all, NaNs. A word of caution when using the 'omitnan'
% option: the trend is calculated only over the timespan in which finite data
% exist. Therefore, for example, if some grid cells contain finite data only
% for one year of a 10 year record, it is possible that the apparent "10 year" trend 
% reported by the trend function could actually be an aliased signal. Accordingly, 
% the 'omitnan' option should only be used when NaNs are scattered somewhat 
% evenly throughout the temporal record. 
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

tmp = strncmpi(varargin,'omitnan',4); 
if any(tmp)
   omitnan = true; 
   varargin = varargin(~tmp); 
else
   omitnan = false;
end

% Dimension of operation: 
tmp = strncmpi(varargin,'dimension',3); 
if any(tmp)
   dim = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
   assert(ismember(dim,[1 2 3]),'Error: trend can only operate along dimension 1, 2, or 3.')
else
   if ndims(y)==3 % if it's a 3D matrix, operate down dim 3
      dim = 3; 
   else
      dim = find(size(y)>1,1,'first'); % if it's 2D, operate down the first nonsingleton dimension. 
   end
end

%% Build or reshape inputs as needed

% Did the user declare a sampling rate or a time array?
if isscalar(Fs_or_t)
   t = 0:1/Fs_or_t:(size(y,dim)-1)/Fs_or_t; % for the case where Fs_or_t is declared as sampling frequency.   
else
   t = Fs_or_t; 
end

% Columnate: 
t = t(:); 

switch dim
   case 1
      % do nothing
   case 2
      y = permute(y,[2 1]); 
   case 3
      if omitnan
         mask = sum(isfinite(y),3)>1; 
      else
         mask = all(isfinite(y),3); 
      end
      y = cube2rect(y,mask); 
   otherwise
      error('The trend function only works on 1D, 2D, or 3D matrices.') 
end

%% Compute trend
% (It's the slope of the least squares fit)

assert(isequal(size(y,1),length(t)),'Dimension mismatch: length of t must match the size of y along which the trend is being calculated. Specify a different dimension?')
 

coefficients = [t ones(size(t))]\y; 

% Deal with spurious NaNs: 
if omitnan
   % Determine which elements of the y data are finite: 
   isf = isfinite(y); 
   
   % Which columns of data (or grid cells) contain some NaNs, but not all NaNs?   
   col = find(sum(isf)>1 & sum(isf)<length(t)); 
   
   % Loop through the columns (each a grid cell) that we have any hope of solving: 
   for k = 1:length(col)
      % For this grid cell, which indices are finite? 
      ind = isf(:,col(k)); 
      
      % Solve least squares for this grid cell: 
      tmp = [t(ind) ones(size(t(ind)))]\y(ind,col(k)); 
      
      % Fill in the missing value in the coefficients matrix: 
      coefficients(1,col(k)) = tmp(1); 
      
   end
end

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
   [~,p] = corr(y,t,varargin{:});    
   
   % Deal with spurious NaNs: 
   if omitnan
      % Loop through the columns (each a grid cell) that we have any hope of solving: 
      % (we've already figured out isf and col above)
      for k = 1:length(col)
         % For this grid cell, which indices are finite? 
         ind = isf(:,col(k)); 

         % Solve p for this grid cell: 
         [~,tmp] = corr(y(ind,col(k)),t(ind),varargin{:}); 

         % Fill in the missing value in the p array: 
         p(col(k)) = tmp; 
      end
   end

   
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

