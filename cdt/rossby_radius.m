function Lr = rossby_radius(lat,varargin)
% rossby_radius gives the Rossby radius of deformation for a barotropic ocean. 
% 
%% Syntax
% 
%  Lr = rossby_radius(lat,lon)
%  Lr = rossby_radius(lat,'depth',D)
%  Lr = rossby_radius(...,'rot',rot)
%  Lr = rossby_radius(...,'g',gravity)
% 
%% Description
% 
% Lr = rossby_radius(lat,lon) computes the barotropic Rossby radius of deformation in the ocean at the 
% geo coordinates lat,lon. The Rossby radius calculation depends on ocean depth, which is 
% automatically determined via the topo_interp function. 
% 
% Lr = rossby_radius(lat,'depth',D) overrides automatic calculation of ocean depth by
% entering depths D, which can be scalar or the same size as lat. Depths should be
% positive. 
% 
% Lr = rossby_radius(...,'rot',rot) specifies a rate of rotation. By default, rot is Earth's 
% present-day rate of rotation 7.2921 x 10^-5 rad/s, but a different rate may be specified 
% to model Earth at a different time, other celestial bodies.
% 
% Lr = rossby_radius(...,'g',gravity) specifies the gravitational rate of acceleration.
% Default is value is 9.81. 
% 
%% Author Info
% This function and supporting documentation were written by Chad A. Greene for 
% the Climate Data Toolbox for Matlab. 
% 
% See also: coriolisf, cdtdim, and cdtgradient. 

%% Initial error checks: 

narginchk(2,7)
assert(max(abs(lat(:)))<=90,'Latitude value(s) out of realistic bounds. Check inputs and try again.')

%% Parse inputs: 

% Is the first input longitude? 
if isnumeric(varargin{1})
   lon = varargin{1}; 
   assert(islatlon(lat,lon),'Error: I am interpreting the first two inputs as geo coordinates, but they are out of the normal range of geo coordinates.') 
   assert(isequal(size(lat),size(lon)),'Error: Dimensions of lat and lon must agree.') 
   
   % Depth is negative elevation: 
   D = -topo_interp(lat,lon); 
   D(D<0) = NaN; % Make Land undefined
   
else % if the first varargin input isn't longitude, ensure D is specified: 
   tmp = strncmpi(varargin,'depth',1); 
   if any(tmp)
      D = varargin{find(tmp)+1}; 
      assert(isnumeric(D),'Error: Depth D must be numeric.') 
      
   else % if first varargin wasn't lon, and D wasn't specified, throw an error: 
      error('Either a longitude or depth D must be specified.')
   end
   
end

% Planetary rate of rotation:
tmp = strncmpi(varargin,'rotation',3); 
if any(tmp)
   rot = varargin{find(tmp)+1}; 
else
   rot = 7.2921e-5; 
end

% gravity: 
tmp = strcmpi(varargin,'g'); 
if any(tmp)
   g = varargin{find(tmp)+1}; 
else
   g = 9.81;
end

%% Calculate things: 

% The coriolis parameter: 
f = coriolisf(lat,rot); 

% The Rossby radius of deformation: 
Lr = ((g.*D).^(0.5))./abs(f); 

end