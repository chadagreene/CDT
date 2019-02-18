function Ads = deseason(A,t,varargin) 
% deseason removes the seasonal (aka annual) cycle of variability from a time series. 
% 
%% Syntax 
% 
%  Ads = deseason(A,t) 
%  Ads = deseason(...,'daily')  
%  Ads = deseason(...,'monthly') 
%  Ads = deseason(...,'detrend',DetrendOption) 
%  Ads = deseason(...,'dim',dimension) 
% 
%% Description 
% 
% Ads = deseason(A,t) gives the typical seasonal (aka annual) cycle of the time series A corresponding
% to times t in datenum format. If t is daily, outputs ts is 1 to 366 and Ads will contain average values
% for each of the 366 days of the year. If inputs are monthly, ts is 1:12 and Ads will contain average values
% for each of the 12 months of the year. 
%
% Ads = deseason(...,'daily') specifies directly that inputs are daily resolution. The deseason function
% will typically figure this out automatically, but if you have large missing gaps in your data you may wish
% to ensure correct results by specifying daily. 
% 
% Ads = deseason(...,'monthly') as above, but forces monthly solution. 
%
% Ads = deseason(...,'detrend',DetrendOption) specifies a baseline relative to which seasonal anomalies are 
% determined. Options are 'linear', 'quadratic', or 'none'. By default, anomalies are calculated after 
% removing the linear least squares trend, but if, for example, warming is strongly nonlinear, you may prefer
% the 'quadratic' option. NOTE: The deseason function does NOT return detrended data. Rather, detrending is 
% only performed to determine the seasonal cycle. Default is 'linear'. 
%
% Ads = deseason(...,'dim',dimension) specifies a dimension along which to assess seasons. By default, 
% if A is 1D, seasonal cycle is returned along the nonsingleton dimension; if A is 2D, deseason is performed
% along dimension 1 (time marches down the rows); if A is 3D, deseason is performed along dimension 3. 
% 
%% Examples
% For examples, type 
% 
%   cdt deseason
%
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG), July 2017. 
% http://www.chadagreene.com
% 
% See also: season, sinefit, and climatology. 

Ads = A - season(A,t,'full',varargin{:}); 

end


