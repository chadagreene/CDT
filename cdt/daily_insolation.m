function [Fsw,ecc,obliquity,long_perh] = daily_insolation(kyear,lat,day,day_type,varargin)
% daily_insolation computes daily average insolation as a function of day and latitude at
% any point during the past 5 million years.
% 
% This function is from Ian Eisenman and Peter Huybers (see the reference
% below). 
% 
%% Syntax 
%  
%  Fsw = daily_insolation(kyear,lat,day)
%  Fsw = daily_insolation(kyear,lat,day,day_type)
%  Fsw = daily_insolation(kyear,lat,day,day_type,'constant',So)
%  [Fsw, ecc, obliquity, long_perh] = daily_insolation(...)
% 
%% Description
% 
% Fsw = daily_insolation(kyear,lat,day) gives the daily average insolation
% in W/m^2 at latitude(s) lat on specified day(s) of the year (as given by the doy
% function) for the times kyear, which are thousands of years before
% present. For example, use kyear = +3000, to indicate 3 million years
% before present. Maximum allowed value of kyear is 5000. 
% 
% Fsw = daily_insolation(kyear,lat,day,day_type) specifies an optional day
% type as 1 (default) or 2. The default option 1 specifies days in the
% range 1 to 365.24, where day 1 is January first and the vernal equinox
% always occurs on day 80. Option 2 specifies day input as solar longitude
% in the range 0 to 360 degrees. Solar longitude is the angle of the Earth's 
% orbit measured from spring equinox (21 March). Note that calendar days and
% solar longitude are not linearly related because, by Kepler's Second Law, Earth's
% angular velocity varies according to its distance from the sun. If day_type 
% is negative, kyear is taken to be a 3 element array containing [eccentricity,
% obliquity, and longitude of perihelion].
%  
% Fsw = daily_insolation(kyear,lat,day,day_type,'constant',So) specfies a
% solar constant So. Default So is 1365 W/m^2.  
% 
% [Fsw, ecc, obliquity, long_perh] = daily_insolation(...) also returns the
% orbital eccentricity, obliquity, and longitude of perihelion (precession angle).
%
%% Detailed description of calculation:
% Values for eccentricity, obliquity, and longitude of perihelion for the
% past 5 Myr are taken from Berger and Loutre 1991 (data from
% ncdc.noaa.gov). If using calendar days, solar longitude is found using an
% approximate solution to the differential equation representing conservation
% of angular momentum (Kepler's Second Law).  Given the orbital parameters
% and solar longitude, daily average insolation is calculated exactly
% following Berger 1978.
%
%% References: 
% 
% Berger A. and Loutre M.F. (1991). Insolation values for the climate of
%  the last 10 million years. Quaternary Science Reviews, 10(4), 297-317.
% Berger A. (1978). Long-term variations of daily insolation and
%  Quaternary climatic changes. Journal of Atmospheric Science, 35(12),
%  2362-2367.
%
%% Authors:
% Ian Eisenman and Peter Huybers, Harvard University, August 2006
% eisenman@fas.harvard.edu
% This file is available online at
% http://deas.harvard.edu/~eisenman/downloads
%

%% Error checks and input parsing:

narginchk(3,6)
assert(max(kyear(:))<=5000,'Error: Maximum allowable kyear is 5000, meaning 5000000 years before present.')
assert(min(kyear(:))>=0,'Error: Minimum allowable kyear is 0. Use positive values for dates in the past.') 
assert(max(abs(lat(:)))<=90,'Error: All latitudes must be in the range -90 to 90.') 
assert(max(day(:))<=366,'Error: day range out of bounds.') 
assert(min(day(:))>0,'Error: day range out of bounds.') 

if nargin<4
   day_type=1; 
else
   assert(isscalar(day_type),'Error: day_type must be 1 or 2.') 
   assert(max(abs(day_type))<=2,'Error: Day type must be 1 or 2.') 
end

tmp = strncmpi(varargin,'constant',4); 
if any(tmp)
   So = varargin{find(tmp)+1}; 
else
   So = 1365; % solar constant (W/m^2)
end

%% Get orbital parameters: 

if day_type>=0
    [ecc,epsilon,omega]=orbital_parameters(kyear); % function is below in this file
else
    if length(kyear)~=3
        disp('Error: expect 3-element kyear argument for day_type<0'), Fsw=nan; inso; return
    end
    ecc=kyear(1);
    epsilon=kyear(2) * pi/180;
    omega=kyear(3) * pi/180;
end

% For output of orbital parameters
obliquity=epsilon*180/pi;
long_perh=omega*180/pi;

% === Calculate insolation ===
lat=lat*pi/180; % latitude
% lambda (or solar longitude) is the angular distance along Earth's orbit measured from spring equinox (21 March)
switch abs(day_type)
   case 1 % calendar days
      % estimate lambda from calendar day using an approximation from Berger 1978 section 3
      delta_lambda_m=(day-80)*2*pi/365.2422;
      beta=(1-ecc.^2).^(1/2);
      lambda_m0=-2*( (1/2*ecc+1/8*ecc.^3).*(1+beta).*sin(-omega)-...
         1/4*ecc.^2.*(1/2+beta).*sin(-2*omega)+1/8*ecc.^3.*(1/3+beta).*(sin(-3*omega)) );
      lambda_m=lambda_m0+delta_lambda_m;
      lambda=lambda_m+(2*ecc-1/4*ecc.^3).*sin(lambda_m-omega)+...
         (5/4)*ecc.^2.*sin(2*(lambda_m-omega))+(13/12)*ecc.^3.*sin(3*(lambda_m-omega));
   case 2 %solar longitude (1-360)
    lambda=day*2*pi/360; % lambda=0 for spring equinox
   otherwise
    error('Error: invalid day_type')
end

delta=asin(sin(epsilon).*sin(lambda)); % declination of the sun
Ho=acos(-tan(lat).*tan(delta)); % hour angle at sunrise/sunset

% no sunrise or no sunset: Berger 1978 eqn (8),(9)
Ho( ( abs(lat) >= pi/2 - abs(delta) ) & ( lat.*delta > 0 ) )=pi;
Ho( ( abs(lat) >= pi/2 - abs(delta) ) & ( lat.*delta <= 0 ) )=0;

% Insolation: Berger 1978 eq (10)
Fsw=So/pi*(1+ecc.*cos(lambda-omega)).^2 ./ ...
    (1-ecc.^2).^2 .* ...
    ( Ho.*sin(lat).*sin(delta) + cos(lat).*cos(delta).*sin(Ho) );

end

%% Subfunction

% === Calculate orbital parameters ===
function [ecc,epsilon,omega] = orbital_parameters(kyear)
% === Load orbital parameters (given each kyr for 0-5Mya) ===
% this .mat file contains the matrix m with data from Berger and Loutre 1991
OP = load('orbital_parameter_data.mat'); 
m = OP.m; 

kyear0=-m(:,1); % kyears before present for data (kyear0>=0);
ecc0=m(:,2); % eccentricity
% add 180 degrees to omega (see lambda definition, Berger 1978 Appendix)
omega0=m(:,3)+180; % longitude of perihelion (precession angle)
omega0=unwrap(omega0*pi/180)*180/pi; % remove discontinuities (360 degree jumps)
epsilon0=m(:,4); % obliquity angle

% Interpolate to requested dates
ecc=spline(kyear0,ecc0,kyear); % eccs means array of ecc values
omega=spline(kyear0,omega0,kyear) * pi/180;
epsilon=spline(kyear0,epsilon0,kyear) * pi/180;
end