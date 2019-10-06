function [mask,coords] = geomask(lat,lon,latv,lonv,varargin) 
% geomask returns true for locations within a specified geographic region. 
% 
%% Syntax
% 
%  mask = geomask(lat,lon,latv,lonv) 
%  mask = geomask(lat,lon,latv,lonv,'inclusive') 
%  [mask,coords] = geomask(...) 
% 
%% Description 
% 
% mask = geomask(lat,lon,latv,lonv) returns a mask the size of lat and lon that is 
% true for all points within the bounds given by latv,lonv. 
% 
%   scalar latv,lonv: If latv,lonv are scalar values, the output mask will be true
%      for only the pixel closest to latv,lonv. 
% 
%   two-element arrays: If latv,lonv are two-element arrays (e.g., [40 50],[110 120]) 
%      the output mask will be true for all lat,lon values within the geographic 
%      quadrangle bounded by latv,lonv. 
% 
%   polygon defined by latv,lonv: If latv,lonv contain more than two elements, the
%      output mask will be true for all elements of lat,lon within the polygon 
%      defined by latv,lonv. 
% 
%   polygons in cell format: If latv,lonv are cell arrays (as is common for multiple 
%      areas in a shapefile), the output mask is true for all elements within any 
%      of the polygons in latv,lonv. 
% 
% mask = geomask(lat,lon,latv,lonv,'inclusive') includes lat,lon points that are on 
% the boundary or boundaries defined by latv,lonv. 
% 
% [mask,coords] = geomask(...) If latv,lonv are scalar, the optional coords output 
% is a structure containing the coordinates of the pixel in the mask. The coords
% structure includes coords.row and coords.col which are the row and column of 
% of the lat,lon grid, and coords.lat and coords.lon, which are the geographic 
% location of the output grid cell. 
% 
%% Examples 
% For examples type 
% 
%    cdt geomask
% 
%% Author Info 
% 
% See also inpolygon, cdtgrid, and local. 

%% Input checks: 

assert(nargin>3,'Input error: geomask requires at least 4 inputs.') 
assert(isequal(size(lat),size(lon))==1,'Input error: The dimensions of lat and lon must match.') 
assert(isequal(size(latv),size(lonv))==1,'Input error: The dimensions of latv,lonv must match.') 
assert(islatlon(lat,lon)==1,'Input error: Coordinates lat,lon do not appear to be in proper range for geo coordinates.') 

if ~iscell(latv)
   assert(islatlon(latv,lonv)==1,'Input error: Coordinates latv,lonv do not appear to be in proper range for geo coordinates.') 
else
   % assume everything is okay. 
end

%% Set defaults: 

inclusive = false; 

%% Parse inputs: 

% Determine whether the edges of the domain should be included in the mask: 
tmp = strncmpi(varargin,'inclusive',3); 
if any(tmp)
   inclusive = true; 
end

% Determine which type of solution we're looking for: 
switch numel(latv) 
   case 1 
      masktype = 'NearestNeighbor'; 
      
   case 2
      masktype = '2Drange'; 
      assert(nargout<2,'Error in geomask: There can be no output coordinates for 2D range type mask.') 
      
   otherwise
      masktype = 'polygon'; 
      assert(nargout<2,'Error in geomask: There can be no output coordinates for polygon type mask.') 
end

% If latv,lonv are one-element cell arrays they'd be incorrectly deemed NearestNeighbor by the switch above, so fix it now: 
if iscell(latv)
   assert(iscell(lonv)==1,'Input error: if latv is a cell array, lonv must also be a cell array.') 
   masktype = 'polygons'; % note, it's plural 
end

%% Wrap longitudes: 

ind = lon>180; 
lon(ind) = lon(ind)-360; 

indv = lonv>180; 
lonv(indv) = lonv(indv)-360; 

%% Make a mask:

switch masktype
   case 'NearestNeighbor'

      % An explanation of gridtypes is found in the recenter documentation
      gridtype = [sign(diff(lon(2,1:2))) sign(diff(lat(1:2,1))) sign(diff(lat(2,1:2))) sign(diff(lon(1:2,1)))]; 
      

      if isequal(abs(gridtype),[1 1 0 0])
         lon1 = lon(1,:); 
         lat1 = lat(:,1); 
         row = interp1(lat1,1:length(lat1),latv,'nearest'); 
         col = interp1(lon1,1:length(lon1),lonv,'nearest'); 
      elseif isequal(abs(gridtype),[0 0 1 1])
         lon1 = lon(:,1); 
         lat1 = lat(1,:); 
         col = interp1(lat1,1:length(lat1),latv,'nearest'); 
         row = interp1(lon1,1:length(lon1),lonv,'nearest'); 
      else
         error('Unrecognized lat,lon grid type. For a single-point nearest-pixel mask, inputs lat,lon must be a monotonic grid, like it was created by meshgrid.') 
      end

      
      mask = false(size(lat)); 
      mask(row,col) = true; 
      
      % if user wants the coordinates of the nearest point, give the user what she or he wants: 
      if nargout==2
         coords.row = row; 
         coords.col = col; 
         coords.lat = lat(row,col); 
         coords.lon = lon(row,col); 
      end

   case '2Drange'

      if inclusive
         if lonv(1) > lonv(2)
            mask = lat>=min(latv) & lat<=max(latv) & (lon>=lonv(1) | lon<=lonv(2));
         else
            mask = lat>=min(latv) & lat<=max(latv) & (lon>=lonv(1) & lon<=lonv(2));
         end
      else
         if lonv(1) > lonv(2)
            mask = lat>min(latv) & lat<max(latv) & (lon>lonv(1) | lon<lonv(2));
         else
            mask = lat>min(latv) & lat<max(latv) & (lon>lonv(1) & lon<lonv(2));
         end
      end
         
   case 'polygon'
      
      if ~inclusive
         [in,on] = inpolygon(lon,lat,lonv,latv); 
         mask = in | on; 
      else 
         mask = inpolygon(lon,lat,lonv,latv); 
      end
      
   case 'polygons'
      
      % preallocate: 
      mask = false(size(lat)); 
      
      % Loop through each cell: 
      for k = 1:length(latv)
        
         if inclusive
            [in,on] = inpolygon(lon,lat,lonv{k},latv{k}); 
            mask = mask | in | on; 
         else 
            mask = mask | inpolygon(lon,lat,lonv{k},latv{k}); 
         end
      
      end
      
      
end   





end
