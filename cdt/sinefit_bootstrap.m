function [ft,rmse,Nsamp] = sinefit_bootstrap(t,y,varargin)
% sinefit_bootstrap performs a bootstrap analysis on the parameters
% estimated by the function sinefit. Bootstrapping means applying the 
% sinefit function to a bunch of subsamples of the data, then analyzing
% the distributions of solutions for each parameter to see how robust
% they are. 
% 
%% Syntax
% 
%  ft = sinefit_bootstrap(t,y)
%  ft = sinefit_bootstrap(...,'terms',TermOption) 
%  ft = sinefit_bootstrap(...,'nboot',nboot)
%  [ft,rmse,Nsamp] = sinefit_bootstrap(...)
% 
%% Description 
% 
% ft = sinefit_bootstrap(t,y) fits a 2-term (amplitude and phase) sinusoid 
% to 1000 random subsamples of the time series t,y. The output ft is a 1000x2
% matrix containinng all 1000 solutions for the amplitude and phase, respectively. 
% See sinefit for a complete description of inputs and outputs. 
%
% ft = sinefit_bootstrap(...,'terms',TermOption) specifies which terms are calculated
% in the sinusoid fit. Default is 2 because more terms can be computationally slow! 
% TermOption can be 2, 3, 4, or 5:
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
% ft = sinefit_bootstrap(...,'nboot',nboot) specifies the number of bootstrap samples. 
% Default is 1000, meaning sinusoids are fit to 1000 random subsamples of the data.  
%
% [ft,rmse,Nsamp] = sinefit_bootstrap(...) also returns distributions of root-mean-square
% error of residuals (how well the sinusoids fit the data) and Nsamp, the number
% of datapoints contributing to each subsample of the data. 
% 
%% Examples 
% For examples, type 
% 
%   cdt sinefit_bootstrap
% 
%% Author Info
% Written by Chad A. Greene, July 2018. 
% 
% See also sinefit and sineval. 

%% Error checks: 
% 
narginchk(2,6) 
if (max(t)-min(t))<365
   warning('Fitting a sinusoid to less than one year of data. This might not be what you want.') 
end

assert(isvector(t)==1,'Error: t must be a vector.') 
assert(isvector(y)==1,'Error: y must be a vector.')
assert(numel(t)==numel(y),'Error: Dimensions of t and y must match.') 

%% input parsing

% Set defaults:
Nterms = 2;
Nboot = 1000; 

if nargin>2
   tmp = strncmpi(varargin,'terms',3); 
   if any(tmp)
      Nterms = varargin{find(tmp)+1}; 
      assert(isscalar(Nterms)==1,'Error: numvals must be 2, 3, or 4.') 
   end
   
   tmp = strncmpi(varargin,'nboot',3); 
   if any(tmp)
      Nboot = varargin{find(tmp)+1}; 
      assert(isscalar(Nboot)==1,'Error: nboot must be a scalar value greater than zero.') 
      assert(Nboot>0,'Error: nboot must be a scalar value greater than zero.') 
   end
end

%% Perform bootstrapping

% Preallocate the outputs: 
ft = NaN(Nboot,Nterms); 
rmse = NaN(Nboot,1); 
Nsamp = NaN(Nboot,1); 

% Loop through Nboot samples: 
for k = 1:Nboot 

   % Generate random indices of a subsample of the input data:
   ind = randi(length(t),[1 length(t)]); 
   
   % Count how many unique values are in this subsample:
   Nsamp(k) = length(unique(ind)); 
   
   % Fit a sinusoid to the subsample of data: 
   [ft(k,:),rmse(k)] = sinefit(t(ind),y(ind),'terms',Nterms);
   
end


end
