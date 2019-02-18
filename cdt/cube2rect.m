function A2 = cube2rect(A3,mask)
% cube2rect reshapes a 3D matrix for use with standard Matlab functions. 
% 
% This function enables easy, efficient, vectorized analysis instead of using 
% nested loops to operate on each row and column of a matrix. 
% 
%% Syntax
% 
%  A2 = cube2rect(A3) 
%  A2 = cube2rect(A3,mask)
% 
%% Description 
% 
% A2 = cube2rect(A3) for a 3D matrix A3 whose dimension correspond to space x space x time, 
% cube2rect reshapes the A3 into a 2D matrix A2 whose dimensions correspond to time x space. 
% 
% A2 = cube2rect(A3,mask) uses only the grid cells corresponding to true values in a 2D mask. 
% This option can reduce memory requirements for large datasets where some regions (perhaps all land
% or all ocean grid cells) can be neglected in processing. 
% 
%% Example 
% For examples type 
% 
%   cdt cube2rect
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG). 
% 
% See also: rect2cube, permute, and reshape.

%% Error checks: 

narginchk(1,2)
if nargin>1
   assert(isequal(size(mask),[size(A3,1),size(A3,2)]),'Error: The dimensions of the input mask must match the first two dimensions of A3') 
   assert(islogical(mask),'Error: mask must be logical.') 
end

% Reshape
A2 = permute(A3,[3 1 2]); % brings the "time" dimenion to dimension 1, which makes time go down the rows. 
A2 = reshape(A2,size(A2,1),size(A2,2)*size(A2,3)); % combines both spatial dimensions into one.  

% Remove masked-out values: 
if nargin>1
   A2 = A2(:,mask(:)); 
end

end