function [ h ] = ntitle(txt,varargin)
% ntitle places a title within a plot instead of on top of it. I
% 
%% Syntax 
% 
%  ntitle(txt)
%  ntitle(...,'location',InsetLocation) 
%  ntitle(...,Name,Value)
%  ntitle(...,'pad',false)
%  h = ntitle(...)
% 
%% Description 
% 
% ntitle(txt) adds the specified title txt to the current axes. 
% 
% ntitle(...,'location',InsetLocation) sets the title location as 
%   'north' (default) 
%   'northwest' or 'nw' upper left
%   'northeast' or 'ne' upper right
%   'east' or 'e' left
%   'center' or 'c' middle
%   'west' or 'w' right
%   'southwest' or 'sw' lower left
%   'south' or 's' bottom center
%   'southeast' or 'sw' lower right
% 
% ntitle(...,Name,Value) specifies any text properties such as color, fontsize, 
% etc. 
% 
% ntitle(...,'pad',false) turns off the default behavior of offsetting text 
% from each side by one space. By default, one space is placed between axis 
% edges and text. 
% 
% h = ntitle(...) returns a handle h of the title text. 
% 
%% Examples
% For examples, type
% 
%  cdt ntitle
% 
%% Author Info 
% This function was written by Chad A. Greene of the University of Texas 
% at Austin in 2013, and was rewritten for inclusion in the Climate Data Toolbox 
% for Matlab in 2018. 
% 
% See also: title and text. 


%% Parse inputs: 

% Set defaults: 
loc = 'north'; 
padText = true; 

% Change defaults if user requests them: 
tmp = strncmpi(varargin,'location',3); 
if any(tmp)
   loc = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
end

tmp = strcmpi(varargin,'pad'); 
if any(tmp)
   padText = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
   assert(islogical(padText),'Error: text padding option must be true or false.') 
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
      
   otherwise
      error('Unrecognized ntitle location.') 
end
      
%% Pad text: 

if padText
   if iscellstr(txt)
      for k = 1:size(txt,1)
         txt{k} = [' ',txt{k},' ']; 
      end
   else
      txt = [' ',txt,' ']; 
   end
end

%% Place the text:    

h = text(x,y,txt,...
   'units','normalized',...
   'horizontalalignment',horiz,...
   'verticalalignment',vert,varargin{:});

%% Clean up: 

% Return the title handle only if it is desired: 
if nargout==0
    clear h; 
end

end

