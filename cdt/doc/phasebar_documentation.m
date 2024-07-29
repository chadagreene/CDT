%% |phasebar| documentation
% The |phasebar| function places a circular donunt-shaped colorbar for phase 
% from -pi to pi or -180 degrees to 180 degrees. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  phasebar
%  phasebar(...,'location',Location) 
%  phasebar(...,'size',Size) 
%  phasebar('deg') 
%  phasebar('rad') 
%  ax = phasebar(...) 
% 
%% Description 
% 
% |phasebar| places a donut-shaped colorbar on the current axes. 
%
% |phasebar(...,'location',Location)| specifies the corner (e.g., |'northeast'| or |'ne'|) 
% of the current axes in which to place the phasebar. Default location is the upper-right or |'ne'| 
% corner. 
%
% |phasebar(...,'size',Size)| specifies a size fraction of the current axes.  Default is 0.3. 
%
% |phasebar('deg')| plots labels at every 90 degrees. 
%
% |phasebar('rad')| plots labels at every pi/2 radians. 
%
% |ax = phasebar(...)| returns a handle |ax| of the axes in which the new axes are plotted. 
% 
%% Example

% Create some example phase data: 
Z = 200*peaks(900); 
Z_wrapped = mod(Z,360); % phase wrapped to 360 degrees.

% Plot the phase data as imagesc:
imagesc(Z_wrapped) 

% Set the colormap to cmocean phase: 
cmocean('phase',12)

% Create a phasebar in the lower right hand corner: 
phasebar('location','se')

%% 
% Do you prefer a large phasebar with units of radians in the upper right-hand corner?  

phasebar('location','nw','size',0.5,'rad') 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% and Kelly Kearney.