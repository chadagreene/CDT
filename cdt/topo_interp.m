function zi = topo_interp(lati,loni,varargin)
% topo_interp interpolates elevation relative to sea level at any
% geographic points. The data are from the ETOPO5 world digital elevation 
% model, which is provided at 5-minute (or 1/12 degree) grid resolution. 
% 
%% Syntax
% 
%  zi = topo_interp(lati,loni)
%  zi = topo_interp(lati,loni,'method',InterpMethod) 
% 
%% Description 
% 
% zi = topo_interp(lati,loni) returns elevations relative to sea level
% at the geographic points lati,loni. 
% 
% zi = topo_interp(lati,loni,'method',InterpMethod) specifies an interpolation
% method and can be any method accepted by interp2. Default method is 'linear'. 
% 
%% Examples 
% For examples, type
% 
%  cdt topo_interp
% 
%% Author Info 
% This function was written by Chad A. Greene, 2018. 
% 
% See also island and dist2coast. 

%% Error checks:

narginchk(2,Inf) 
assert(islatlon(lati,loni),'Input coordinates appear to be outside the normal range of latitudes and longitudes. Check inputs (and their order) and try again.')
assert(isequal(size(lati),size(loni)),'Dimensions of input coordinates must agree.') 

%% Parse Inputs: 

tmp = strncmpi(varargin,'method',4); 
if any(tmp)
   InterpMethod = varargin{find(tmp)+1}; 
else
   InterpMethod = 'linear'; 
end

%% Wrap input coordinates
% In case inputs are on the 0-360 range: 

ind = loni>180; 
loni(ind) = loni(ind)-360; 

%% Load Data

load('global_topography.mat','lat','lon','Z'); 

%% Wrap the topography dataset itself
% For continuous interpolation across the international date line. 

Z = [Z(:,end-4:end) Z Z(:,1:5)]; 
lon = [lon(end-4:end)-360 lon lon(1:5)+360]; 

%% Interpolate

zi = interp2(lon,lat,Z,loni,lati,InterpMethod,NaN); 

end