function r = earth_radius(varargin)
% earth_radius gives the radius of the Earth. 
% 
%% Syntax
% 
%  r = earth_radius
%  r = earth_radius(lat)
%  r = earth_radius(...,'km') 
% 
%% Description
% 
% r = earth_radius returns 6371000, the nominal radius of the Earth in meters. 
%
% r = earth_radius(lat) gives the radius of the Earth as a function of latitude.
% 
% r = earth_radius(...,'km') returns values in kilometers.
% 
%% Examples
% For examples, type 
% 
%  cdt earth_radius 
% 
%% Author Info
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: cdtdim and cdtarea. 

%% Set defaults: 

r = 6371000;
LatitudeDependent = false; % just output nominal radius by default
kilometers = false; 

%% Parse user-definted inputs: 

narginchk(0,2)

tmp = strcmpi(varargin,'km'); 
if any(tmp)
   kilometers = true; 
   varargin = varargin(~tmp); 
end

if ~isempty(varargin)
   if isnumeric(varargin{1})
      lat = varargin{1}; 
      LatitudeDependent = true; 
   end
end

%% Do mathematics: 

if LatitudeDependent
   a = 6378137; % equatorial radius
   b = 6356752; % polar radius
   r = (((a^2*cosd(lat)).^2 + (b^2*sind(lat)).^2)./...
        ((a*cosd(lat)).^2 + (b*sind(lat)).^2)).^(1/2);
end

if kilometers
   r = r/1000; 
end

end
