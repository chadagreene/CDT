function varargout = ekman(lat,lon,u10,v10,varargin) 
% ekman estimates the classical Ekman transport and upwelling/downwelling from 10 m winds. 
% 
%% Syntax
% 
%  [UE,VE,wE] = ekman(lat,lon,u10,v10)
%  [UE,VE,wE] = ekman(...,'Cd',Cd)
%  [UE,VE,wE] = ekman(...,'ci',seaIce)
%  [UE,VE,wE] = ekman(...,'rho',waterDensity)
%  [UE,VE,wE,dE] = ekman(...)
% 
%% Description 
% 
% [UE,VE,wE] = ekman(lat,lon,u10,v10) estimates the zonal (UE, m^2/s) and meridional (VE, m^2/s)  
% Ekman layer transports along with vertical velocities (wE, m/s) associated with Ekman pumping. 
% Positive values of wE indicate upwelling. Inputs lat and lon must be 2D grids whose dimensions 
% zonal (u10, m/s) and meridional (v10, m/s) wind speeds taken 10 m above the surface. Wind speeds
% are automatically converted to wind stress before performing the Ekman transport calculations. 
% Inputs u10 and v10 can be 2D grids the same size as lat and lon, or they can be 3D matrices whose
% first two dimensions correspond to lat and lon, with a third dimension corresponding to time.  
% 
% [UE,VE,wE] = ekman(...,'Cd',Cd) specifies a drag coefficient for wind stress calculation. Cd can 
% be a scalar or a matrix whose dimensions match u10 and v10. Default Cd is 1.25e-3. 
% 
% [UE,VE,wE] = ekman(...,'ci',seaIce) specifies sea ice concentration for estimation of Cd as given by Lüpkes
% and Birnbaum, 2005. Input seaIce is a fraction of sea ice cover and must be in the range 0 to 1 inclusive. 
% seaIce can be a scalar or a vector, 2D matrix, or 3D matrix the same size as u10 and v10.
% 
% [UE,VE,wE] = ekman(...,'rho',waterDensity) specifies water density. Default is 1025 kg/m3. 
% 
% [UE,VE,wE,dE] = ekman(...) also gives an approximate Ekman layer depth dE. 
% 
%% Examples 
% For examples type 
% 
%   cdt ekman
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG), February 2017. 
% http://www.chadagreene.com
% 
% See also: geocurl and geodim. 

%% Initial error checks: 

narginchk(4,inf) 
assert(isequal(size(u10),size(v10))==1,'Input error: Dimensions of u10 and v10 must agree.') 
assert(islatlon(lat,lon)==1,'Input error: lat and/or lon values appear to exceed the normal range of geo coordinates.') 
assert(isvector(lat)==0,'Input error: lat and lon must be 2D grids, not vectors. Use meshgrid to make a 2D grid.') 
assert(isequal(size(lat),size(lon))==1,'Input error: Dimensions of lat and lon must agree.') 
assert(isequal(size(lat),[size(u10,1) size(u10,2)])==1,'Input error: The dimensions of wind field must match the dimensions of lat and lon.')
assert(numel(lat)>3,'Input error: The grid should have more than a few points.') 

if any(abs(lat(:))<10)
   warning('You have included some data points within 10 degrees of the equator. Some folks say Ekman is invalid within 10 degrees of the equator, others say Ekman''s formulas work as close as two or three degrees from the equator. There is no clearly defined cutoff latitude, but the issue is that Ekman divides by the Coriolis frequency, which approaches zero at the equator.')
end

%% Set defaults: 

Cd = 1.25e-3; 
rho = 1025; 
ice = false; % no sea ice present unless user says so.

%% Check for user-defined preferences: 

if nargin>4
   
   % Check for user-defined sea ice concentration: 
   tmp = strcmpi(varargin,'ci'); 
   if any(tmp) 
      ice = true; 
      ci = varargin{find(tmp)+1}; 
      assert(isnumeric(ci)==1,'Input error: sea ice concentration must be numeric.') 
      assert(max(ci(:))<=1,'Input error: sea ice concentration cannot exceed 1.') 
      assert(min(ci(:))>=0,'Input error: sea ice cannot have an negative concentration values.') 
      Cd = Cd_ice(ci); % This is a subfunction below which calculates Cd by Lüpkes and Birnbaum, 2005. 
   end
   
   % Check for drag coefficient: 
   tmp = strcmpi(varargin,'Cd'); 
   if any(tmp) 
      Cd = varargin{find(tmp)+1}; 
      assert(ice==false,'Input error: If you enter sea ice concentration you cannot also specify a drag coefficient. Pick one and try again.')
   end
   
   % Check for water density: 
   tmp = strcmpi(varargin,'rho'); 
   if any(tmp) 
      rho = varargin{find(tmp)+1}; 
   end
end

%% Calculate Ekman layer depth if user wants it: 

if nargout==4 
   
   % The following is from Eqn 9.16 of Introduction to Physical Oceanography, Robert H. Stewart, September 2008. 
   varargout{4} = 7.6*hypot(u10,v10)./repmat(sqrt(sind(abs(lat))),[1 1 size(u10,3)]); 
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
   u10 = permute(u10,[2 1 3]); 
   v10 = permute(v10,[2 1 3]); 
   Cd = permute(Cd,[2 1 3]); 
   rho = permute(rho,[2 1 3]); 
   permutedims = true; 
else
   error('Unrecognized lat,lon grid type. It should be monotonic, like it was created by meshgrid.') 
end

%% Calculate parameters for the input grid: 

% Grid dimensions: 
[dx,dy] = cdtdim(lat,lon); 

% Coriolis frequency: 
f = coriolisf(lat); 

% Estimate wind stress based on 10 m wind speed and drag coefficient:
[Taux,Tauy] = windstress(u10,v10,'Cd',Cd); 

%% Compute Ekman transports:
 
% Zonal and meridional components: 
UE = bsxfun(@rdivide,Tauy,(rho.*f)); % m^2/s
VE = bsxfun(@rdivide,-Taux,(rho.*f)); % m^2/s
          
% Only compute vertical velocity if user wants it: 
if nargout~=2 
   
   % Preallocate curlz
   wE = nan(size(UE)); 
   
   % Solve curl for each slice in dimension 3: 
   for k = 1:size(UE,3)
      [~,dVdy] = gradient(VE(:,:,k)./dy);
      [dUdx,~] = gradient(UE(:,:,k)./dx);
      wE(:,:,k) =  dUdx+dVdy; % m/s
   end
   
end

%% Return to original grid orientation if we changed it: 

if permutedims 
   UE = ipermute(UE,[2 1 3]); 
   VE = ipermute(VE,[2 1 3]); 
   if nargout>2
      wE = ipermute(wE,[2 1 3]); 
   end
end

%% Package up the outputs: 

switch nargout
   case {0,1} 
      varargout{1} = wE; 
      
   case 2
      varargout{1} = UE; 
      varargout{2} = VE; 

   case {3,4}
      varargout{1} = UE; 
      varargout{2} = VE; 
      varargout{3} = wE; 
      
   otherwise 
      error('Unrecognized outputs. But I can''t even imagine how we got here.')
end

end




%% Subfunctions 

function [ Cdn10e ] = Cd_ice(SeaIceConcentration)
% Cd_ice estimates drag coefficient on sea ice resulting from 10 m winds. This
% model is from Lüpkes and Birnbaum, 2005. 
% 
% Enter Sea Ice Concentration (fraction) and get a coefficient of drag in
% return.  
% 
% Chad Greene, September 26, 2013.   
% 
% See also windstress.

A = SeaIceConcentration; % sea ice concentration 
A(A>1) = 1; 
hf = .49*(1-exp(-.59.*A)); % Eq 20
Di = 31*hf./(1-A); % Eq 21
ar = Di./hf; % aspect ratio from Eq 22

Cdn10i = 1.89e-3; % constants used in text 
Cdn10w = 1.25e-3;

Cdn10e = (.34*A.^2).*(((1-A).^.8 + .5*(1-.5*A).^2)./(ar+90*A)) + A.*Cdn10i + (1-A).*Cdn10w;

% The equation above blows up in Matlab where A=0 (no sea ice present), but equation 22
% of lupkes2005surface indicates that when A=0, the equation reduces to the last term. 
% In other words, evaluating the Equation 22 by hand we'd be left with just the last term, 
% but Matlab sends the the whole solution to NaN if the first two terms are included when 
% A=0, so let's just set it manually, and include a little wiggle room for numerical noise: 

Cdn10e(A<0.001) = Cdn10w; 

end
