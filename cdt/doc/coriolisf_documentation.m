%% |coriolisf| documentation 
% The |coriolisf| function returns the Coriolis frequency for any given latitude(s). 
% The Coriolis frequency is sometimes called the Coriolis parameter or the 
% Coriolis coefficient. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  f = coriolisf(lat) 
%  f = coriolisf(lat,rot) 
% 
%% Description
% 
% |f = coriolisf(lat)| returns Earth's Coriolis frequency for any locations(s) 
% at latitude(s) |lat|. By default, the Coriolis frequency is given in units of rad/s. 
% 
% |f = coriolisf(lat,rot)| specifies a rate of rotation |rot|. By default, |rot|
% is Earth's present-day rate of rotation 7.2921 x 10^-5 rad/s, but a different
% rate may be specified to model Earth at a different time, other celestial 
% bodies, or the Coriolis parameter in a different unit of frequency. 
% 
%% Example 
% Make a a 1°x1° grid, with <cdtgrid_documentation.html |cdtgrid|>, and get 
% the Coriolis parameter for corresponding to each grid cell:

[Lat,Lon] = cdtgrid; 

f = coriolisf(Lat); 

%% 

globepcolor(Lat,Lon,f)          % coriolis f as pcolor
globeborders                    % national borders
globegraticule('linestyle',':') % the grid lines

view(20,5)                      % sets the globe viewing angle

caxis([-1 1]*0.146e-3)          % sets color axis limits
cb = colorbar('location','southoutside'); 
xlabel(cb,'coriolis frequency rad s^{-1}')
cmocean diff                    % sets the colormap
axis tight                      % minimizes empty space

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 