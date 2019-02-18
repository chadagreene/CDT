function [tsb,Nts] = ts_normstrap(ts,varargin)
% ts_normstrap performs a bootstrap uncertainty analysis on a
% time series given an uncertainty value at each step assuming a normal
% probability distribution. Bootstrapping means estimating a value at each
% time point within particular uncertainty bounds with a given probability
% distribution. Ultimately, the goal is to generate several realizations of
% the time series and provide confidence intervals at each time step. 
% 
%% Syntax
% 
%  tsb = ts_normstrap(ts)
%  tsb = ts_normstrap(ts,e)
%  tsb = ts_normstrap(ts,E)
%  tsb = ts_normstrap(ts,'nboot',nboot)
%  [tsb,Nts] = ts_normstrap(...)
% 
%% Description 
% 
% |tsb = ts_normstrap(ts)| calculates confidence bounds for a given timeseries
% after randomly subsampling vector |ts| 1000 times at each point with a
% normal probability, assuming an uncertainty of 1 standard deviation 
% of the overall time series |ts|. The output |tbs| is a |length(ts)|x1
% matrix containg the 1 standard deviation bounds of time series |ts|.
% Note that |ts| is a vector without time dimensions as the bounds are
% returned at the points of query.
% 
% |tsb = ts_normstrap(ts,e)| specifies the uncertainty value |e| from
% which the uncertainty distribution at each step in the vector |ts| is calculated 
% and thereby overrides the default value of 1 standard deviation of |ts|.
%
% |tsb = ts_normstrap(ts,E)| specifies a vector |E| containing uncertainty
% values at each step from which the uncertainty distribution in vector
% |ts| is calculated. 
%
% |tsb = ts_normstrap(...,'nboot',nboot) specifies the number of bootstrap samples. 
% Default is 1000, meaning 1000 random time series are calculated.
%
% |[tsb,Nts] = ts_normstrap(...)| also returns the 1000 (or the specified
% number of) randomly generated time series subsampled with the specified
% uncertainty.
% 
%% Examples 
% For examples, type 
% 
%   cdt ts_normstrap
% 
%% Author Info
% Written by Kaustubh Thirumalai, February 2019 

%% Error checks: 
% 
narginchk(1,4) 
assert(isvector(ts)==1,'Error: y must be a vector.')

%% input parsing

% Set defaults:
Nboot = 1000; 
e = std(ts,'omitnan');
E = ones(length(ts),1).*e;

tmp = strncmpi(varargin,'nboot',3);
if nargin>1 && any(tmp)
    Nboot = varargin{find(tmp)+1};
	assert(isscalar(Nboot)==1,'Error: nboot must be a scalar value greater than zero.')
	assert(Nboot>0,'Error: nboot must be a scalar value greater than zero.')
    if nargin > 3
        if isscalar(varargin{1})
            e = varargin{1};
            E = ones(length(ts),1).*e;
        else 
            E = varargin{1};
            assert(length(E)==length(ts),'Error: E must be equal in length to the time series ts')
        end
    end        
elseif nargin>1
    if isscalar(varargin{1})
        e = varargin{1};
        E = ones(length(ts),1).*e;
    else
        E = varargin{1};
        assert(length(E)==length(ts),'Error: E must be equal in length to the time series ts')
    end
end

%% Bootstrap

% Generate normally distributed uncertainty distribution
Udis = E.*randn(length(ts),Nboot);

% Generate distribution of time series
Nts = ts + Udis;

% Find 1-sigma confidence intervals
tsb = std(Nts,0,2,'omitnan');

end