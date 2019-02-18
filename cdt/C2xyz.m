function [x,y,z] = C2xyz(C)
% C2xyz converts a contour matrix (as returned by the contour function) into
% x, y, and corresponding z coordinates.
% 
%% Syntax
% 
%  [x,y] = C2xyz(C)
%  [x,y,z] = C2xyz(C)
% 
%% Description 
% 
% [x,y] = C2xyz(C) returns x and y coordinates of contours in a contour
% matrix C
% 
% [x,y,z] = C2xyz(C) also returns corresponding z values. 
% 
%% Examples
% For examples, type 
% 
%  cdt C2xyz
% 
%% Author Info
% Written in 2013 by Chad A. Greene of the University of Texas. Updated in
% for inclusion in Antarctic Mapping Tools for Matlab (Greene et a., 2017) 
% and updated again for the Climate Data Toolbox in 2019. 
% 
% See also contour, clabel, and transectc.


m(1)=1; 
n=1;  
try
   while n<length(C)
      n=n+1;
      m(n) = m(n-1)+C(2,m(n-1))+1; 
   end
end

for nn = 1:n-2
   x{nn} = C(1,m(nn)+1:m(nn+1)-1); 
   y{nn} = C(2,m(nn)+1:m(nn+1)-1); 
   if nargout==3
      z(nn) = C(1,m(nn));
   end
end

end