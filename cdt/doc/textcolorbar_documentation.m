%% |textcolorbar| documentation 
% The |textcolorbar| function creates a color-scaled text legend that does *not* hijack the 
% current colormap.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  textcolorbar(labels)
%  textcolorbar(...,'colormap',col,...) 
%  textcolorbar(...,'location',loc,...) 
%  textcolorbar(...,'TextProperty',TextValue,...) 
%  h = textcolorbar 
% 
%% Description
% 
% |textcolorbar(labels)| places a color-scaled text label legend in the upper
% left hand corner of the current axes. If |labels| is a numeric array, then
% the color of each label is scaled according to the range of values in
% |labels|. If |labels| is a cell array of strings, each cell becomes a row in
% the color-scaled legend.
%
% |textcolorbar(...,'colormap',col,...)| specifies an Mx3 colormap. If input
% labels are numeric, the colors of each row in the text legend are
% interpolated from the specified colormap. If input labels are cell
% strings, the colormap must have the same number of rows as the number of
% cells in labels. The default colormap is parula. 
%
% |textcolorbar(...,'location',loc,...)| specifies a location as: 
% 
% * 'north' 
% * 'northwest' or 'nw' upper left (default) 
% * 'northeast' or 'ne' upper right
% * 'east' or 'e' left
% * 'center' or 'c' middle
% * 'west' or 'w' right
% * 'southwest' or 'sw' lower left
% * 'south' or 's' bottom center
% * 'southeast' or 'sw' lower right
% * 'northoutside' or 'no'
% * 'northwestoutside' or 'nwo' 
% * 'northeastoutside' or 'neo' 
% * 'eastoutside' or 'eo' 
% * 'westoutside' or 'wo' 
% * 'southwestoutside' or 'swo' 
% * 'southoutside' or 'so' 
% * 'southeastoutside' or 'swo' 
%
% |textcolorbar(...,'TextProperty',TextValue,...)| sets any text properties
% as name-value pairs. 
%
% |h = textcolorbar(...)| returns a handle h of the color-scaled text object. 
%
%% Examples
% Start with this example plot: 

% Load some example data: 
[X,Y,Z] = peaks(500); 

figure
pcolor(X,Y,abs(Z))
shading interp
caxis([-1 15]) 
cmocean amp 
colorbar

%% 



%% 

textcolorbar(1:5)

textcolorbar([1:4 50],'loc','ne')

textcolorbar(10:20,'colormap',cmocean('thermal'),...
   'fontsize',20,'fontweight','bold',...
   'loc','se')

lifestages = {'newborn','infant','toddler','teen','adult'}; 
textcolorbar(lifestages,'loc','w') 


t=textcolorbar(lifestages,...
   'colormap',cmocean('algae',5),...
   'fontweight','bold',...
   'fontname','baskerville',...
   'fontangle','italic',...
   'loc','sw') 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by
% <https://www.chadagreene.com Chad A. Greene>
% of NASA Jet Propulsion Laboratory. 
