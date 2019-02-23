function [az,el] = sun_angle(t,lat,lon,h)
% sun_angle gives the solar azimuth and elevation for any time at any location 
% on Earth.
% 
% This function was adapted from the SolarAzEl function by Darin C. Koblick.
%% Syntax
% 
%  [az,el] = sun_angle(t,lat,lon)
%  [az,el] = sun_angle(t,lat,lon,h)
% 
%% Description 
% 
% [az,el] = sun_angle(t,lat,lon) gives the solar azimuth and elevation in
% degrees at the specified geographic locations and times t in UTC. Input t
% can be datenum, datestr, or datetime format.
% 
% [az,el] = sun_angle(t,lat,lon,h) specifies height above sea level in
% meters. If no height is specified, elevations are automatically
% determined via the CDT function topo_interp. 
% 
%% Examples
% For examples, type 
% 
%  cdt sun_angle 
% 
%% Source References:
% Solar Position obtained from: http://stjarnhimlen.se/comp/tutorial.html#5
% 
%% Revision History:
% Programed by Darin C. Koblick 2/17/2009
%
%              Darin C. Koblick 4/16/2013 Vectorized for Speed
%                                         Allow for MATLAB Datevec input in
%                                         addition to a t string.
%                                         Cleaned up comments and code to
%                                         avoid warnings in MATLAB editor.
%              
%              Chad A. Greene Feb 2019 optimized for performance and
%                                      changed Alt in km to height in m! 
%                                      Included edits by Serge Kharabash.
%
%% See also
% 
% See also solar_radiation, daily_insolation, and topo_interp. 

%% Error checks and input parsing: 

narginchk(3,4)
assert(islatlon(lat,lon),'Error: input coordinates are outside the range of normal lat,lon coordinates.') 

if nargin<4
   h = topo_interp(lat,lon); % a function in Climate Data Toolbox for Matlab. 
   h(h<0) = 0; 
end

%% Begin Code Sequence

Alt = h/1000; % original function had altitude in kilometers. 

d2r = pi/180; %radiance to degrees conversion factor
r2d = 180/pi; %radiance to degrees conversion factor

%julian date
[year,month,day,hour,min,sec] = datevec(t);
if ndims(t)>2 %#ok<ISMAT>
year = reshape(year ,size(t));
month = reshape(month,size(t));
day = reshape(day ,size(t));
hour = reshape(hour ,size(t));
min = reshape(min ,size(t));
sec = reshape(sec ,size(t));
end
[jd,UTH] = juliandate(year,month,day,hour,min,sec);
day = jd - 2451543.5;

%Keplerian elements for the Sun (geocentric)
w = 282.9404 + 4.70935e-5 * day; %longitude of perihelion degrees
e = 0.016709 - 1.151e-9 * day; %eccentricity
M = mod(356.0470 + 0.9856002585 * day, 360); %mean anomaly degrees
L = w + M; %Sun's mean longitude degrees
oblecl = (23.4393 - 3.563e-7 * day)*d2r; %Sun's obliquity of the ecliptic, rad

%auxiliary angle
E = M + r2d*e.*sin(M*d2r).*(1+e.*cos(M*d2r));

%rectangular coordinates in the plane of the ecliptic (x toward perhilion)
x = cos(E*d2r)-e;
year = sin(E*d2r).*sqrt(1-e.^2);

%distance and true anomaly
r = sqrt(x.^2 + year.^2);
v = atan2(year,x)*r2d;

%longitude of the sun
lon_sun = v + w;

%ecliptic rectangular coordinates
xeclip = r.*cos(lon_sun*d2r);
yeclip = r.*sin(lon_sun*d2r);
zeclip = 0;

%rotate to equitorial rectangular coordinates
xequat = xeclip;
yequat = yeclip.*cos(oblecl) + zeclip*sin(oblecl);
zequat = yeclip.*sin(0.409115648642983) + zeclip*cos(oblecl);

%convert to RA and Dec
r = sqrt(xequat.^2 + yequat.^2 + zequat.^2) - (Alt/149598000); %roll up the altitude correction
RA = atan2(yequat,xequat); %rad
delta = asin(zequat./r); %rad

%local siderial time
GMST0 = mod(L+180,360)/15;
SIDTIME = GMST0 + UTH + lon/15;

%replace RA with hour angle HA
HA = 15*SIDTIME - RA * r2d;

%convert to rectangular coordinate system
x = cos(HA*d2r).*cos(delta);
year = sin(HA*d2r).*cos(delta);
z = sin(delta);

%rotate along an axis going east-west
xhor = x.*cos((90-lat)*d2r) - z.*sin((90-lat)*d2r);
yhor = year;
zhor = x.*sin((90-lat)*d2r) + z.*cos((90-lat)*d2r);

%find Az and El
az = atan2(yhor,xhor) * r2d + 180;
el = asin(zhor) * r2d;

end

function [jd,UTH] = juliandate(year,month,day,hour,min,sec)
%calculate julian date & J2000 value
UTH = hour + min/60 + sec/3600; %J2000
idx = month <= 2;
year(idx) = year(idx) - 1;
month(idx) = month(idx) + 12;
jd = floor(365.25*(year+4716)) + floor(30.6001*(month+1)) + 2 - ...
floor(year/100) + floor(floor(year/100)/4) + day - 1524.5 + ...
UTH/24;
end