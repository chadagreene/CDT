function varargout = xyz2grid(varargin)
% xyz2grid converts regularly-spaced columnated x,y,z data into gridded data. 
% 
%% Syntax 
% 
%  Z = xyz2grid(x,y,z)
%  Z = xyz2grid(filename)
%  Z = xyz2grid(filename,Name,Value)
%  [X,Y,Z] = xyz2grid(...)
% 
%% Description 
% 
% Z = xyz2grid(x,y,z) assumes x and y have some form of regularity and puts
% the corresponding values of z into a regular 2D MxN gridded matrix Z. 
% 
% Z = xyz2grid(filename) loads data from a .xyz file of three columns 
% (x, y, and z) then puts the data into a grid.  This function assumes the 
% input x,y,z data have some gridded regularity, but may have some missing 
% data points. 
% 
% Z = xyz2grid(filename,Name,Value) opens a .xyz file with any textscan 
% options Name,Value, for example, 'headerlines',1. 
% 
% [X,Y,Z] = xyz2grid(...) returns 2D meshgridded X and Y matrices corresponding
% to the values in Z. 
% 
%% Example 
% For examples, type 
% 
%  cdt xyz2grid
% 
%% Author Info
% This script was written by Chad A. Greene of the University of Texas 
% at Austin's Institute for Geophysics (UTIG), April 2016. 
% http://www.chadagreene.com 
% 
% See also xyzread and accumarray. 

%% Error checks and input parsing: 

narginchk(1,inf) 

% Has the user input x,y,z coordinates or a .xyz filename? Assume filename if first input is a string:  
if isnumeric(varargin{1})
   x = varargin{1}; 
   y = varargin{2}; 
   z = varargin{3}; 
else
   [x,y,z] = xyzread(varargin{:}); 
end

assert(isequal(size(x),size(y),size(z))==1,'Dimensions of x,y, and z must match.') 
assert(isvector(x)==1,'Inputs x,y, and z must be vectors.') 

%% Grid xyz: 

% Get unique values of x and y: 
[xs,~,xi] = unique(x(:),'sorted'); 
[ys,~,yi] = unique(y(:),'sorted'); 

% Before we go any further, we better make sure we're not gridding scattered data. 
% This is not a perfect assessor, but it's at least some kind of check: 
if numel(xs)==numel(z)
   warning 'It does not seem like the xyz dataset is gridded. You may be attempting to grid scattered data, but I will try to put it into a 2D matrix anyway. Check the output spacing of X and Y.';
end

% Sum up all the Z values that in each x,y grid point: 
Z = accumarray([yi xi],z(:),[],[],NaN); 

% Flip Z to match X,Y and to be correctly oriented in ij image coordinates: 
Z = flipud(Z); 

%% Package up the outputs: 

switch nargout 
   case 1 
      varargout{1} = Z; 
      
   case 3

      % Create a meshgrid of x and y:
      [varargout{1},varargout{2}] = meshgrid(xs,flipud(ys)); 
      varargout{3} = Z; 
      
   otherwise
      error('Wrong number of outputs.') 
end
      

end
