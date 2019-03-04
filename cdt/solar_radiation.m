function Ra = solar_radiation(t,lat)
% solar_radiation computes modern daily total extraterrestrial solar radiation
% received at the top of Earth's atmosphere.
% 
% This function is quite similar to the daily_insolation function, and one 
% may suit your needs better than the other. The daily_insolation function
% is best suited for investigations involving orbital changes over tousands 
% to millions of years, whereas solar_radiation may be easier to use
% for applications such as present-day precipitation/drought research.
%
%% Syntax
%
%  Ra = solar_radiation(t,lat)
%   
%% Description
% 
% Ra = solar_radiation(t,lat) calculates the extraterrestrial radiation (MJ m^(-2)
% day^(-1)) based on the dates t and latitude lat. Dates t can be in datetime, 
% datenum, or datestr format, but must be a 1D array or a scalar. lat can be scalar, 
% vector, or grid. If lat is a vector or array with size nrows and ncols
% then Ra has the size [nrows,ncols,length(t)].
% 
%% Examples 
% For examples, type 
% 
%  cdt solar_radiation
% 
%% References
% The solar_radiation function computes the equation by Allen et al. (1998), 
% McCullough and Porter (1971) and McCullough (1968). See also here: 
% https://www.hydrol-earth-syst-sci.net/17/1331/2013/hess-17-1331-2013-supplement.pdf
% 
%% Author Info
% The spei function were written by José Delgado and Wolfgang Schwanghart 
% (University of Potsdam).
% February 2019. 
% 
% See also daily_insolation, sun_angle, pet, and spei. 

%% Error checks: 

assert(max(abs(lat(:)))<=90,'Input latitude(s) cannot exceed +/-90 degrees.') 

%% Mathematics: 

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
dr2 = 1 + 0.033*cos(2*pi*dy);

% solar declination (radians)
rho = 0.409*sin(2*pi*dy - 1.39); % same size as t

% ws - sunset hour angle
ws  = real(acos( - bsxfun(@times,tan(lat),tan(rho))));

Ra = 1440/pi * Gsc * bsxfun(@times,dr2, (ws .* bsxfun(@times,sin(lat),sin(rho)) + ...
                           bsxfun(@times,cos(lat),cos(rho)).*sin(ws)));
                        
end
