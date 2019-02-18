%% |quiversc| documentation
% |quiversc| scales a dense grid of quiver arrows to comfortably fit in axes
% before plotting them.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  quiversc(x,y,u,v)
%  quiversc(...,'density',DensityValue)
%  quiversc(...,scale)
%  quiversc(...,LineSpec)
%  quiversc(...,LineSpec,'filled')
%  quiversc(...,'Name',Value)
%  h = quiversc(...)
% 
%% Description 
% 
% |quiversc(x,y,u,v)| plots vectors as arrows at the coordinates specified in 
% each corresponding pair of elements in |x| and |y|. The matrices |x|, |y|, |u|, and 
% |v| must all be the same size and contain corresponding position and velocity
% components. By default, the arrows are scaled to just not overlap, but you 
% can scale them to be longer or shorter if you want.
% 
% |quiversc(...,'density',DensityFactor)| specifies density of quiver arrows. The 
% |DensityFactor| defines how many arrows are plotted. Default |DensityFactor| is 
% |50|, meaning |hypot(Nrows,Ncols)=50|, but if your plot is too crowded you may 
% specify a lower |DensityFactor| (and/or adjust the markersize). 
% 
% |quiversc(...,scale)| automatically scales the length of the arrows to fit within 
% the grid and then stretches them by the factor scale. |scale = 2| doubles their 
% relative length, and |scale = 0.5| halves the length. Use |scale = 0| to plot the 
% velocity vectors without automatic scaling. You can also tune the length of 
% arrows after they have been drawn by choosing the Plot Edit tool, selecting 
% the quiver object, opening the Property Editor, and adjusting the Length slider.
% 
% |quiversc(...,LineSpec)| specifies line style, marker symbol, and color using 
% any valid |LineSpec|. quiversc draws the markers at the origin of the vectors.
% 
% |quiversc(...,LineSpec,'filled')| fills markers specified by |LineSpec|.
% 
% |quiversc(...,'Name',Value)| specifies property name and property value pairs
% for the quiver objects the function creates.
% 
% |h = quiversc(...)| returns the quiver object handle |h|. 
% 
%% The problem 
% *Here's the problem:* When you try to plot a dense grid of wind patterns 
% using Matlab's built-in |quiver| function, things can get too crowded 
% to make any sense out of what's going on: 

load pacific_wind

figure
quiver(lon,lat,u10,v10)
axis tight % eliminates empty space
borders    % national borders for context 

%% Example 1
% Above, the 417x761 grid of wind vectors means there are more than 300,000
% arrows in that plot. To put that into context, there are 761 arrows spanning 
% the width of the plot, and that's probably about how many pixels the plot is 
% occupying on your screen. In other words, if each arrow is about the size
% of a pixel, they're gonna be too small gain any understanding from. 
% 
% So try the same thing, but this time with |quiversc|: 

figure
quiversc(lon,lat,u10,v10)
axis tight 
borders 

%% Example 2: Define arrow properties
% Make the arrows red and plot fewer of them by setting the density to 30 
% rather than the default 50: 

figure
quiversc(lon,lat,u10,v10,'r','density',75)
axis tight 
borders 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 
