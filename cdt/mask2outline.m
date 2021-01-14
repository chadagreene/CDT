function [xb,yb] = mask2outline(x,y,mask,varargin)
% mask2outline converts a logical mask into an outline or border. 
% 
%% Syntax 
% 
%  [xb,yb] = mask2outline(x,y,mask)
%  [xb,yb] = mask2outline(...,'buffer',buf)
%  [xb,yb] = mask2outline(...,'region',N)
% 
%% Description 
% 
% [xb,yb] = mask2outline(x,y,mask) returns the coordinates xb,yb of the 
% outline of a 2D mask whose input coordinates pixel centers are given by 
% x,y. 
% 
% [xb,yb] = mask2outline(...,'buffer',buf) specifies a buffer in units
% of x,y to place around the mask. For example, if the units of x and y are 
% meters and buf=10e3, then that places a 10 km buffer around the mask. The 
% buffer can be negative to buffer into the mask. 
% 
% [xb,yb] = mask2outline(...,'region',N) only returns the outline of the 
% Nth largest region by area. 
% 
%% Example 
% For examples type 
% 
%   cdt mask2outline
% 
%% Author Info
% This function was written by Chad A. Greene of NASA's Jet Propulsion 
% Laboratory in September 2020. 
% http://www.chadagreene.com 
% 
% See also: demresize. 

%% Input checks: 

narginchk(3,Inf) 
assert(islogical(mask),'Error input mask must be logical.') 

BufferIt = false; 
SingleRegion = false; 
if nargin>3 
   tmp = strncmpi(varargin,'buffer',3);
   if any(tmp)
      buf = varargin{find(tmp)+1}; 
      assert(isscalar(buf),'Error: buffer value must be a scalar with the same units as x and y.') 
      BufferIt = true; 
   end
    
   tmp = strncmpi(varargin,'region',3);
   if any(tmp)
      reg = varargin{find(tmp)+1}; 
      assert(isscalar(reg),'Error: Region number must be a scalar.') 
      SingleRegion = true; 
    end
end

if size(x,1)>1 & size(x,2)>1 
   % ...then assume input was created by [X,Y] = meshgrid(x,y); 
   x = x(1,:); 
   y = y(:,1); 
end

%% Math: 

% Create a contour halfway between 0 and 1: 
C = contourc(x,y,double(mask),[0.5 0.5]); 

% Convert the contour matrix to x,y coordinates: 
[xb,yb] = C2xyz(C); 

if BufferIt 
   P = polybuffer(polyshape(xb,yb),buf); % 3 km offset of the buffer 

   P = sortboundaries(P,'area','descend'); % to ensure we're just getting biggest section of the ice shelf if the ice shelf is somewhat piecemeal 

   if SingleRegion
      [xb,yb] = boundary(P,reg); 
   else
      [xb,yb] = boundary(P); 
   end
   
else 
   xb = cell2nancat(xb); 
   yb = cell2nancat(yb); 
end



end