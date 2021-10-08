function [xc,yc] = polycenter(varargin)
% polycenter finds coordinates at the center of the largest section of a
% polygon. This is similar to the centroid, but ensures the coordinates are
% in the interior of the polygon (centroids may be outside of a cresecent
% shape, for example). 
%
%% Syntax
% 
%  [xc,yc] = polycenter(P)
%  [xc,yc] = polycenter(S)
%  [lonc,latc] = polycenter(S)
%  [xc,yc] = polycenter(x,y)
%
%% Description
% 
% [xc,yc] = polycenter(P) returns the "center" coordinate(s) xc,yc of any
% polyshape(s) P. 
%
% [xc,yc] = polycenter(S) returns the "center" coordinate(s) xc,yc of each
% row in the shapefile structure S. This syntax assumes the shapefile
% structure S contains the fields S.X and S.Y. 
%
% [lonc,latc] = polycenter(S) returns the "center" longitude and latitude 
% if the shapefile structure S does not contain S.X or S.Y, but does contain
% S.Lat and S.Lon.
%
% [xc,yc] = polycenter(x,y) returns the "center" coordinate(s) xc,yc for the 
% inputs coordinates x,y. If x,y are 1d arrays, the outputs xc,yc
% are scalars. If input x,y are cells, outputs xc,yc will contain a center
% coordinate for the polygons bound by the arrays in each cell. 
% 
%% Examples 
% For examples, type 
% 
%  cdt polycenter
% 
%% Author Info 
% This function was written by Chad A. Greene of NASA Jet Propulsion
% Laboratory, October 2021. 
% 
% See also centroid and text. 

structIn = false; 
polyshapeIn = false; 
arrayIn = false; 
cellIn = false; 

switch nargin
   case 1 
      if isstruct(varargin{1})
         structIn = true;
         S = varargin{1}; 
         shapeIn = size(S);
      else
         % There's no ispolyshape function, so assume it's a structure. 
         polyshapeIn = true; 
         Pin = varargin{1}; 
         shapeIn = size(Pin);
      end
   case 2 
      if iscell(varargin{1})
         cellIn = true; 
         xs = varargin{1}; 
         ys = varargin{2}; 
         shapeIn = size(xs); 
      else
         arrayIn = true; 
         x = varargin{1}; 
         y = varargin{2}; 
         shapeIn = [1,1]; 
      end
   otherwise
      error('polycenter must have one or two inputs.') 
end

xc = NaN(shapeIn); 
yc = xc; 
N = numel(xc); 

warnStruct = warning; 
warning off % because the polyshape function complains like heck.

for k = 1:N
   if structIn
      if isfield(S,'X') & isfield(S,'Y')
         x = S(k).X;
         y = S(k).Y;
      else 
         x = S(k).Lon;
         y = S(k).Lat;
      end
   end
   
   if ~polyshapeIn
      % Convert the outline to a polyshape:
      P = polyshape(x,y);
   else
      P = Pin(k); 
   end
    
   % And get the delaunay triangulation of the polygon:
   T = triangulation(P);
    
   % Now find the center points of all the triangles:
   [C,r] = circumcenter(T);
    
   % If it's not inside the polygon, make sure it doesn't have the maximum radius: 
   r(~isinterior(P,C(:,1),C(:,2))) = -1;
    
   % Get the index of the centerpoint that has the largest radius from the boundary:
   [~,ind] = max(r);
    
   % These center coordinates are in the center of the fattest part of the polygon:
   xc(k) = C(ind,1);
   yc(k) = C(ind,2);
    
end
warning(warnStruct) 

