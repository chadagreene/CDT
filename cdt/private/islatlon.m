function tf = islatlon(lat,lon)
% islatlon determines whether lat,lon is likely to represent geographical
% coordinates. This function is use for input parsing in many CDT functions. 
% 
%% Syntax
% 
%  tf = islatlon(lat,lon) 
% 
%% Description
% 
% tf = islatlon(lat,lon) returns true for all input coordinates where lat
% is in the range -90 to 90 and lon is in the range -180 to 360. 
% 
%% Author Info
% Written by Chad A. Greene for Antarctic Mapping Tools for Matlab. 

tf = all([isnumeric(lat) isnumeric(lon) all(abs(lat(isfinite(lat)))<=90) all(lon(isfinite(lon))<=360) all(lon(isfinite(lon))>=-180)]); 

end