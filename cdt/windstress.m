function varargout = windstress(u10,varargin)
% windstress estimates wind stress on the ocean from wind speed.
% 
%% Syntax 
% 
%  Tau = windstress(u10)
%  [Taux,Tauy] = windstress(u10,v10)
%  [...] = windstress(...,'Cd',Cd) 
%  [...] = windstress(...,'ci',seaIce) 
%  [...] = windstress(...,'rho',airDensity)
% 
%% Description 
% 
% Tau = windstress(u10) estimates the wind stress (in pascals) imparted on the ocean by the wind speed
% (in meters per second) 10 m above the surface. Output Tau is the same size as input u10. 
% 
% [Taux,Tauy] = windstress(u10,v10) simultaneously computes zonal and meridional components of wind stress.
% 
% [...] = windstress(...,'Cd',Cd) specifies a coefficient of friction Cd. Default Cd is 1.25e-3, which is a 
% global average (Kara et al., 2007) but in reality Cd can vary quite a bit in space and time. Cd can be a 
% scalar or a vector, 2D matrix, or 3D matrix the same size as u10 (and v10 if v10 is included). 
% 
% [...] = windstress(...,'ci',seaIce) specifies sea ice concentration for estimation of Cd as given by Lüpkes
% and Birnbaum, 2005. Input seaIce is a fraction of sea ice cover and must be in the range 0 to 1 inclusive. 
% seaIce can be a scalar or a vector, 2D matrix, or 3D matrix the same size as u10 (and v10 if v10 is included). 
% 
% [...] = windstress(...,'rho',airDensity) specifies air density, which can be a scalar or a vector, 2D matrix, 
% or 3D matrix the same size as u10 (and v10 if v10 is included). Default value of rho is 1.225 kg/m^3. 
% 
%% Examples
% For examples type 
% 
%    cdt windstress
%
%% References 
% 
% Kara, A. Birol, et al. "Wind stress drag coefficient over the global ocean." Journal of Climate 20.23 (2007): 5856-5864.
% http://dx.doi.org/10.1175/2007JCLI1825.1.
% 
% Lüpkes, Christof, and Gerit Birnbaum. "Surface drag in the Arctic marginal sea-ice zone: a comparison of different 
% parameterisation concepts." Boundary-layer meteorology 117.2 (2005): 179-211. http://dx.doi.org/10.1007/s10546-005-1445-8.
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at Austin
% Institute for Geophysics (UTIG), 2013. 
% http://www.chadagreene.com 
% 
% See also: ekman and cdtcurl. 

%% Set defaults: 

Cd = 1.25e-3; % Drag coefficient, a global average from Kara et al., 2007 (http://dx.doi.org/10.1175/2007JCLI1825.1)
rho = 1.225;  % density of air in kg/m^3
ice = false;  % No sea ice unless user says so. 

%% Parse inputs: 

narginchk(1,inf) 
if nargout==2
   assert(isnumeric(varargin{1})==1,'Error: If you request two outputs from windstress, the second input must be v10, which must be the same size as u10.')
   assert(isequal(size(u10),size(varargin{1}))==1,'Error: If you request two outputs from windstress, the second input must be v10, which must be the same size as u10.')
   v10 = varargin{1}; 
end

if nargin>1 
   
   % One more error check just to be sure: 
   if isnumeric(varargin{1})
      assert(nargout==2,'Error: You have entered v10, but you are not requesting Tauy as an output--that is strange. Perhaps there''s been some sort of mistake?') 
   end
   
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
   
   % Check for user-defined drag coefficient: 
   tmp = strcmpi(varargin,'Cd'); 
   if any(tmp) 
      Cd = varargin{find(tmp)+1}; 
      assert(isnumeric(Cd)==1,'Input error: Drag coefficient must be numeric.') 
      assert(ice==false,'Input error: You cannot enter a drag coefficient value and also a sea ice concentration by which to calculate the drage coefficient. Pick one and try again.')  
   end
   
   % Check for user-defined air density: 
   tmp = strcmpi(varargin,'rho'); 
   if any(tmp) 
      rho = varargin{find(tmp)+1}; 
      assert(isnumeric(rho)==1,'Input error: Air density rho must be numeric.') 
   end
   
end

%% Calculate wind stress: 

switch nargout 
   case {0,1} 
      varargout{1} = rho.*Cd.*sign(u10).*u10.^2; 
      
   case 2
      U = hypot(u10,v10); 
      
      Tau = rho.*Cd.*(u10.^2 + v10.^2); 
      
      % Taux: 
      varargout{1} = Tau.*u10./U; 
   
      % Tauy: 
      varargout{2} =  Tau.*v10./U; 
   
   otherwise
      
end


end








%% SUBFUNCTIONS 

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
