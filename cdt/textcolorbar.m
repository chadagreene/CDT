function h = textcolorbar(labels,varargin) 
% textcolorbar creates a color-scaled text legend that does *not* hijack the 
% current colormap.
% 
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
% textcolorbar(labels) places a color-scaled text label legend in the upper
% left hand corner of the current axes. If labels is a numeric array, then
% the color of each label is scaled according to the range of values in
% labels. If labels is a cell array of strings, each cell becomes a row in
% the color-scaled legend.
%
% textcolorbar(...,'colormap',col,...) specifies an Mx3 colormap. If input
% labels are numeric, the colors of each row in the text legend are
% interpolated from the specified colormap. If input labels are cell
% strings, the colormap must have the same number of rows as the number of
% cells in labels. The default colormap is parula. 
%
% textcolorbar(...,'location',loc,...) specifies a location as: 
%   'north' 
%   'northwest' or 'nw' upper left (default) 
%   'northeast' or 'ne' upper right
%   'east' or 'e' left
%   'center' or 'c' middle
%   'west' or 'w' right
%   'southwest' or 'sw' lower left
%   'south' or 's' bottom center
%   'southeast' or 'sw' lower right
%   'northoutside' or 'no'
%   'northwestoutside' or 'nwo' 
%   'northeastoutside' or 'neo' 
%   'eastoutside' or 'eo' 
%   'westoutside' or 'wo' 
%   'southwestoutside' or 'swo' 
%   'southoutside' or 'so' 
%   'southeastoutside' or 'swo' 
%
% textcolorbar(...,'TextProperty',TextValue,...) sets any text properties
% as name-value pairs. 
%
% h = textcolorbar(...) returns a handle h of the color-scaled text object. 
%
%% Examples
% For examples type 
% 
%    cdt textcolorbar
% 
%% Author Info 
% This function was written by Chad A. Greene of NASA's Jet Propulsion 
% Laboratory, October 2021. 
% 
% See also: text, legend, and colorbar. 

%% Parse inputs: 

% Set defaults: 
loc = 'nw'; 
if isnumeric(labels)
   col = parula; % might be interpolated later based on input values
else
   col = parula(length(labels)); 
end

if nargin>1
   % Change defaults if user requests them: 
   tmp = strncmpi(varargin,'location',3); 
   if any(tmp)
      loc = varargin{find(tmp)+1}; 
      tmp(find(tmp)+1) = true; 
      varargin = varargin(~tmp); 
   end
      
   % 
   tmp = strncmpi(varargin,'colormap',3); 
   if any(tmp)
      col = varargin{find(tmp)+1}; 
      assert(isnumeric(col) & size(col,2)==3,'Colormap must be Nx3 numeric.')
      tmp(find(tmp)+1) = true; 
      varargin = varargin(~tmp); 
   end
end

%% Determine text positions and alignment: 

switch lower(loc)
   case {'northwest','nw'}
      x = 0; 
      y = 1; 
      horiz = 'left'; 
      vert = 'top'; 
      
   case {'north','n','top'}
      x = 0.5; 
      y = 1; 
      horiz = 'center'; 
      vert = 'top'; 
      
   case {'northeast','ne'}
      x = 1; 
      y = 1; 
      horiz = 'right'; 
      vert = 'top'; 
      
   case {'west','w','left'}
      x = 0; 
      y = 0.5; 
      horiz = 'left'; 
      vert = 'middle'; 
      
   case {'center','c','cent','cen'}
      x = 0.5; 
      y = 0.5; 
      horiz = 'center'; 
      vert = 'middle'; 
      
   case {'east','e','right'}
      x = 1; 
      y = 0.5; 
      horiz = 'right'; 
      vert = 'middle'; 
      
   case {'southwest','sw'}
      x = 0; 
      y = 0; 
      horiz = 'left'; 
      vert = 'bottom'; 
      
   case {'south','s','bottom','bot'}
      x = 0.5; 
      y = 0; 
      horiz = 'center'; 
      vert = 'bottom'; 
      
   case {'southeast','se'}
      x = 1; 
      y = 0; 
      horiz = 'right'; 
      vert = 'bottom'; 
      %%%
      
   case {'northwestoutside','nwo'}
      x = 0; 
      y = 1; 
      horiz = 'right'; 
      vert = 'top'; 
      
   case {'northoutside','no','topout'}
      x = 0.5; 
      y = 1; 
      horiz = 'center'; 
      vert = 'bottom'; 
      
   case {'northeastoutside','neo'}
      x = 1; 
      y = 1; 
      horiz = 'left'; 
      vert = 'top'; 
      
   case {'westoutside','wo','leftout'}
      x = 0; 
      y = 0.5; 
      horiz = 'right'; 
      vert = 'middle'; 
      
   case {'eastoutside','eo','rightout'}
      x = 1; 
      y = 0.5; 
      horiz = 'left'; 
      vert = 'middle'; 
      
   case {'southwestoutside','swo'}
      x = 0; 
      y = 0; 
      horiz = 'right'; 
      vert = 'bottom'; 
      
   case {'southoutside','so','bottomout','boto'}
      x = 0.5; 
      y = 0; 
      horiz = 'center'; 
      vert = 'top'; 
      
   case {'southeastoutside','seo'}
      x = 1; 
      y = 0; 
      horiz = 'left'; 
      vert = 'bottom'; 
      
   otherwise
      error('Unrecognized textcolorbar location.') 
end
      
%% Create text 

% Convert to characters: 
if isnumeric(labels) 
   % Re-interpolate the colormap to the input numeric values: 
   col = mat2rgb(labels(:),col); 
   labels = num2str(labels(:));
else
   labels = char(labels); 
end
   
nc1 = num2str(col(:,1)); 
nc2 = num2str(col(:,2)); 
nc3 = num2str(col(:,3)); 

txt = [' \color[rgb]{',nc1(1,:),',',nc2(1,:),',',nc3(1,:),'} ',labels(1,:),' '];
for k = 2:size(col,1)
   txt = [txt;[' \color[rgb]{',nc1(k,:),',',nc2(k,:),',',nc3(k,:),'} ',labels(k,:),' ']];
end

% Place the text:    
h = text(x,y,txt,...
   'units','normalized',...
   'horizontalalignment',horiz,...
   'verticalalignment',vert,...
   'interpreter','tex',varargin{:});

%% Clean up: 

% Return the title handle only if it is desired: 
if nargout==0
    clear h; 
end

end


function RGB = mat2rgb(val,cmap,limits)
% 
% 
% Chad Greene wrote this, July 2016. 

if nargin==2
   limits = [min(val) max(val)]; 
end

gray = mat2gray(val,limits); 
ind = gray2ind(gray,size(cmap,1));
RGB = cmap(ind+1,:); 

end