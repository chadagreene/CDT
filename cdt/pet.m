function pevap = pet(Ra,tmax,tmin,tmean,varargin)
% pet gives the potential reference evapotranspiration following Hargreaves-Samani.
%
%% Syntax
%
%  pevap = pet(Ra,tmax,tmin,tmean)
%
%% Description
%
% pevap = pet(Ra,tmax,tmin,tmean) computes the Hargreaves equation for the
% potential evapotranspiration (PET) for extraterrestrial radiation Ra (such
% as from the solar_radiation function), and temperature maxima, minima, and means. 
% Temperatures tmax, tmin, and tmean can be vectors, or can be cubes in which the first
% two dimensions are spatial and the third dimension corresponds to time. The inputs
% tmax, tmin, and tmean represent maximinum, minimum, and mean temperatures
% over a given time period. 
%
%% Examples 
% For examples, type 
% 
%  cdt pet 
% 
%% References 
% 
% Hargreaves, George H., and Zohrab A. Samani. "Reference crop evapotranspiration 
% from temperature." Applied Engineering in Agriculture 1.2 (1985): 96-99.
% https://doi.org/10.13031/2013.26773 doi:10.13031/2013.26773.
% 
% Samani, Zohrab. "Estimating solar radiation and evapotranspiration using 
% minimum climatological data." Journal of Irrigation and Drainage Engineering
% 126.4 (2000): 265-267. https://doi.org/10.1061/(ASCE)0733-9437(2000)126:4(265)
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