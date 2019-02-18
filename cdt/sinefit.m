function [ft,rmse] = sinefit(t,y,varargin) 
% sinefit fits a least-squares estimate of a sinusoid to time series data
% that have a periodicity of 1 year. 
% 
%% Syntax
% 
%  ft = sinefit(t,y) 
%  ft = sinefit(t,y,'terms',TermOption) 
%  [ft,rmse] = sinefit(...)
% 
%% Description 
% 
% ft = sinefit(t,y) fits a sinusoid with a periodicity of 1 year to input
% data y collected at times t. Input times can be in datenum, datetime, or 
% datestr format, and do not need to be sampled at regular intervals. The output
% ft contains the coefficients of the terms in the calculation described below.
% 
% ft = sinefit(t,y,'terms',TermOption) specifies which terms are calculated
% in the sinusoid fit. TermOption can be 2, 3, 4, or 5:
% 
%   2: ft = [A doy_max] where A is the amplitude of the sinusoid, and doy_max 
%      is the day of year corresponding to the maximum value of the sinusoid. 
%      The default TermOption is 2.
%   3: ft = [A doy_max C] also estimates C, a constant offset. Solving for  
%      adds processing time, so you may prefer to estimate C on your own simply
%      as the mean of the input y. However, if you can't assume C=mean(y), you
%      may prefer this three-term solution. 
%   4: ft = [A doy_max C trend] also estimates a linear trend over the entire
%      time series in units of y per year. Again, simultaneously solving for 
%      four terms will be much more computationally expensive than solving for
%      two yerms, so you may prefer to estimate the trend on your own with 
%      polyfit, then calculate the two-term sine fit on your detrended data. 
%   5: ft = [A doy_max C trend quadratic_term] also includes a quadratic term
%      in the solution, but this is experimental for now, because fitting a 
%      polynomial to dates referenced to year zero tends to be scaled poorly.
% 
% [ft,rmse] = sinefit(...) returns the root-mean-square error of the residuals 
% of y after removing the sinusoidal fit. This is one measure of how well the 
% sinusoid fits the data, but for a more in-depth understanding of the uncertainties, 
% including uncertainties in the timing, see sinefit_bootstrap. 
%
%% Example: 
% For examples, type 
% 
%   cdt sinefit 
% 
%% Author Info
% Written by Chad A. Greene, July 2018. 
% 
% See also sineval, sinefit_bootstrap, and polyfit. 

%% Error checks: 
% 
narginchk(2,4) 
if (max(t)-min(t))<365
   warning('Fitting a sinusoid to less than one year of data. This might not be what you want.') 
end

assert(isvector(t)==1,'Error: t must be a vector.') 
assert(isvector(y)==1,'Error: y must be a vector.')
assert(numel(t)==numel(y),'Error: Dimensions of t and y must match.') 

%% input parsing

Nterms = 2; % 2 term equation by default
if nargin>2
   tmp = strncmpi(varargin,'terms',3); 
   if any(tmp)
      Nterms = varargin{find(tmp)+1}; 
      assert(isscalar(Nterms)==1,'Error: numvals must be 2, 3, 4, or maybe 5.') 
   end
end

%% Ready the data 

% Convert time vector to decimal year: 
yr = doy(t,'decimalyear'); 

% Define the N-term equation we want to solve:        
switch Nterms 
   case 2 
      f = @(A,t) A(1)*sin((yr + A(2))*2*pi); 
   case 3 
      f = @(A,t) A(1)*sin((yr + A(2))*2*pi) + A(3); 
   case 4 
      f = @(A,t) A(1)*sin((yr + A(2))*2*pi) + A(3) + A(4)*yr; 
   case 5 
      f = @(A,t) A(1)*sin((yr + A(2))*2*pi) + A(3) + A(4)*yr + A(5)*yr.^2; 
   otherwise
      error('This function can only solve for 2, 3, or 4 terms. But given the error check above, I''m not even sure how we got here.') 
end

%% Solve the equation

% Set some options for fminsearch:        
opts = optimset('Display','off');

% Define a sum-of-squares function that figures out the mismatch between data and the fit: 
fcn = @(A) sum((f(A,t) - y).^2); 
      
switch Nterms    
   case 2
      ft = fminsearch(fcn,[rms(y)*2/sqrt(2) -0.5],opts); 
   case 3 
      ft = fminsearch(fcn,[rms(y)*2/sqrt(2) -0.5 mean(y)],opts); 
   case 4
      pv = polyfit(yr,y,1); 
      ft = fminsearch(fcn,[rms(detrend(y))*2/sqrt(2) -0.5 pv(2) pv(1)],opts); 
   case 5
      pv = polyfit(yr,y,2); 
      ft = fminsearch(fcn,[rms(detrend(y))*2/sqrt(2) -0.5 pv(3) pv(2) pv(1)],opts); 
   otherwise
      error('I am totally dumbfounded about how we could have possibly gotten here.') 
end

%% Package up the outputs

% Standardize amplitude and phase terms: 
if ft(1)<0 
   ft(1) = -ft(1);  % ensures a positive amplitude
   ft(2) = ft(2)+.5;% but also means we'll have to change the phase by half a cycle. 
end

% Convert the phase term (decimal years) into something meaningful (day of year corresponding to max of sine wave):
ft(2) = 365.24*(mod(0.25 - ft(2),1)); 

% Estimate errors: 
if nargout==2
   rmse = rms(y - sineval(ft,t)); 
end

end


function n = doy(t,option) 
% doy returns the Julian day of year. 
% 
%% Syntax
% 
%  n = doy(t) 
%  n = doy(t,'decimalyear') 
%  n = doy(t,'remdecimalyear') 
% 
%% Description 
% 
% n = doy(t) gives the day of year (from 1 to 366.999) corresponding to the date(s) 
% given by t. Input dates can be datenum, datetime, or string format. 
% 
% n = doy(t,'decimalyear') gives the year in decimal form of input date t. It accounts 
% for leap years, so the decimal value for a given date will depend on whether it's a leap
% year. For example, July 4th of 2016 (a leap year) is 2016.5082 whereas July 4th of 2017
% (not a leap year) is 2017.5068. 
% 
% n = doy(t,'remdecimalyear') returns only the remainder of the decimal year, and is always
% in the range 0 to 1. 
% 
%% Examples: 
% doy('july 4, 2017')
% ans =
%         185.00
%         
% doy(datenum('july 4, 2017'))
% ans =
%         185.00
%         
% doy(datetime('july 4, 2017'))
% ans =
%         185.00
%         
% doy('july 4, 2017','decimalyear')
% ans =
%        2017.51
%        
% doy('july 4, 2017','remdecimalyear')
% ans =
%           0.51
%           
%% Author Info: 
% This function was written by Chad A. Greene of the University of Texas Institute for 
% Geophysics (UTIG), June 2017. 
% 
% See also datenum, datevec, and datestr. 

%% Error checks: 

narginchk(1,2)

%% Parse inputs: 

remdec = false; 
decyear = false; 

if nargin>1
   switch lower(option(1:3))
      case 'dec'
         remdec = true; 
         decyear = true; 
      case 'rem'
         remdec = true; 
      otherwise
         error('Unrecognized inputs.') 
   end
end

%% Perform mathematics: 

% If the input is a string, convert it to datenum: 
t = datenum(t); 

% Get the year of each input date: 
[yr,~,~] = datevec(t); 

% Datenum corresponding to the strike of midnight at New Years: 
tnye = datenum(yr,0,0,0,0,0); 

% The day of the year is the date minus the datenum of the New Year: 
n = t - tnye; 

if remdec 
   
   % Datenum of the ceiling new years: 
   tmax = datenum(yr+1,0,0,0,0,0); 
     
   % The year fraction is the day of year out of the total number of days in the year: 
   n = n./(tmax-tnye); 
   
   if decyear
      n = n+yr; 
   end
   
end

end
