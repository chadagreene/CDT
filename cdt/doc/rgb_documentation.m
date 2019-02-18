%% |rgb| documentation 
% From the <http://blog.xkcd.com/2010/05/03/color-survey-results results of an impressively thorough survey>
% by Randall Munroe of <http://xkcd.com XKCD>, this function returns the
% RGB color triplets for just about any color name you can think of. In
% keeping with Matlab syntax, RGB values are scaled from 0 to 1. If you
% mispell a color or the color you want is not in the database,
% |rgb| will offer suggestions for other similarly-spelled colors. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  RGB = rgb('Color Name') 
%  RGB = rgb('Color Name 1','Color Name 2',...,'Color Name N')
%  RGB = rgb({'Color Name 1','Color Name 2',...,'Color Name N'})
% 
%% Description 
% 
% |RGB = rgb('Color Name')| returns the RGB triplet for a color described
% by |'Color Name'|.  
% 
% |RGB = rgb('Color Name 1','Color Name 2',...,'Color Name N')| returns an
% _N_ by 3 matrix containing RGB triplets for each color name. 
% 
% |RGB = rgb({'Color Name 1','Color Name 2',...,'Color Name N'})| accepts
%  list of color names as a character array. 
% 
%% Color reference chart
%
% To see the color options before plotting, you can reference the RGB chart
% <http://xkcd.com/color/rgb/ here>, but if you're thinking of a specific 
% color, try the |rgb| function and it will probably have the RGB values you seek.

%% Example 1: single color
% Get the RGB triplet for chartreuse: 

rgb('chartreuse')

%% Example 2: multiple colors
% Get RGB triplets for multiple colors: 

rgb('wintergreen','sunflower yellow','sapphire')

%% 
% The way colors are perceived on a computer monitor is not necessarily
% the way that colors are <http://en.wikipedia.org/wiki/Web_colors somewhat officially 
% defined>.  If we perceived RGB values of [1 0 0] as "red", [0 1 0] as
% "green", and [0 0 1] as blue, |rgb('red','green','blue')| would look like
% an identity matrix instead we have this: 

rgb('red','green','blue')

%% 
% You can also enter color names as a cell array: 

myColors = {'leather','swamp','light bluish green','butterscotch','cinnamon','radioactive green'}; 
rgb_vals = rgb(myColors)

%% 
% and we can easily plot our |rgb_vals|: 

x = 1:length(myColors); 
y = -x; 
scatter(x,y,1e3,rgb_vals,'filled')
text(x,y,myColors,'horizontalalignment','center')
axis([min(x)-1 max(x)+1 min(y)-1 max(y)+1])

%% Author Info
% This function was written by <http://www.chadagreene.com Chad A. Greene> of the Institute for
% Geophysics at the University of Texas at Austin. I do not claim any responsibility
% for the color data; kudos for the analysis and design of the survey by Randall Munroe. 