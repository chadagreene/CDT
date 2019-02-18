function idx = sam(slp40,slp65,t)
% sam calculates the Southern Annular Mode index from sea-level
% pressures based on the SAM definition proposed by Marshall 2003.
% 
%% Syntax 
% 
%  idx = sam(slp40,slp65,t) 
% 
%% Description 
% 
% idx = sam(slp40,slp65,t) calculates the Southern Annular Mode index 
% from two time series of sea-level pressures at two latitudes (40S and 65S) 
% and their corresponding times t. 
% 
%% Examples
% For examples and a description of methods, type 
% 
%   cdt sam
%
%% Reference
% 
% Marshall, G. J., 2003: Trends in the Southern Annular Mode 
% from observations and reanalyses. J. Clim., 16, 4134-4143.
% 
%% Author Info
% This function was written by Kaustubh Thirumalai of the University of 
% Arizona, January 2019.
% http://www.kaustubh.info
% 
% See also: enso and nam. 

%% Initial error checks: 

narginchk(3,3) 
assert(ismember(length(t),size(slp40))==1,'Error: length of t must match dimensions of slp.') 
assert(isequal(size(slp40),size(slp65)),'Error: length of slp series must be of equal length.') 

%% Parse inputs: 

% Convert time from datetime, datestr, or datevec:
t = datenum(t); % (If it's already datenum, nothing changes.)

assert(min(t)<=datenum(1971,1,1),'Error: The time series must begin on or before Jan 1, 1971 to allow for baseline calculation.') 
assert(max(t)>=datenum(2001,1,1),'Error: The time series must end on or after Jan 1, 2001 to allow for baseline calculation.') 

%% Calculate SAM index: 

% Remove climatology: 
slp40 = slp40 - climatology(slp40,t,'full'); 
slp65 = slp65 - climatology(slp65,t,'full'); 

% Normalize zonal mean sea-level pressures:
nslp40 = standardize(slp40); 
nslp65 = standardize(slp65); 

% Get baseline indices: 
ind = t>=datenum(1971,1,1) & t<datenum(2001,1,1); 

% Calculate anomalies relative to baseline: 
anom40 = nslp40 - mean(nslp40(ind)); 
anom65 = nslp65 - mean(nslp40(ind)); 

% The SAM index is now the difference of the two normalized anomalies: 
idx = anom40 - anom65; 

end

