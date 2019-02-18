function [row,col,dst] = near2(X,Y,xi,yi,mask)
% near2 finds the subscript indices of the point in a grid closest to a 
% specified location. 
% 
%% Syntax
% 
%  [row,col] = near2(X,Y,xi,yi)
%  [row,col] = near2(X,Y,xi,yi,mask)
%  [row,col,dst] = near2(...)
% 
%% Description
% 
% [row,col] = near2(X,Y,xi,yi) returns the row and column corresponding to the 
% X,Y grid point with the shortest euclidean distance to the point xi,yi. If
% xi or yi is equidistant between two X or Y grid points, only the first of
% the two equally valid rows or columns is returned. 
% 
% [row,col] = near2(X,Y,xi,yi,mask) ignores X,Y grid points corresponding
% to false mask values. This option may be useful near data boundaries, where
% the nearest point in the data grid could correspond to NaN data in the
% time series. 
% 
% [row,col,dst] = near2(...) also returns the euclidean distance dst from 
% the point {X(row,col),Y(row,col)} to the point {xi,yi}.
%
%% Examples
% For examples, type 
% 
%  cdt near2
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% at Austin, 2018. 
% 
% See also: geomask, local, near1, and ind2sub. 

%% Error checks: 

narginchk(4,5) 
nargoutchk(2,3) 
siz = size(X); 
assert(isequal(siz,size(Y)),'Error: Dimensions of X and Y must match.')
assert(isequal(numel(xi),numel(yi)),'Error: xi and yi must be the same size.') 

%% Do mathematics: 

% Mask-out user-defined mask values by setting them to NaN: 
if nargin==5
   assert(isequal(siz,size(mask)),'Error: Dimensions of the grid and the mask must agree.') 
   X(~mask) = NaN; 
end

% Preallocate distance-squared and index arrays: 
dst_sq = NaN(size(xi));
ind = dst_sq; 

% Loop through, computing the distance from each user-defined coordinate to
% all grid points: : 
for k = 1:length(xi)

   % Get the distance between the point and each grid point, but just
   % compute the sum of squares. That's because square roots are
   % computationally expensive and hypot includes the square root.:
   D_sq = (X-xi(k)).^2 + (Y-yi(k)).^2; 

   % Find the minimim distance squared and its linear index: 
   [dst_sq(k),ind(k)] = min(D_sq(:)); 
end

% Convert linear indices to rows and columns: 
[row,col] = ind2sub(siz,ind); 

% If the user wants distances, calculate them: 
if nargout==3
   dst = sqrt(dst_sq); 
end

end