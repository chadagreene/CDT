function [xc,yc,Pout] = polycenter(varargin)
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
% [xc,yc,Pout] = polycenter(..., 'reduce', method) simplifies the input
% polygon(s) using the selected method prior to applying the primary
% algorithm; this can significantly reduce the computation time for
% polygons with a high density of vertices.  The simplified polygon can be
% returned as a polyshape object Pout.  Methods are:
%  'none':      no simplification applied.  Usually fastest for simple
%               polygons with a few hundred or so vertices or fewer.
%  'subsample': vertices are reduced to approximately 100 by keeping every
%               nth vertex.  This is typically faster than line
%               simplification but is only appropriate if the polygon has
%               relatively uniform vertex density and only a single region.
%  'dp':        vertices are reduced using the Douglas-Peucker line
%               simplification algorithm.  This is more robust than simple
%               subsampling but also a bit slower. [default]
%
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


p = inputParser;
p.addRequired('one', @(x) validateattributes(x, {'struct','polyshape','numeric','cell'}, {}));
p.addOptional('two', [], @(x) isnumeric(x) || iscell(x));
p.addParameter('reduce', 'dp', @(x) validateattributes(x, {'char','string'}, {}));
p.parse(varargin{:});

if isempty(p.Results.two)
   if isstruct(p.Results.one)
      structIn = true;
      S = varargin{1}; 
      shapeIn = size(S);
   elseif isa(p.Results.one, 'polyshape')
      polyshapeIn = true; 
      Pin = p.Results.one; 
      shapeIn = size(Pin);
   else
      error('Single input should be structure or polyshape');
   end
else
   if iscell(p.Results.one)
      cellIn = true; 
      xs = p.Results.one; 
      ys = p.Results.two; 
      shapeIn = size(xs); 
   else
      x = p.Results.one; 
      y = p.Results.two; 
      shapeIn = [1,1]; 
   end 
end
reducemethod = validatestring(p.Results.reduce, {'dp','subsample','none'}, 'polycenter', 'reduce');


xc = NaN(shapeIn); 
yc = xc; 
N = numel(xc); 

warnStruct = warning; 
warning off % because the polyshape function complains like heck.

for k = N:-1:1
   if structIn
      if isfield(S,'X') && isfield(S,'Y')
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
   
   switch reducemethod
      case 'none'
         % Do nothing
      case 'subsample'
         skip = max([floor(size(P.Vertices,1)/100) 1]); 
         P.Vertices = P.Vertices(1:skip:end,:);
      case 'dp'
         tol = sqrt(area(P))/100;
         pnew = dpsimplify(P.Vertices, tol);
         P.Vertices = pnew;
   end
   Pout(k) = P;

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

