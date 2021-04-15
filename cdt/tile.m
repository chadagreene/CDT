function [row,col,h_rect,h_txt] = tile(A_or_siz,maxsiz,varargin) 
% tile determines indices for dividing a matrix into multiple tiles. 
% 
%% Syntax 
% 
%  [row,col] = tile(A,maxsiz) 
%  [row,col] = tile(siz,maxsiz)
%  [row,col] = tile(...,'overlap',overlap)
%  [row,col,h_rect,h_txt] = tile(...,'show')
%  
%% Description
% 
% [row,col] = tile(A,maxsiz) returns subscript indices row and col that can
% be used to divide matrix A into tiles, each having a maximum size maxsiz. maxsiz
% can be a scalar to describe the side dimenions of a square tile, or maxsiz
% can be a two-element array to limit tile sizes to rectangular dimensions.
% Outputs row and col are cell arrays, each cell containing the range of
% subscript indices of one tile of A. A can be a 2D or 3D matrix, but if A
% is a 3D matrix, only its first two dimensions are considered in the tiling
% calculations. 
% 
% [row,col] = tile(siz,maxsiz) tiles a matrix of size siz into tiles of
% maximum dimensions maxsiz. 
% 
% [row,col] = tile(...,'overlap',overlap) specifies the number of rows and
% columns by which the tiles overlap. overlap can be a scalar or a two-element 
% array. 
% 
% [row,col,h_rect,h_txt] = tile(...,'show') displays numbered rectangles on
% a plot, showing the tiles. Optional outputs h_rect and h_txt are handles
% of the plotted rectangles and text labels. 
%
%% Examples
% For examples, type 
% 
%  cdt tile
% 
%% Author Info
% This function was written by Chad A. Greene in 2019. 
% 
% See also: blockproc and sub2ind. 

%% Error checks: 

narginchk(2,Inf) 
assert(isvector(maxsiz),'Error: Maximum tilesize maxsiz should be an array.')
assert(numel(maxsiz)<=2,'Error: Maximum tilesize maxsiz cannot have more than two elements.') 

if nargout==1
   warning('You have only requested one output from the tile function. That means just the rows. Sure you don''t want the columns too?')
end

%% Parse Inputs: 

% Set the defaults: 
overlap = [0 0]; 
show = false;  % don't show the grid.

% Check for changes to the defaults: 
tmp = strncmpi(varargin,'show',3); 
if any(tmp)
   show = true; 
end

tmp = strncmpi(varargin,'overlap',4);
if any(tmp)
   overlap = varargin{find(tmp)+1}; 
end

%% Reshape inputs as warranted: 


% Did the user enter a whole matrix, or just the size of a matrix? 
if numel(A_or_siz)<=3
   siz = A_or_siz; 
else
   siz = size(A_or_siz); 
end

% Take only the first two dimensions: 
switch numel(siz)
   case 1
      siz = [siz siz]; 
   case 2
      % do nothing
   case 3
      siz = siz(1:2); 
   otherwise
      error('Invalid matrix size siz.') 
end

if isscalar(maxsiz)
   maxsiz = [maxsiz maxsiz]; 
end

if isscalar(overlap)
   overlap = [overlap overlap]; 
end

%% Do the math: 

% Adjust maxsiz if there's any overlap: 
maxsiz = maxsiz-overlap; 

% Make grids of starting rows and colums for each tile: 
startrow = repmat((1:maxsiz(1):siz(1))',1,ceil(siz(2)./maxsiz(2))) - overlap(1);
startcol = repmat(1:maxsiz(2):siz(2),ceil(siz(1)./maxsiz(1)),1) - overlap(2);

% Define the end rows corresponding to the starts: 
endrow = startrow + maxsiz(1) - 1 + overlap(1); 
endcol = startcol + maxsiz(2) - 1 + overlap(1); 

% Ensure start indices don't go lower than 1: 
startrow(startrow<1) = 1; 
startcol(startcol<1) = 1; 

% Ensure the ending indices don't exceed the size of the full grid: 
endrow(endrow>siz(1)) = siz(1); 
endcol(endcol>siz(2)) = siz(2); 

% Preallocate row and column cells: 
row = cell(size(startrow)); 
col = row; 

% Loop through each tile, 
for k = 1:numel(row)
   row{k} = startrow(k):endrow(k); 
   col{k} = startcol(k):endcol(k); 
end

%% Show the grid (if requested) 

if show
   hold on
   for k = 1:numel(row)

      % Coordinates of the rectangle (leaves a small space between)
      rect = [col{k}(1)-.45 row{k}(1)-.45 length(col{k})-.1 length(row{k})-.1];

      % Define a color of this rectangle: 
      color = rand(1,3); 

      % Draw this rectangle: 
      h_rect(k) = rectangle('position',rect,'linewidth',1,'edgecolor',color);

      % Label this rectangle: 
      h_txt(k) = text(rect(1)+rect(3)/2,rect(2)+rect(4)/2,num2str(k),...
         'color',color,'horiz','center','vert','middle','clipping','on');
   end
   
   axis ij % because these are row and colummn indices
   
   % Only suppress the output if user wanted a 'show' and didn't request any outputs:
   if nargout==0
      clear row col
   end
end

end