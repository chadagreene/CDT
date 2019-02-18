function [Zb,ind] = bottom(Z) 
% bottom returns the lowermost finite values in a 3D matrix. This function is
% useful for getting the seafloor temperature or atmospheric surface temperature
% in the presence of topography. 
% 
%% Syntax 
% 
%  Zb = bottom(Z)
%  [Zb,ind] = bottom(Z)
% 
%% Description 
% 
% Zb = bottom(Z) returns a 2D matrix containing the lowermost finite values
% in the 3D matrix Z. 
% 
% [Zb,ind] = bottom(Z) also returns 2D matrix ind which contains the indices 
% along the third dimension of Z corresponding to the lowermost finite values 
% in Z. 
% 
%% Example
% For examples, type 
% 
%  cdt bottom
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas
% Institute for Geophysics (UTIG).
% 
% See also: reshape, find, ind2sub.

assert(ndims(Z)==3,'Error: Z must be a 3D matrix.'); 

%% Mathematics: 

% Transform Z into 2D: 
Zr = cube2rect(Z); 

% Make a counter for each grid cell, starting w/1 at the top, increasing as we go down: 
cntr = cumsum(ones(size(Zr))); 

% Set Z's NaNs to zero in the counter matrix: 
cntr(isnan(Zr)) = 0; 

% Find the row of the maximum counter in each grid cell: 
[~,row] = max(cntr);

% Convert rows and cols to indices of the big 2D matrix: 
Zr_ind = sub2ind(size(cntr),row,1:size(cntr,2)); 

% Get bottom Z values from Zr_ind and reshape to original gridsize: 
Zb = rect2cube(Zr(Zr_ind),size(Z)); 

% Only give the depth indices if the user wants them: 
if nargout==2
   ind = rect2cube(row,size(Z)); 
end

end
