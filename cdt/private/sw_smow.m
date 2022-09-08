
function dens = sw_smow(T)

% SW_SMOW    Denisty of standard mean ocean water (pure water)
%=========================================================================
% SW_SMOW  $Id: sw_smow.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = sw_smow(T)
%
% DESCRIPTION:
%    Denisty of Standard Mean Ocean Water (Pure Water) using EOS 1980.
%
% INPUT:
%   T = temperature [degree C (ITS-90)]
%
% OUTPUT:
%   dens = density  [kg/m^3]
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
%     UNESCO 1983 p17  Eqn(14)
%
%     Millero, F.J & Poisson, A.
%     INternational one-atmosphere equation of state for seawater.
%     Deep-Sea Research Vol28A No.6. 1981 625-629.    Eqn (6)
%=========================================================================

% Modifications
% 99-06-25. Lindsay Pender, Fixed transpose of row vectors.
% 03-12-12. Lindsay Pender, Converted to ITS-90.

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
% TEST INPUTS
if nargin ~= 1
   error('sw_smow.m: Only one input argument allowed')
end %if

%----------------------
% DEFINE CONSTANTS
%----------------------
a0 = 999.842594;
a1 =   6.793952e-2;
a2 =  -9.095290e-3;
a3 =   1.001685e-4;
a4 =  -1.120083e-6;
a5 =   6.536332e-9;

T68 = T * 1.00024;
dens = a0 + (a1 + (a2 + (a3 + (a4 + a5*T68).*T68).*T68).*T68).*T68;
return
%--------------------------------------------------------------------


