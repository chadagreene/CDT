%% |hline| documentation
% hline creates horizontal lines on a plot. 
% 
% See also <vline_docummentation.html |vline|> and <hfill_documentation.html |hfill|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents> 
%% Syntax 
% 
%  hline(y) 
%  hline(y,LineSpec) 
%  hline(...,'Name',Value,...)
%  h = hline(...)
% 
%% Description
% 
% |hline(y)| plots horizontal lines at the locations |y|. 
%
% |hline(y,LineSpec)| sets the line style, marker symbol, and color.
% 
% |hline(...,'Name',Value,...)| specifies line properties using one or more 
% Name,Value pair arguments. For a list of properties, see Line Properties. 
% Use this option with any of the input argument combinations in the previous 
% syntaxes.
% 
% |h = hline(...)| returns a handle |h| of the plotted lines. 
% 
%% Examples 
% Starting with this plot: 

plot((1:100).^0.5,'linewidth',2)

%% 
% Add a horizontal line at y=5: 

hline(5)

%% 
% Make it a black line instead: 

hline(5,'k')

%% 
% Plot thick dotted pink lines at y = 6, 7, 8, and 9. To specify pink you
% can either enter the RGB values |[1 0.51 0.75]| or you can use the
% <rgb_documentation.html |rgb|> function: 

hline(6:9,':','color',rgb('pink'),'linewidth',2)

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 