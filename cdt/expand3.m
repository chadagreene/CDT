function Z3 = expand3(Z,y)
% expand3 creates a 3D matrix from the product of a 2D grid and a 1D
% vector.
% 
%% Syntax
% 
%  Z3 = expand3(Z,y)
% 
%% Description
% 
% Z3 = expand3(Z,y) creates a 3D matrix Z3 through elementwise
% multiplication of the 2D grid Z and the 1D array y. 
% 
%% Examples
% For examples, type 
% 
%  cdt expand3
% 
%% Author Info
% This function was written by Chad A. Greene, 2018. 
% 
% See also bsxfun, reshape, and repmat. 

%% Input checks: 

narginchk(2,2) 
assert(ismatrix(Z),'Error: Input grid Z must be 2D.') 
assert(sum(size(y)>1)<=1,'Error: Input y must be a vector.')

%% 

% Get y into 1x1xN shape: 
y = reshape(y,[1 1 numel(y)]); 

Z3 = bsxfun(@times,Z,y); 

end