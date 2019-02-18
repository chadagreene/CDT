function Am = mask3(A,mask,repval) 
% mask3 applies a mask to all levels of 3D matrix corresponding to a 2D mask.
% 
%% Syntax
% 
%  Am = mask3(A,mask)
%  Am = mask3(A,mask,repval)
% 
%% Description
% 
% Am = mask3(A,mask) sets all elements along the third dimenion of the 3D 
% matrix A to NaN wherevever there are true elements in the corresponding 2D 
% logical mask.
% 
% Am = mask3(A,mask,repval) fills masked elements with a specified 
% value. Default repval is NaN.  
% 
%% Example 
% For examples, type
% 
%   cdt mask3 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas Institute for 
% Geophysics (UTIG), January 2017. 
% http://www.chadagreene.com 
% 
% See also: geomask, island, and bsxfun.

%% Error checks: 

narginchk(2,3)
assert(islogical(mask),'Input error: the mask must be logical.') 
assert(isequal([size(A,1) size(A,2)],size(mask)),'Input error: The dimensions of the mask must match the first two dimensions of A.') 

%% Input parsing: 

% Set default: 
ReplacementGrid = false; % scalar replacement by default

if nargin>2
   assert(isnumeric(repval)==1,'Input error: Replacement value must be numeric.')
   assert(any([isscalar(repval) isequal(size(mask),size(repval))]),'Replacement values repval must be a scalar or have dimensiions that match the mask.') 
   if isequal(size(mask),size(repval))
      ReplacementGrid = true; 
   end
else
   repval = NaN; 
end

%% Perform fancy math: 

% Expand the mask to 3 dimensions: 
mask = repmat(mask,[1 1 size(A,3)]); 

if ReplacementGrid
   % Expand the replacement values to 3 dimensions: 
   repval = repmat(repval,[1 1 size(A,3)]); 
   A(mask) = repval(mask); 
else
   A(mask) = repval; 
end

% The following step is wasteful in terms of memory usage, but it's more intuitive for 
% users if the output is named something different than the input: 
Am = A; 

end


