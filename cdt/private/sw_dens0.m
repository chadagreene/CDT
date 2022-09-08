
function dens = sw_dens0(S,T)

% SW_DENS0   Denisty of sea water at atmospheric pressure
%=========================================================================
% SW_DENS0  $Id: sw_dens0.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%           Copyright (C) CSIRO, Phil Morgan 1992
%
% USAGE:  dens0 = sw_dens0(S,T)
%
% DESCRIPTION:
%    Density of Sea Water at atmospheric pressure using
%    UNESCO 1983 (EOS 1980) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (ITS-90)]
%
% OUTPUT:
%   dens0 = density  [kg/m^3] of salt water with properties S,T,
%           P=0 (0 db gauge pressure)
%
% AUTHOR:  Phil Morgan 92-11-05, Lindsay Pender (Lindsay.Pender@csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%     Unesco 1983. Algorithms for computation of fundamental properties of
%     seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%     Millero, F.J. and  Poisson, A.
%     International one-atmosphere equation of state of seawater.
%     Deep-Sea Res. 1981. Vol28A(6) pp625-629.
%=========================================================================

% Modifications
% 03-12-12. Lindsay Pender, Converted to ITS-90.

% CALLER: general purpose, sw_dens.m
% CALLEE: sw_smow.m

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=2
   error('sw_dens0.m: Must pass 2 parameters')
end %if

[mS,nS] = size(S);
[mT,nT] = size(T);

if (mS~=mT) | (nS~=nT)
   error('sw_dens0.m: S,T inputs must have the same dimensions')
end %if

%----------------------
% DEFINE CONSTANTS
%----------------------

T68 = T * 1.00024;

%     UNESCO 1983 eqn(13) p17.

b0 =  8.24493e-1;
b1 = -4.0899e-3;
b2 =  7.6438e-5;
b3 = -8.2467e-7;
b4 =  5.3875e-9;

c0 = -5.72466e-3;
c1 = +1.0227e-4;
c2 = -1.6546e-6;

d0 = 4.8314e-4;
dens = sw_smow(T) + (b0 + (b1 + (b2 + (b3 + b4*T68).*T68).*T68).*T68).*S  ...
                   + (c0 + (c1 + c2*T68).*T68).*S.*sqrt(S) + d0*S.^2;
return
%--------------------------------------------------------------------


