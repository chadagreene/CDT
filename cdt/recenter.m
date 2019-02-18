function [latout,lonout,varargout] = recenter(lat,lon,varargin) 
% recenter rewraps a gridded dataset to be centered on a specified longitude. 
% 
%% Syntax
% 
%  [lat,lon] = recenter(lat,lon)
%  [lat,lon,Z1,Z2,...,Zn] = recenter(lat,lon,Z1,Z2,...,Zn)
%  [...] = recenter(...,'center',centerLon)
% 
%% Description 
% 
% [lat,lon] = recenter(lat,lon) rewraps a global lat,lon grid such that it is centered on the 
% Prime Meridian (zero longitude). A common application is to convert a grid spanning 0 to 360 
% into a grid spanning -180 to 180. 
% 
% [lat,lon,Z1,Z2,...,Zn] = recenter(lat,lon,Z1,Z2,...,Zn) rewraps input grids lat,lon along with 
% any other datasets Zn of corresponding dimensions. Any of the Z datasets can be 2D of exactly
% the same dimensions as lat and lon, or can be 3D, whose first two dimensions correspond to the 
% lat,lon grids and the third dimension might correspond to time or depth.  
% 
% [...] = recenter(...,'center',centerLon) centers gridded data on any specified longitude. Default 
% centerlon is 0 degrees. 
% 
%% Examples 
% For examples type 
% 
%    cdt recenter
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas Institute for Geophysics
% (UTIG), Februrary 2017.  http://www.chadagreene.com
% 
% See also wrapTo180 and wrapTo360. 

narginchk(2,inf) 
assert(islatlon(lat,lon)==1,'Input error, your lats and lons contain values that exceed typical lats and lons. Check inputs and try again.') 

%% Set Defaults: 

center = 0; % Default center longitude 

%% Parse optional inputs: 

if nargin>2
   tmp = strncmpi(varargin,'center',4); 
   if any(tmp) 
      center = varargin{find(tmp)+1}; 
      assert(isscalar(center)==1,'Input error: Center longitude must be a scalar.')
      assert(abs(center)<=360,'Input error: center longitude out of range.') 
      tmp(find(tmp)+1) = 1; 
      varargin = varargin(~tmp); 
   end
   
end

%% Determine grid type: 
% The grid may have been constructed any of the following, where + indicates ascending, and - indicates descending: 
% 
% [lon,lat] = meshgrid(+lon,+lat)   in which case   gridtype = [1 1 0 0]
% [lon,lat] = meshgrid(-lon,+lat)   in which case   gridtype = [-1 1 0 0]
% [lon,lat] = meshgrid(+lon,-lat)   in which case   gridtype = [1 -1 0 0]
% [lon,lat] = meshgrid(-lon,-lat)   in which case   gridtype = [-1 -1 0 0]
% [lat,lon] = meshgrid(+lat,+lon)   in which case   gridtype = [0 0 1 1] 
% [lat,lon] = meshgrid(-lat,+lon)   in which case   gridtype = [0 0 -1 1] 
% [lat,lon] = meshgrid(+lat,-lon)   in which case   gridtype = [0 0 1 -1] 
% [lat,lon] = meshgrid(-lat,-lon)   in which case   gridtype = [0 0 -1 -1] 
% 
% Conveniently, we don't really have to worry about whether values are ascending or descending, we'll just try
% to move the left side to the right and the right side to the left and sure it's a little inelegant, but it
% works.  Do a similar procedure for top and bottom if abs(gridtype) = [0 0 1 1].  

% If input is vector, convert it to a grid for now:
isv = isvector(lon); 
if isv
   lon_vec = lon; 
   lat_vec = lat; 
   % First, assume it's [lon,lat] style: 
   [lon,lat] = meshgrid(lon_vec,lat_vec); 
   if nargin>2 
      if isnumeric(varargin{1})
         % But if the grid we tried creating doesn't match Z, try a [lat,lon] grid:
         if ~isequal(size(lon),[size(varargin{1},1) size(varargin{1},2)])
            [lat,lon] = meshgrid(lat_vec,lon_vec); 
         end
      end
   end
end

assert(isequal(size(lat),size(lon)),'Error: Unless lat and lon are vectors, their dimensions must match exactly.')
gridtype = [sign(diff(lon(2,1:2))) sign(diff(lat(1:2,1))) sign(diff(lat(2,1:2))) sign(diff(lon(1:2,1)))]; 
assert(sum(abs(gridtype))==2,'Input error: The lat,lon grids must be constructed in meshgrid style.') 

%% Make sure there's actual work to be done: 

stufftofix = [any(lon(:)>(center+180)) any(lon(:)<(center-180))]; 

if ~any(stufftofix) 
   latout = lat; 
   lonout = lon; 
   varargout = varargin; 
end

%% For [lon,lat] = meshgrid type grids: 
 
if isequal(abs(gridtype),[1 1 0 0])

   % Take rightmost bits and move them to the left:  
   lon1 = lon(1,:); 
   
   % Find indices of lons that are too high: 
   ind = lon1>(center+180); 
   if any(ind)

      % Change longitude values: 
      lon(:,ind) = lon(:,ind) - 360; 

      % Concatenate the lats and lons: 
      latout = horzcat(lat(:,ind),lat(:,~ind)); 
      lonout = horzcat(lon(:,ind),lon(:,~ind)); 

      % Preallocate output before the loop:
      varargout = cell(1,nargout-2); 

      % Loop through all the inputs, and make them outputs: 
      if nargin>2
         for k = 1:length(varargin) 
            tmp = varargin{k}; 
            assert(isequal([size(tmp,1) size(tmp,2)],size(lat))==1,'Input error: Dimensions of all inputs must match lat,lon grids.') 

            switch ndims(varargin{k}) 
               case 2
                  varargout{k} = horzcat(tmp(:,ind),tmp(:,~ind)); 

               case 3
                  varargout{k} = horzcat(tmp(:,ind,:),tmp(:,~ind,:)); 

               otherwise
                  error('Input error: Cannot parse dimensions of inputs.') 
            end
         end
      end
      
   end
  

   % Or perhaps the leftmost bits must be moved to the right side:  
   lon1 = lon(1,:); 

   % Find indices of lons that are too low: 
   ind = lon1<(center-180); 
   
   if any(ind)

      % Change longitude values: 
      lon(:,ind) = lon(:,ind) + 360; 

      % Concatenate the lats and lons: 
      latout = horzcat(lat(:,~ind),lat(:,ind)); 
      lonout = horzcat(lon(:,~ind),lon(:,ind)); 
      

      % Preallocate output before the loop:
      varargout = cell(1,nargout-2); 

      % Loop through all the inputs, and make them outputs: 
      if nargin>2
         for k = 1:length(varargin) 
            tmp = varargin{k}; 

            switch ndims(varargin{k}) 
               case 2
                  varargout{k} = horzcat(tmp(:,~ind),tmp(:,ind)); 

               case 3
                  varargout{k} = horzcat(tmp(:,~ind,:),tmp(:,ind,:)); 

               otherwise
                  error('Input error: Cannot parse dimensions of inputs.') 
            end
         end
      end
   end

   % Take just the vectors if vectors were the inputs: 
   if isv
      latout = latout(:,1); 
      lonout = lonout(1,:); 
   end
end

%% For [lat,lon] = meshgrid types

if isequal(abs(gridtype),[0 0 1 1])
   
      % Take topmost bits and move them to the bottom:  
      lon1 = lon(:,1); 

      % Find indices of lons that are too high: 
      ind = lon1>(center+180); 
      
      if any(ind)

         % Change longitude values: 
         lon(ind,:) = lon(ind,:) - 360; 

         % Concatenate the lats and lons: 
         latout = vertcat(lat(ind,:),lat(~ind,:)); 
         lonout = vertcat(lon(ind,:),lon(~ind,:)); 

         % Preallocate output before the loop:
         varargout = cell(1,nargout-2); 

         % Loop through all the inputs, and make them outputs: 
         if nargin>2
            for k = 1:length(varargin) 
               tmp = varargin{k}; 
               assert(isequal([size(tmp,1) size(tmp,2)],size(lat))==1,'Input error: Dimensions of all inputs must match lat,lon grids.') 

               switch ndims(varargin{k}) 
                  case 2
                     varargout{k} = vertcat(tmp(ind,:),tmp(~ind,:)); 

                  case 3
                     varargout{k} = vertcat(tmp(ind,:,:),tmp(~ind,:,:)); 

                  otherwise
                     error('Input error: Cannot parse dimensions of inputs.') 
               end
            end
         end
         
      end

      
      % Or perhaps the bottommost bits must be moved to the top side:  
      lon1 = lon(:,1); 

      % Find indices of lons that are too low: 
      ind = lon1<(center-180); 
      
      if any(ind)

         % Change longitude values: 
         lon(ind,:) = lon(ind,:) + 360; 

         % Concatenate the lats and lons: 
         latout = vertcat(lat(~ind,:),lat(ind,:)); 
         lonout = vertcat(lon(~ind,:),lon(ind,:)); 

         % Preallocate output before the loop:
         varargout = cell(1,nargout-2); 

         % Loop through all the inputs, and make them outputs: 
         if nargin>2
            for k = 1:length(varargin) 
               tmp = varargin{k}; 
               switch ndims(varargin{k}) 
                  case 2
                     varargout{k} = vertcat(tmp(~ind,:),tmp(ind,:)); 

                  case 3
                     varargout{k} = vertcat(tmp(~ind,:,:),tmp(ind,:,:)); 

                  otherwise
                     error('Input error: Cannot parse dimensions of inputs.') 
               end
            end
         end
      end
      
   % Take just the vectors if vectors were the inputs: 
   if isv
      latout = latout(1,:); 
      lonout = lonout(:,1); 
   end
      
end

end
