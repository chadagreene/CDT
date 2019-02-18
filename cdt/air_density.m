function rho = air_density(h)
% air_density computes density the baromometric forumula for a US Standard Atmosphere. 
% 
%% Syntax
% 
%  rho = air_density(h)
% 
%% Description
%
% rho = air_density(h) returns the atmospheric density rho in kg/m^3 corresponding to
% the heights h in geometric meters above sea level.
% 
%% Examples 
% For examples, type 
% 
%  cdt air_density
% 
%% Reference
% The barometric formula uses a 7 layer formula (8 layers if you include
% invalid heights above 86 km) for the 1976 US Standard Atmosphere. 
% https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19770009539_1977009539.pdf
% 
%% Author Info 
% This function was written by Chad A. Greene of the University of Texas at
% Austin, 2018. 
% 
% See also air_pressure.

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
MassDensity = [1.2250 0.36391 0.08803 0.01322 0.00143 0.00086 0.000064 NaN]; 
StandardTemp = [288.15 216.65 216.65 228.65 270.65 270.65 214.65 NaN];
LapseRate = [-0.0065 0 0.001 0.0028 0 -0.0028 -0.002 NaN];

% Preallocate:  
rhob = NaN(size(h)); % kg/m^3 mass density
Tb = rhob;           % K standard temperature
Lb = rhob;           % K/m standard temperature lapse rate
hb = rhob;           % m height at the bottom of layer b

% Define layer-dependent constants corresponding to each user-defined h: 
for k = 1:8
   ind     = h>=LayerBase(k); % indices of LayerBase k
   rhob(ind) = MassDensity(k); 
   Tb(ind) = StandardTemp(k); 
   Lb(ind) = LapseRate(k); 
   hb(ind) = LayerBase(k); 
end

%% Do the mathematics: 

% Preallocate output pressure: 
rho = NaN(size(h)); 

% Get indices corresponding to zero lapse rate: 
ind = Lb==0; 

% Density where lapse rate equals zero: 
rho(ind) = rhob(ind).*exp((-g0.*M.*(h(ind)-hb(ind)))./(R.*Tb(ind)));

% Density for other layers: 
rho(~ind) =  rhob(~ind).*(Tb(~ind)./(Tb(~ind)+Lb(~ind).*(h(~ind)-hb(~ind)))).^(1 + (g0.*M)./(R.*Lb(~ind))); 

end