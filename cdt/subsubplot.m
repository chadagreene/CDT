function h = subsubplot(varargin) 
% subsubplot creates sub-axes in tiled positions.
% 
%% Syntax 
% 
%  subsubplot(mm,nn,pp)
%  subsubplot(m,n,p,mm,nn,pp)
%  subsubplot(...,'vpad',vspace)
%  subsubplot(...,'hpad',hspace)
%  h = subsubplot(...)
% 
%% Description 
%
% subsubplot(mm,nn,pp) divides the current figure into an mm-by-nn grid and creates
% axes in the position specified by pp. The first subplot is the first column of
% the first row, the second subplot is the second column of the first row, and 
% so on. This syntax effectively fills the area that would be occupied by
% subplot(1,1,1).
% 
% subsubplot(m,n,p,mm,nn,pp) As above, but in this case the subplot(m,n,p)
% is further divided into an mm-by-nn grid, and subsubplot creates a new
% set of axes in the location specified by pp. 
% 
% subsubplot(...,'vpad',vspace) specifies the amount of vertical spacing
% between each subsubplot axis, in normalized figure units on the scale of 0
% to 1. The default value is 0. Setting it to 0.05, for example, separates axes
% by 5% of the figure height. 
% 
% subsubplot(...,'hpad',hspace) specifies the amount of horizontal spacing
% between each subplot axis, in normalized figure units on the scale of 0
% to 1. The default value is 0. Setting it to 0.05, for example, separates axes
% by 5% of the figure width. 
% 
% h = subsubplot(...) returns a handle h of the axes created by subsubplot. 
% 
%% Examples 
% For examples, type 
% 
%  cdt subsubplot
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin, 2018. 
% 
% See also: subplot, axes, and stackedplot. 

%% Set defaults: 

hpad = 0; % horizontal padding between plots (normalized figure units)
vpad = 0; % vertical padding between plots 

%% Input checks: 

% Check for subplot position: 
if nargin>5 && all(cellfun(@isnumeric,varargin(1:6)))
   m = varargin{1}; 
   n = varargin{2}; 
   p = varargin{3}; 
   mm = varargin{4}; 
   nn = varargin{5}; 
   pp = varargin{6}; 
else
   m = 1; 
   n = 1; 
   p = 1; 
   mm = varargin{1}; 
   nn = varargin{2}; 
   pp = varargin{3}; 
end

tmp = strcmpi(varargin,'vpad'); 
if any(tmp)
   vpad = varargin{find(tmp)+1}; 
   assert(all([isscalar(vpad) vpad<1]),'Error: vpad spacing must be less than 1, and should probably be closer to 0.01, which would indicate 1% of the figure height.')
end

tmp = strcmpi(varargin,'hpad'); 
if any(tmp)
   hpad = varargin{find(tmp)+1}; 
   assert(all([isscalar(hpad) hpad<1]),'Error: hpad spacing must be less than 1, and should probably be closer to 0.01, which would indicate 1% of the figure width.')
end

%% Do geometry: 

% Determine the row and column of the subsubplot: 
col = rem(pp-1,nn)+1; 
% row = fix((pp-1)/nn)+1; % from top down, is intuitive but not useful
row = (mm - 1) - fix((pp - 1) / nn); % starts at 0 from bottom up

% Determine the position of the subplot axes: 
% (This is the same position in which you'd find a subplot(m,n,p).) 
axpos = subplotpos(m,n,p); 

% Position of new axes: 
newAxWidth = (axpos(3) - hpad*(nn-1))/nn; % this allows one hpad between each column
newAxHeight = (axpos(4) - vpad*(mm-1))/mm; 
newAxX = axpos(1) + (col-1)*(newAxWidth + hpad); % bottom left corner
newAxY = axpos(2) + (row)*(newAxHeight + vpad);  % bottom left corner

%% Make new axes: 

h = axes('position',[newAxX newAxY newAxWidth newAxHeight]); 

%% Format the new axes: 

hold on
box off

% Erase the x axes unless it's the bottom row: (these 'rows' start at the
% bottom with the number zero.) 
if row~=0 
   h.XColor = 'none'; 
end

% Erase the y axes unless it's the bottom row: 
if col~=1
   h.YColor = 'none'; 
end

%% Clean up: 

if nargout==0
   clear h
end

end


%% Subfunctions: 
function position = subplotpos(varargin)
% subplotpos is a crudely edited version of the standard subplot function 
% from Matlab 2017b. This edited version just returns the axis position of a subplot
% that would be plotted by subplot, if subplot were to plot a subplot. 
% . Chad A. Greene made these edits in 2018. No warranty. 
% 
    
    parent = gcf; 
    ancestorFigure = parent;

    % This is the percent offset from the subplot grid of the plotbox.
    inset = [.2, .18, .04, .1]; % [left bottom right top]

    %check for encoded format
    position = [];
    
     % passed in subplot(m,n,p)
     nRows = varargin{1};
     nCols = varargin{2};
     plotId = varargin{3};


     if isempty(position) % true
         if min(plotId) < 1
             error(message('MATLAB:subplot:SubplotIndexTooSmall'))
         elseif max(plotId) > nCols * nRows
             error(message('MATLAB:subplot:SubplotIndexTooLarge'));
         else

             row = (nRows - 1) - fix((plotId - 1) / nCols);
             col = rem(plotId - 1, nCols);

             % get default axes position in normalized units
             % If we have checked this quantity once, cache it.
             if ~isappdata(ancestorFigure, 'SubplotDefaultAxesLocation')
                 if ~strcmp(get(ancestorFigure, 'DefaultAxesUnits'), 'normalized')
                     tmp = axes;
                     tmp.Units = 'normalized';
                     def_pos = tmp.InnerPosition;
                     delete(tmp)
                 else
                     def_pos = get(ancestorFigure, 'DefaultAxesPosition');
                 end
                 setappdata(ancestorFigure, 'SubplotDefaultAxesLocation', def_pos);
             else
                 def_pos = getappdata(ancestorFigure, 'SubplotDefaultAxesLocation');
             end


             % compute outerposition and insets relative to figure bounds
             rw = max(row) - min(row) + 1;
             cw = max(col) - min(col) + 1;
             width = def_pos(3) / (nCols - inset(1) - inset(3));
             height = def_pos(4) / (nRows - inset(2) - inset(4));
             inset = inset .* [width, height, width, height];
             outerpos = [def_pos(1) + min(col) * width - inset(1), ...
                 def_pos(2) + min(row) * height - inset(2), ...
                 width * cw, height * rw];

             % adjust outerpos and insets for axes around the outside edges
             if min(col) == 0
                 inset(1) = def_pos(1);
                 outerpos(3) = outerpos(1) + outerpos(3);
                 outerpos(1) = 0;
             end
             if min(row) == 0
                 inset(2) = def_pos(2);
                 outerpos(4) = outerpos(2) + outerpos(4);
                 outerpos(2) = 0;
             end
             if max(col) == nCols - 1
                 inset(3) = max(0, 1 - def_pos(1) - def_pos(3));
                 outerpos(3) = 1 - outerpos(1);
             end
             if max(row) == nRows - 1
                 inset(4) = max(0, 1 - def_pos(2) - def_pos(4));
                 outerpos(4) = 1 - outerpos(2);
             end

             % compute inner position
             position = [outerpos(1 : 2) + inset(1 : 2), ...
                 outerpos(3 : 4) - inset(1 : 2) - inset(3 : 4)];

         end
     end
    
    
end
