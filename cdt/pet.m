function pevap = pet(Ra,tmax,tmin,tmean,varargin)
% pet potential reference evapotranspiration following Hargreaves-Samani
%
%% Syntax
%
%     pevap = pet(Ra,tmax,tmin,tmean)
%
%% Description
%
%     The Hargreaves equation is a temperature based method to calculate
%     the potential evapotranspiration (PET). This function calculates the
%     Hargreaves-Samani equation (Hargreaves and Samani, 1985, Samani 2000)
%     which estimates a reference crop evapotranspiration based on maximum,
%     minimum and mean temperature (weekly and monthly).
%
%% Input parameters
%
%     Ra       extraterrestrial radiation 
%     tmax     vector or time-space cube with maximum temperatures
%     tmin     vector or time-space cube with minimum temperatures
%     tmean    vector or time-space cube with mean temperature
%    
%  
%% Author Info
% The spei function were written by José Delgado and Wolfgang Schwanghart 
% (University of Potsdam).
% February 2019. 
% 
% See also spei and solar_radiation. 

lambda = 2.45; % MJ/kg
% Modification of the empirical coefficient according to Samani (2000)
CHS   = 0.00185*(tmax-tmin).^2 - 0.0433*(tmax-tmin) + 0.4023;
pevap = 0.0135* CHS.* Ra ./ lambda .* (tmax- tmin).^0.5 .* (tmean + 17.8); 

end