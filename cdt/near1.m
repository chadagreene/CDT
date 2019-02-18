function [ind,dst] = near1(x,xi) 
% near1 finds the linear index of the point in an array closest to a 
% specified coordinate. 
% 
%% Syntax
% 
%  ind = near1(x,xi) 
%  [ind,dst] = near1(x,xi) 
% 
%% Description 
% 
% ind = near1(x,xi) returns the index ind of the point in x closest to xi. 
% If xi is equidistant between two x values, ind corresponds to the first
% of the two. 
% 
% [ind,dst] = near1(x,xi) also returns the ditance dst between x(ind) and xi. 
% 
%% Examples 
% For examples, type 
% 
%  cdt near1 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% at Austin, 2018. 
% 
% See also: near2, find, geomask, and local. 

%% Error checks: 

narginchk(1,2) 
assert(isvector(x),'Error: x must be a vector.') 
assert(isvector(xi),'Error: xi must be a scalar or a vector.')

%% Mathematics: 

% Preallocate array: 
ind = NaN(size(xi)); 

% Solve it for each xi: 
for k = 1:numel(ind)
   [~,ind(k)] = min(abs(x-xi(k))); 
end

if nargout==2
   dst = x(ind) - xi; 
end

end