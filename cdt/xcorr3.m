function [r,rmax,lags] = xcorr3(A,ref,varargin) 
% xcorr3 gives a map of correlation coefficients between grid cells of a 3D spatiotemporal dataset 
% and a reference time series.  This function is similar to xcov3.
% 
%% Syntax
% 
%  r = xcorr3(A,ref)
%  r = xcorr3(...,'detrend')
%  r = xcorr3(...,'maxlag',maxlag)
%  r = xcorr3(...,'mask',mask)
%  [r,rmax,lags] = xcorr3(...)
% 
%% Description
% 
% r = xcorr3(A,ref) gives a 2D correlation map r, which has dimensions corresponding to dimensions 1 and 2 of A. The 3D matrix
% A is assumed to have spatial dimensions 1 and 3 which may correspond to x and y, lat and lon, lon and lat, etc. The third
% dimension of A is assumed to correspond to time.  The array ref is a time series reference signal against which you're comparing
% each grid cell of A. Length of ref must match the third dimension of A. 
% 
% r = xcorr3(...,'detrend') removes the mean and linear trend from each time series before calculating correlation. This is 
% recommended for any type of analysis where data values in A or the range of values in ref are not centered on zero. 
% 
% r = xcorr3(...,'maxlag',maxlag) specifies maximum lag as an integer scalar number of time steps. If you specify maxlag, the 
% returned cross-correlation sequence ranges from -maxlag to maxlag. Default maxlag is N-1 time steps.
%
% r = xcorr3(...,'mask',mask) only performs analysis on true grid cells in the mask whose dimensions correspond to the first 
% two (spatial) dimensions of A. The option to apply a mask is intended to minimize processing time if A is large.  By default, 
% *any* NaN value in A sets the corresponding grid cell in the default mask to false. 
% 
% [r,rmax,lags] = xcorr3(...) returns the zero-phase correlation coefficient r, the maximum correlation coefficient rmax, and
% time lags corresponding to maximum correlation.   A negative |lag| value implies the local time series happens _after_ the reference 
% signal.  A positive |lag| indicates the local phenomena leads the reference signal. 
% 
%% Examples
% For detailed examples with pictures, simply type 
% 
%  cdt xcorr3
% 
%% Author Info 
% This function was written by Chad A. Greene of the University of Texas at Austin
% Institute for Geophysics (UTIG), February 2017. 
% http://www.chadagreene.com
% 
% See also: xcorr, xcov3, and cov3. 

%% Error checks: 

narginchk(2,inf) 
assert(license('test','signal_toolbox')==1,'Error: the xcorr3 function requires Matlab''s Signal Processing Toolbox.') 
assert(ndims(A)==3,'Input error: A must be 3 dimensional.') 
assert(isvector(ref)==1,'Input error: Reference signal must be a vector.') 
assert(size(A,3)==length(ref),'Input error: The length of the reference signal must correspond to the third dimension of A.')

%% Set defaults: 

mask = ~any(isnan(A),3); 
if nargout==1
   maxlag = 0; 
else
   maxlag = size(A,3) - 1;
end
detrend_inputs = false; 

%% Input parsing: 

if nargin>2
   
   % Detrend the data first? 
   if any(strcmpi(varargin,'detrend')); 
      detrend_inputs = true; 
   end
   
   % Maximum lags?  
   tmp = strncmpi(varargin,'maxlag',3); 
   if any(tmp) 
      maxlag = varargin{find(tmp)+1}; 
      assert(isscalar(maxlag)==1,'Input error: maxlag must be a scalar.') 
      assert(rem(maxlag,1)==0,'Input error: maxlag must be an integer.') 
   end
   
   % Has the user defined a mask? 
   tmp = strcmpi(varargin,'mask'); 
   if any(tmp) 
      mask = varargin{find(tmp)+1}; 
      assert(isequal(size(mask),[size(A,1) size(A,2)])==1,'Input error: Mask dimensions must match the first two dimensions of the data matrix A.') 
      assert(islogical(mask)==1,'Input error: mask must be logical.') 
   end
   
end

%% Manipulate input data: 

% Reshape
A = permute(A,[3 1 2]); 
A = reshape(A,size(A,1),size(A,2)*size(A,3)); 

% Eliminate masked-out values: 
A = A(:,mask(:)); 

% Remove mean and linear trend if desired: 
if detrend_inputs
   ref = detrend(ref(:)); 
   A = detrend(A); 
else 
   ref = ref(:); 
end

%% Calculate xcorr: 

% Preallocate outputs: 
r0 = nan(1,size(A,2)); 
rmax_array = nan(1,size(A,2)); 
lags_all = nan(1,size(A,2)); 

% Loop through each grid cell b/c if we try to calculate xcorr with all data all at once it might break the user's computer:
for k = 1:size(A,2)
   [r_tmp,lag_tmp] = xcorr([ref A(:,k)],maxlag,'coeff'); 
   r0(k) = r_tmp(lag_tmp==0,2); 
   [rmax_array(k),ind] = max(r_tmp(:,2)); 
   lags_all(k) = lag_tmp(ind); 
end

%% Un-reshape results: 

r = nan(size(mask)); 
r(mask) = r0; 

rmax = nan(size(mask)); 
rmax(mask) = rmax_array; 

lags = nan(size(mask)); 
lags(mask) = lags_all; 

end
