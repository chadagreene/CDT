function idx = nao(slpA,slpB,t)
% nao calculates the North Atlantic Oscillation index from sea-level
% pressures based on the definition proposed by Hurrell, 1995. For all
% practical purposes the NAO index is equivalent to the Arctic Oscillation
% as well as the North Annular Mode. For more information see this
% introduction to Annular Modes by David Thompson at NCAR
% http://www.atmos.colostate.edu/~davet/ao/introduction.html.
% 
%% Syntax 
% 
%  idx = nao(slpA,slpB,t) 
% 
%% Description 
% 
% idx = nao(slp40,slp65,t) calculates the North Atlantic Oscillation index 
% from two time series of sea-level pressures at two stations (A and B) 
% and their corresponding times t. Here, Station A (either Azores or
% Lisbon or Gibraltar) is usually south of Station B (Iceland).
% 
%% Examples
% For examples and a description of methods, type 
% 
%   cdt nao
%
%% Reference
% 
% Hurrell, J.W., 1995: Decadal Trends in the North Atlantic Oscillation: 
% Regional Temperatures and Precipitation. Science: Vol. 269, pp.676-679
% 
% Jones, P. D. et al., 1997: Extension to the North Atlantic oscillation 
% using early instrumental pressure observations from Gibraltar and 
% south-west Iceland. Int. J. Climatol., 17: 1433-1450.
%
%% Author Info
% This function was written by Kaustubh Thirumalai of the University of 
% Arizona, March 2019.
% http://www.kaustubh.info
% 
% See also: enso and sam. 

%% Initial error checks: 

narginchk(3,3) 
assert(ismember(length(t),size(slpA))==1,'Error: length of t must match dimensions of slp.') 
assert(isequal(size(slpA),size(slpB)),'Error: length of slp series must be of equal length.') 

%% Parse inputs: 

% Convert time from datetime, datestr, or datevec:
t = datenum(t); % (If it's already datenum, nothing changes.)

%% Calculate NAO index: 
% The climatology according to Hurrell, 1995 or Jones et al. 1997 is to
% calculate anomalies wrt to the full baseline.

% Remove climatology: 
slpA = slpA - climatology(slpA,t,'full','omitnan'); 
slpB = slpB - climatology(slpB,t,'full','omitnan'); 

% Normalize zonal mean sea-level pressures:
nslpA = standardize(slpA); 
nslpB = standardize(slpB); 

% Calculate anomalies relative to baseline: 
anomA = nslpA - mean(nslpA,'omitnan'); 
anomB = nslpB - mean(nslpB,'omitnan'); 

% The NAO index is now the difference of the two normalized anomalies: 
idx = anomA - anomB; 

end

