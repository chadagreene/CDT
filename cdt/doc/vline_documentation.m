%% |vline| documentation
% vline creates vertical lines on a plot. 
% 
% See also <hline_documentation.html |hline|> and <vfill_documentation.html |vfill|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents> 
%% Syntax 
% 
%  vline(y) 
%  vline(y,LineSpec) 
%  vline(...,'Name',Value,...)
%  h = vline(...)
% 
%% Description
% 
% |vline(y)| plots vertical lines at the locations |y|. 
%
% |vline(y,LineSpec)| sets the line style, marker symbol, and color.
% 
% |vline(...,'Name',Value,...)| specifies line properties using one or more 
% Name,Value pair arguments. For a list of properties, see Line Properties. 
% Use this option with any of the input argument combinations in the previous 
% syntaxes.
% 
% |h = vline(...)| returns a handle |h| of the plotted lines. 
% 
%% Examples 
% Starting with this plot: 

plot((1:100).^2,'linewidth',2)

%% 
% Add a vertical line at y=5: 

vline(20)

%% 
% Make it a black line instead: 

vline(20,'k')

% Optional: Label the line: 
text(20,10000,' <- this is a black line',...
   'vert','top') % pin text to top left corner

%% 
% Plot thick dotted pink lines at y = 60, 70, 80, and 90. To specify pink you
% can either enter the RGB values |[1 0.51 0.75]| or you can use the
% <rgb_documentation.html |rgb|> function: 

vline(60:10:90,':','color',rgb('pink'),'linewidth',2)

text(60,0,'pink lines -> ',...
   'color',rgb('pink'),...
   'horiz','right',... % pins text to the right sid
   'vert','bottom')       % pins text to bottom

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 