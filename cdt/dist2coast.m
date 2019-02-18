function di = dist2coast(lati,loni,varargin)
% dist2coast determines the distance from any geolocation to the nearest coastline.
% 
%% Syntax
% 
%  di = dist2coast(lati,loni)
% 
%% Description 
% 
% di = dist2coast(lati,loni) gives the great-circle distance di in kilometers from the 
% geolocation(s) lati,loni to the nearest coast line. For points on land, di is the 
% distance to the nearest ocean. For oceanic locations, di is the distance to the nearest
% land. 
% 
%% Examples 
% For examples, type
% 
%  cdt dist2coast
% 
%% Author Info 
% This function was written by Chad A. Greene, 2018. 
% 
% See also island and topo_interp. 

%% Error checks:

narginchk(2,2) 
assert(islatlon(lati,loni),'Input coordinates appear to be outside the normal range of latitudes and longitudes. Check inputs (and their order) and try again.')
assert(isequal(size(lati),size(loni)),'Dimensions of input coordinates must agree.') 

%% Wrap input coordinates
% In case inputs are on the 0-360 range: 

ind = loni>180; 
loni(ind) = loni(ind)-360; 

%% Load Data

load('distance2coast.mat','lat','lon','D'); 

%% Wrap the topography dataset itself
% For continuous interpolation across the international date line. 

D = [D(:,end-4:end) D D(:,1:5)]; 
lon = [lon(end-4:end)-360 lon lon(1:5)+360]; 

%% Interpolate

di = interp2(lon,lat,double(D),loni,lati,'linear'); 

end