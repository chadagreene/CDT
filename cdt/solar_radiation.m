function Ra = solar_radiation(t,lat)
% solar_radiation computes modern daily total extraterrestrial solar radiation.
%
% Syntax
%
%     Ra = solar_radiation(t,lat)
%
% Description
%
%     solar_radiation calculates the extraterrestrial radiation (MJ m^(-2)
%     day^(-1)) based on the dates in t and latitude lat. solar_radiation uses the
%     equation by Allen et al. (1998), McCullough and Porter (1971) and
%     McCullough (1968). See also here: 
%     https://www.hydrol-earth-syst-sci.net/17/1331/2013/hess-17-1331-2013-supplement.pdf
%
% Input arguments
%
%     t     nt*1 vector with dates (datetime or datenum vector)
%     lat   scalar, vector or grid with latitudes (negative for southern
%           hemisphere) in degree.
%
% Output arguments
%
%     Ra    solar radiation. If lat is a scalar, Ra is a vector same size
%           as t. If lat is a vector or array with size nrows and ncols
%           then Ra has the size [nrows,ncols,nt].
%
%% Author Info
% The spei function were written by José Delgado and Wolfgang Schwanghart 
% (University of Potsdam).
% February 2019. 
% 
% See also daily_insolation, sun_angle, pet, and spei. 

% Day of year
dy = doy(t,'remdecimalyear'); % will be a number between 0 and 1 & accounts for leap year.  
dy = dy(:);

if ~isscalar(lat)
    dy = reshape(dy,1,1,numel(dy));
end
Gsc = 0.0820; %(MJ m-2 min-1)

% latitudes to radians
lat = deg2rad(lat);

% inverse relative distance earth-sun
dr2 = 1 + 0.033*cos(2*pi * dy);

% solar declination (radians)
rho = 0.409*sin(2*pi * dy - 1.39); % same size as t

% ws - sunset hour angle
ws  = acos( - bsxfun(@times,tan(lat),tan(rho)));

Ra = 1440/pi * Gsc * bsxfun(@times,dr2, (ws .* bsxfun(@times,sin(lat),sin(rho)) + ...
                           bsxfun(@times,cos(lat),cos(rho)).*sin(ws)));
                        
end
