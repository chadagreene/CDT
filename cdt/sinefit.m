function [ft,rmse] = sinefit(t,y,varargin) 
% sinefit fits a least-squares estimate of a sinusoid to time series data
% that have a periodicity of 1 year. 
% 
%% Syntax
% 
%  ft = sinefit(t,y) 
%  ft = sinefit(...,'weight',weights) 
%  ft = sinefit(...,'terms',TermOption) 
%  [ft,rmse] = sinefit(...)
% 
%% Description 
% 
% ft = sinefit(t,y) fits a sinusoid with a periodicity of 1 year to input
% data y collected at times t. Input times can be in datenum, datetime, or 
% datestr format, and do not need to be sampled at regular intervals. The output
% ft contains the coefficients of the terms in the calculation described below.
% 
% ft = sinefit(...,'weight',w) applies weighting to each of the observations
% y. For example, if formal errors err are associated with y, you might 
% let w = 1./err.^2. By default, w = ones(size(y)). 
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
%      time series in units of y per year. 
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
% Rewritten May 2019 for a more efficient least squares method that relies
% on simple trig identities rather than the previous, slower method which 
% found the best match via fminsearch. Also added option for including weights. 
% 
% See also sineval, sinefit_bootstrap, and polyfit. 

%% Error checks: 
% 
narginchk(2,6) 
if (max(t)-min(t))<365
   warning('Fitting a sinusoid to less than one year of data. This might not be what you want.') 
end

assert(isvector(t)==1,'Error: t must be a vector.') 
%assert(isvector(y)==1,'Error: y must be a vector.')
%assert(numel(t)==numel(y),'Error: Dimensions of t and y must match.') 

%% input parsing

Nterms = 2; % 2 term equation by default
w = ones(size(y)); % equal weighting by default. 
omitnan = false; 

if nargin>2
   tmp = strncmpi(varargin,'terms',3); 
   if any(tmp)
      Nterms = varargin{find(tmp)+1}; 
      assert(isscalar(Nterms),'Error: numvals must be 2, 3, 4, or maybe 5.') 
   end
   
   tmp = strncmpi(varargin,'weights',3); 
   if any(tmp)
      w = varargin{find(tmp)+1}; 
      assert(isequal(size(w),size(y)),'Error; Dimensions of weights must match the dimensions of y.') 
      assert(isvector(y),'Error: weights cannot be specified for input cubes.') 
   end
   
   tmp = strncmpi(varargin,'omitnan',4); 
   if any(tmp)
      omitnan = true; 
      warning('the omitnan option is not yet supported.')
   end
end

%% Ready the data 

% Columnate:
t = t(:); 

if isvector(y)
   y = y(:); 
   w = w(:); 
   
   % Trim to finite values: 
   ind = isfinite(t) & isfinite(y) & isfinite(w); 
   t = t(ind); 
   y = y(ind); 
   w = w(ind); 
end

if ndims(y)==3
   InputCube = true; 
   if omitnan
      mask = sum(isfinite(y),3)>1; 
   else
      mask = all(isfinite(y),3); 
   end
   y = cube2rect(y,mask); 
   w = 1; 
else
   InputCube = false; 
end

% Convert time vector to decimal year: 
yr = doy(t,'decimalyear'); 

%% Least squares fit: 

% Define the N-term equation we want to solve:        
switch Nterms 
   case 2 % amp,ph 
      V = [sin(2*pi*yr) cos(2*pi*yr)];
   case 3 % amp,ph and C
      V = [sin(2*pi*yr) cos(2*pi*yr) ones(size(yr))];
   case 4 % amph,ph and C and trend
      V = [sin(2*pi*yr) cos(2*pi*yr) ones(size(yr)) yr];
   case 5 % amp,ph and C and trend and quadratic
      V = [sin(2*pi*yr) cos(2*pi*yr) ones(size(yr)) yr yr.^2];
   otherwise
      error('This function can only solve for 2, 3, or 4 terms. But given the error check above, I''m not even sure how we got here.') 
end

%% Solve the equation

p = (sqrt(w).*V) \ (sqrt(w).*y);

if InputCube
   ft = NaN(size(mask,1),size(mask,2),Nterms); 
   ft(:,:,1) = rect2cube(hypot(p(1,:),p(2,:)),mask); 
   ft(:,:,2) = rect2cube(atan2(p(2,:),p(1,:)),mask); 
   ft(:,:,2) = 365.24*(mod(0.25 - ft(:,:,2)/(2*pi),1)); % converts phase to day of ear corresponding to max of sine wave.
   
   if Nterms>2
      ft(:,:,3) = rect2cube(p(3,:),mask); 
   end
   
   if Nterms>3
      ft(:,:,4) = rect2cube(p(4,:),mask); 
   end
   
   if Nterms>4
      ft(:,:,5) = rect2cube(p(5,:),mask); 
   end
else
   
   % Preallocate the fit: 
   ft = NaN(size(p))'; 

   % Populate the fit: 
   ft(1) = hypot(p(1),p(2));

   ft(2) = atan2(p(2),p(1));

   % Convert the phase term (decimal years) into something meaningful (day of year corresponding to max of sine wave):
   ft(2) = 365.24*(mod(0.25 - ft(2)/(2*pi),1)); 

   ft(3:end) = p(3:end);  
end

%% Package up the outputs

% Estimate errors: 
if nargout==2
   rmse = rms(y - sineval(ft,t)); 
end

%% Previous method via fminsearch: 
% %% Ready the data 
% 
% % Convert time vector to decimal year: 
% yr = doy(t,'decimalyear'); 
% 
% % Define the N-term equation we want to solve:        
% switch Nterms 
%    case 2 
%       f = @(A,t) A(1)*sin((yr + A(2))*2*pi); 
%    case 3 
%       f = @(A,t) A(1)*sin((yr + A(2))*2*pi) + A(3); 
%    case 4 
%       f = @(A,t) A(1)*sin((yr + A(2))*2*pi) + A(3) + A(4)*yr; 
%    case 5 
%       f = @(A,t) A(1)*sin((yr + A(2))*2*pi) + A(3) + A(4)*yr + A(5)*yr.^2; 
%    otherwise
%       error('This function can only solve for 2, 3, or 4 terms. But given the error check above, I''m not even sure how we got here.') 
% end
% 
% %% Solve the equation
% 
% % Set some options for fminsearch:        
% opts = optimset('Display','off');
% 
% % Define a sum-of-squares function that figures out the mismatch between data and the fit: 
% fcn = @(A) sum((f(A,t) - y).^2); 
%       
% switch Nterms    
%    case 2
%       ft = fminsearch(fcn,[rms(y)*2/sqrt(2) -0.5],opts); 
%    case 3 
%       ft = fminsearch(fcn,[rms(y)*2/sqrt(2) -0.5 mean(y)],opts); 
%    case 4
%       pv = polyfit(yr,y,1); 
%       ft = fminsearch(fcn,[rms(detrend(y))*2/sqrt(2) -0.5 pv(2) pv(1)],opts); 
%    case 5
%       pv = polyfit(yr,y,2); 
%       ft = fminsearch(fcn,[rms(detrend(y))*2/sqrt(2) -0.5 pv(3) pv(2) pv(1)],opts); 
%    otherwise
%       error('I am totally dumbfounded about how we could have possibly gotten here.') 
% end
% 
% %% Package up the outputs
% 
% % Standardize amplitude and phase terms: 
% if ft(1)<0 
%    ft(1) = -ft(1);  % ensures a positive amplitude
%    ft(2) = ft(2)+.5;% but also means we'll have to change the phase by half a cycle. 
% end
% 
% % Convert the phase term (decimal years) into something meaningful (day of year corresponding to max of sine wave):
% ft(2) = 365.24*(mod(0.25 - ft(2),1)); 
% 
% % Estimate errors: 
% if nargout==2
%    rmse = rms(y - sineval(ft,t)); 
% end

end

