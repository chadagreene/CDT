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
%% References 
% The inner workings of this function were inspired by:
% 
% Kang & Elhami, 2001, "Using Shape Analyses for Placement of Polygon Labels",
% ESRI 2001 Int. User Conf.
% https://proceedings.esri.com/library/userconf/proc01/professional/papers/pap388/p388.htm 
% 
%% Author Info 
% This function was written by Kelly Kearney and Chad A. Greene, October 2021. 
% 
% See also centroid and text. 

structIn = false; 
polyshapeIn = false; 
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
   
   if cellIn
      x = xs{k};
      y = ys{k}; 
   end
   
   if ~polyshapeIn
      % Convert the outline to a polyshape:
      P = polyshape(x,y);
   else
      P = Pin(k); 
   end
    
   % Take only the largest region of P: 
   P = sortregions(P,'area','descend'); 
   P = regions(P);
   P = P(1);

   % Approximate P as a polygon with about 100 vertices because buffering complex polygons is too slow. 
   % For a more exact solution, delete the next two lines: 
   skip = max([floor(size(P.Vertices,1)/100) 1]); 
   P.Vertices = P.Vertices(1:skip:end,:);

   % Define a buffering step size: 
   step = sqrt(P.area/pi/10);
   init=0;

   while 1

       % Test the initial buffer size.  If too big (buffer erases the entire
       % polygon), cut buffer size in half and try again.

      istoobig = true;
      while istoobig

         bwidth = init + step;

         Pb = polybuffer(P, -bwidth);

         if ~Pb.NumRegions
            step = step/2;
         else
            
            Pb = sortregions(Pb,'area','descend'); 
            Pr = regions(Pb);
            Pr = Pr(1); 
            istoobig = false;
         end

      end

       Phull = convhull(Pr);
       sub = subtract(Phull, P);

       % If we found an enclosed hull, break out of loop.  Otherwise, repeat
       % the process with a larger buffer.

       if ~sub.NumRegions
           break
       else
           init = init + step;
       end

   end

   % Calculate centroid of enclosed polygon
   [xc(k),yc(k)] = centroid(Pr);
    
end
warning(warnStruct) 

