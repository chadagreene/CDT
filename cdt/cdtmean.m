function M = cdtmean(lat,lon,A,varargin) 
% cdtmean computes an area-weighted average of georeferenced data. 
% 
%% Syntax
% 
%  M = cdtmean(lat,lon,A) 
%  M = cdtmean(...,'mask',mask) 
%  M = cdtmean(...,'nanmean') 
% 
%% Description 
% 
% M = cdtmean(lat,lon,A) 
% 
% M = cdtmean(...,'mask',mask) 
% 
% M = cdtmean(...,'nanmean') 
% 
%% Example 

error('this function has not been written yet.') 


%% Error checks: 

narginchk(3,inf) 
assert(islatlon(lat,lon)==1,'Input error: It appears your lat and/or lon arguments contain values outside the normal range for lats and lons. Check inputs and try again.') 
assert(isvector(lat)==1,'Input error: Input lat and lon must be 2D grids.') 
assert(isequal(size(lat),size(lon),[size(A,1) size(A,2)])==1,'Dimensions of lat and lon must match each other, and they must also match the first two dimensions of A.') 

%% Set defaults: 

mask = true(size(lat)); % Use all grid cells by default
nanmean = false; % Again, use all grid cells by default

%% Parse inputs: 

if nargin>3
   
   tmp = strcmpi(varargin,'mask'); 
   if any(tmp) 
      mask = varargin{find(tmp)+1}; 
      assert(islogical(mask)==1,'Input error: Mask must be logical.') 
      assert(isequal(size(mask),size(lat))==1,'Input error: mask must be the same size as lat and lon grids.') 
   end
   
   
end

%% Perform mathematics: 

% Calculate grid area: 
A = geoarea(lat,lon); 

% 

% Convert 2D grid area to 3D weights (if A is 3D): 



% Calculate weighted mean: 
M = sum(W.*x,dim)./sum(W,dim);

end
