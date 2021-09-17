function A3 = rect2cube(A2,gridsize_or_mask) 
% rect2cube is the complement of cube2rect. It reshapes and permutes
% a 2D matrix into a 3D cube. 
% 
% This function enables easy, efficient, vectorized analysis instead of using 
% nested loops to operate on each row and column of a matrix. 
% 
%% Syntax
% 
%  A3 = rect2cube(A2,gridsize)
%  A3 = rect2cube(A2,mask)
% 
%% Description
% 
% A3 = rect2cube(A2,gridsize) reshapes 2D matrix A2 into a 3D matrix whose first
% two dimensions are spatial (e.g., lat x lon or lon x lat) and whose third 
% dimension is time or perhaps ocean depth or some variable along which operations
% are performed. The final dimensions of A3 are specified by gridsize, which 
% may be a complete 3 element array describing A3, or gridsize may be just a 2 
% element array containing the first two dimensions of A3. 
% 
% A3 = rect2cube(A2,mask) reshapes the elements of A2 into the true grid
% cells in a 2D matrix mask. 
% 
%% Examples
% For examples, type 
% 
%  cdt rect2cube
% 
%% Author Info
% This function was written by Chad A. Greene of the University 
% of Texas at Austin. 
% 
% See also: cube2rect, reshape, and permute. 

%% Error checks: 

assert(nargin==2,'Error: rect2cube requires 2 inputs.') 

%% Input parsing: 

% maskMethod means the user has input a 2D mask.  
if numel(gridsize_or_mask)<=3
   maskMethod = false; % the user has input only the sizes
   gridsize = gridsize_or_mask; 
   assert(gridsize(1)*gridsize(2)==size(A2,2),'Error: Dimensions of the gridsize must match the number of columns in A2.')
else
   maskMethod = true;  % the user has input a full 2D mask
   mask = gridsize_or_mask; 
   assert(islogical(mask),'Error: gridsize_or_mask must be either a 1D array describing grid size or a 2D logical mask.')
   gridsize = size(mask); 
end

if maskMethod
   
   % Create a full-size 2D NaN array: 
   if islogical(A2)
      A2full = false(size(A2,1),numel(mask)); 
   else
      A2full = NaN(size(A2,1),numel(mask)); 
   end
   
   % Fill in the "true" elements from the mask with A2: 
   A2full(:,mask) = A2; 
   
   % Unreshape back to original size of A: 
   A3 = ipermute(reshape(A2full,[],gridsize(1),gridsize(2)),[3 1 2]); 
   
else
   % Unreshape back to original size of A: 
   A3 = ipermute(reshape(A2,[],gridsize(1),gridsize(2)),[3 1 2]); 
end


end