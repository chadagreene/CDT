function [FX,FY] = cdtgradient(lat,lon,F,varargin)
% cdtgradient calculates the spatial gradient of gridded data equally spaced in geographic
% coordinates. 
% 
%% Syntax 
% 
%  [FX,FY] = cdtgradient(lat,lon,F)
%  [FX,FY] = cdtgradient(lat,lon,F,'km')
% 
%% Description
% 
% [FX,FY] = cdtgradient(lat,lon,F) for the gridded variable F and corresponding geographic
% coordinates lat and lon, cdtgradient calculates FX, the spatial rate of west-to-east change 
% in F per meter along the Earth's surface, and FY, the south-to-north change in F  per meter. 
% This function assumes an ellipsoidal Earth as modeled by the cdtdim and earth_radius. A
% positive value of FX indicates that F increases from west to east in that grid cell, as
% a positive value of FY indicates F increases from south to north. F can be a 2D or 3D matrix
% whose first two dimensions must correspond to lat and lon. If F is 3D, outputs FX and FY
% will also be 3D, with each grid along the third dimension calculated separately. 
% 
% [FX,FY] = cdtgradient(lat,lon,F,'km') returns gradients per kilometer rather than the
% default meters. 
% 
%% Examples 
% For examples, type 
% 
%   cdt cdtgradient
%
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG). 
% http://www.chadagreene.com
% 
% See also: cdtarea and cdtcurl. 

%% Initial error checks: 

assert(nargout==2,'Error: cdtgradient requires two outputs, FX and FY. Type ''cdt cdtgradient'' for help.') 
assert(nargin>2,'Error: cdtgradient requires at least three inputs: lat, lon, and F.') 
assert(isequal(isvector(lat),isvector(lon),0),'Error: lat and lon must be grids, not arrays.') 
assert(islatlon(lat,lon)==1,'Input error: cdtgradient requires the first two inputs to be lat and lon.') 
assert(isequal(size(lat),size(lon),[size(F,1) size(F,2)])==1,'Input error: dimensions of lat, lon, and F must match.')

%% Input parsing: 

% Set defaults: 
km = false; 

if nargin>3
    tmp = strcmpi(varargin,'km'); 
    if any(tmp)
        km = true; 
    else
        error('Unrecognized input.') 
    end
end
 
%% Change grid orientation if necessary: 
% Some grids are created like [lon,lat] = meshgrid(-180:180,-90:90) while others are created like 
% [lat,lon] = meshgrid(-90:90,-180:180). For consistency, let's permute the [lat,lon] types into [lon,lat] types: 

% An overview of gridtypes appears in the recenter function
gridtype = [sign(diff(lon(2,1:2))) sign(diff(lat(1:2,1))) sign(diff(lat(2,1:2))) sign(diff(lon(1:2,1)))]; 

if isequal(abs(gridtype),[1 1 0 0])
   % This means it's the [lon,lat] type, and we're good to keep going.
   permutedims = false; 
   
elseif isequal(abs(gridtype),[0 0 1 1])
   lat = permute(lat,[2 1 3]); 
   lon = permute(lon,[2 1 3]); 
   F = permute(F,[2 1 3]); 
   permutedims = true; 
else
   error('Unrecognized lat,lon grid type. It should be monotonic, like it was created by meshgrid.') 
end

%% Estimate grid size: 

if km
   [dx,dy] = cdtdim(lat,lon,'km');
else
   [dx,dy] = cdtdim(lat,lon);
end

%% Calculate gradient: 

% Preallocate output: 
FX = nan(size(F)); 
FY = nan(size(F)); 

% Calculate gradient for each slice of F: 
for k = 1:size(F,3)
   [FX(:,:,k),FY(:,:,k)] = gradient(F(:,:,k)); 
end

FX = bsxfun(@rdivide,FX,dx); 
FY = bsxfun(@rdivide,FY,dy); 

%% Return to original grid orientation if we changed it: 

if permutedims 
   FX = ipermute(FX,[2 1 3]); 
   FY = ipermute(FY,[2 1 3]); 
end

end
