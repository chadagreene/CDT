function [cb2,ax1,ax2] = newcolorbar(varargin) 
% newcolorbar allows multiple colormaps and colorbars to be used in  
% the same subplot. 
% 
%% Syntax 
% 
%  colorbar
%  colorbar(Location)
%  colorbar(...,PropertyName,PropertyValue)
%  [cb2,ax2,ax1] = colorbar(...)
% 
%% Description 
% 
% colorbar creates a new set of axes and a new colorbar in the default 
% (right) location. 
% 
% colorbar(Location) specifies location of the new colorbar as 
%       'North'              inside plot box near top
%       'South'              inside bottom
%       'East'               inside right
%       'West'               inside left
%       'NorthOutside'       outside plot box near top
%       'SouthOutside'       outside bottom
%       'EastOutside'        outside right (default)  
%       'WestOutside'        outside left
%
% colorbar(...,PropertyName,PropertyValue) specifies additional
% name/value pairs for colorbar. 
% 
% [cb2,ax2,ax1] = colorbar(...) returns handles of the new colorbar
% cb2, the new axes ax2, and the previous current axes ax1. 
% 
%% Examples 
% For examples, type 
% 
%  cdt newcolorbar
% 
%% Author Info
% The newcolorbar function was written by  Chad A. Greene of the University
% of Texas at Austin's Institute for Geophysics (UTIG), August 2015. 
% http://www.chadagreene.com. 
% 
% See also colorbar, colormap, and cmocean. 

%% Make sure user has R2014b or later: 

assert(verLessThan('matlab','8.4.0')==0,'Sorry, the newcolorbar function requires Matlab R2014b or later.') 

%% Begin work: 

% Axis 1 is the original current axis: 
ax1 = gca; 

% Get position of axis 1: 
ax1p = get(ax1,'pos'); 

% Create new axes: 
if license('test','map_toolbox')
    if ismap(gca)
        gm = gcm; 
        ax2 = axesm(gm);
    else
        ax2 = axes; 
    end
end

% Co-locate ax2 atop ax1: 
set(ax2,'pos',ax1p)

% Make ax2 invisible:
axis off 

% Link ax1 and ax2 so zooming will work properly: 
linkaxes([ax1,ax2],'xy') 

% Create a new colorbar
cb2 = colorbar(varargin{:}); 

% If creation of the new colorbar resized ax2, set ax1 to the same size. 
% But first we need to make sure everything is drawn properly: 
drawnow 
set(ax1,'pos',get(ax2,'pos'))

% Make new axes current: 
axes(ax2)

% Ensure we're ready to plot new data:
hold on

%% Clean up: 

if nargout==0
    clear cb2
end
end
