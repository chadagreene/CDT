function P = air_pressure(h)
% air_pressure computes pressure from the baromometric forumula for a US Standard Atmosphere. 
% 
%% Syntax
% 
%  P = air_pressure(h)
% 
%% Description
%
% P = air_pressure(h) returns the pressure P in pascals corresponding to
% the heights h in geometric meters above sea level.
% 
%% Examples 
% For examples, type 
% 
%  cdt air_pressure
% 
%% Reference
% The barometric formula uses a 7 layer formula (8 layers if you include
% invalid heights above 86 km) for the 1976 US Standard Atmosphere. 
% https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19770009539_1977009539.pdf
% updated link: https://www.ngdc.noaa.gov/stp/space-weather/online-publications/miscellaneous/us-standard-atmosphere-1976/us-standard-atmosphere_st76-1562_noaa.pdf 
% 
%% Author Info 
% This function was written by Chad A. Greene of the University of Texas at
% Austin, 2018. 
% 
% See also air_density.

%% Error checks: 

if any(h>86e3)
   warning('Returning NaNs for altitudes greater than 86 km.')
end

%% Define constants: 

% Scalar constants: 
R = 8.3144598;     % J/(mol K) Universal gas constant
g0 = 9.80665;      % m/s^2 gravitational acceleration 	
M = 0.0289644;     % kg/mol Molar mass of dry air

% Layer-dependent constants: 
LayerBase = [0 11 20 32 47 51 71 86]*1000; 
StaticPressure = [101325 22632.1 5474.89 868.02 110.91 66.94 3.96 NaN]; 
StandardTemp = [288.15 216.65 216.65 228.65 270.65 270.65 214.65 NaN];
LapseRate = [-0.0065 0 0.001 0.0028 0 -0.0028 -0.002 NaN];

% Preallocate 
Pb = NaN(size(h)); % Pa static pressure
Tb = Pb;           % K standard temperature
Lb = Pb;           % K/m standard temperature lapse rate
hb = Pb;           % m height at the bottom of layer b

% Define layer-dependent constants corresponding to each user-defined h: 
for k = 1:8
   ind     = h>=LayerBase(k); % indices of LayerBase k
   Pb(ind) = StaticPressure(k); 
   Tb(ind) = StandardTemp(k); 
   Lb(ind) = LapseRate(k); 
   hb(ind) = LayerBase(k); 
end

%% Do the mathematics: 

% Preallocate output pressure: 
P = NaN(size(h)); 

% Get indices corresponding to zero lapse rate: 
ind = Lb==0; 

% Pressure where lapse rate equals zero: 
P(ind) = Pb(ind).*exp((-g0.*M.*(h(ind)-hb(ind)))./(R.*Tb(ind)));

% Pressure for other layers: 
P(~ind) =  Pb(~ind).*(Tb(~ind)./(Tb(~ind)+Lb(~ind).*(h(~ind)-hb(~ind)))).^((g0.*M)./(R.*Lb(~ind))); 

end