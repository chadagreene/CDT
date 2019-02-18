function f = coriolisf(lat,rot)
% coriolisf returns the Coriolis frequency for any given latitude(s). 
% The Coriolis frequency is sometimes called the Coriolis parameter or the 
% Coriolis coefficient. 
% 
%% Syntax
% 
%  f = coriolisf(lat) 
%  f = coriolisf(lat,rot) 
% 
%% Description
% 
% f = coriolisf(lat) returns Earth's Coriolis frequency for any locations(s) 
% at latitude(s) lat. By default, the Coriolis frequency is given in units of
% rad/s. 
% 
% f = coriolisf(lat,rot) specifies a rate of rotation rot. By default, rot
% is Earth's present-day rate of rotation 7.2921 x 10^-5 rad/s, but a different
% rate may be specified to model Earth at a different time, other celestial 
% bodies, or the Coriolis parameter in a different unit of frequency. 
% 
%% Examples 
% For examples type: 
% 
%   cdt coriolisf
% 
%% Author Info
% Written by Chad A. Greene of the University of Texas Institute for
% Geophysics (UTIG). July 2014. http://www.chadagreene.com
% 
% See also: rossby_radius and ekman. 

%% Error checks: 

narginchk(1,2) 
assert(max(abs(lat(:)))<=90,'Latitude value(s) out of realistic bounds. Check inputs and try again.')

%% Parse inputs: 

if nargin==1
   rot = 7.2921e-5; 
else
   assert(isnumeric(rot),'Error: rotation rate rot must be numeric.')
end

%% Do some really complicated mathematics: 

f = 2*rot.*sind(lat); 

end

