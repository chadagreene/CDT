%% |air_density| documentation
% |air_density| computes density from the baromometric forumula for a US Standard Atmosphere. 
% 
% See also <air_pressure_documentation.html |air_pressure|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  rho = air_density(h)
% 
%% Description
%
% |rho = air_density(h)| returns the atmospheric density |rho| in kg/m^3 corresponding to
% the heights |h| in geometric meters above sea level.
% 
%% Example
% The US Standard Atmosphere formula is valid to 86 km above sea level, so
% let's look at air density from sea level to 85 km: 

h = 0:85e3; 

rho = air_density(h); 

figure 
plot(rho,h/1000)
axis tight
box off 
ylabel 'height above sea level (km)' 
xlabel 'density (kg m^{-3})' 

%% 
% The formula uses a piecewise function that calculates an equation based
% on different constants for different layers of the atmosphere. The bases
% of those layers are at 0, 11, 20, 32, 47, 51, and 71 km above sea level. 
% For context, we can plot those layer bases as horizontal lines using
% <hline_documentation.html |hline|>:

LayerBases = [0 11 20 32 47 51 71]; 

hline(LayerBases,':','color',rgb('gray'))

%%
% Pro tip: For some applictions it may be helpful to display the x axis on
% a log scale. To do that, we could have plotted the data with |semilogx| instead of
% using the |plot| function above, or we can change the x scale to log like this: 

set(gca,'xscale','log')

%% 
% Curious about the relationship between atmospheric density and
% atmospheric pressure? Compare with <air_pressure_documentation.html
% |air_pressure|>:

p = air_pressure(h); 

figure
plot(p/1000,rho)
axis tight 
box off
xlabel 'pressure (kPa)'
ylabel 'density (kg m^{-3})' 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 