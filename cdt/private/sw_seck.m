
function K = sw_seck(S,T,P)

% SW_SECK    Secant bulk modulus (K) of sea water
%=========================================================================
% SW_SECK  $Id: sw_seck.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = sw_seck(S,T,P)
%
% DESCRIPTION:
%    Secant Bulk Modulus (K) of Sea Water using Equation of state 1980.
%    UNESCO polynomial implementation.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78) ]
%   T = temperature [degree C (ITS-90)]
%   P = pressure    [db]
%       (alternatively, may have dimensions 1*1 or 1*n where n is columns in S)
%
% OUTPUT:
%   K = Secant Bulk Modulus  [bars]
%
% AUTHOR:  Phil Morgan 92-11-05, Lindsay Pender (Lindsay.Pender@csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%    Eqn.(15) p.18
%
%    Millero, F.J. and  Poisson, A.
%    International one-atmosphere equation of state of seawater.
%    Deep-Sea Res. 1981. Vol28A(6) pp625-629.
%=========================================================================

% Modifications
% 99-06-25. Lindsay Pender, Fixed transpose of row vectors.
% 03-12-12. Lindsay Pender, Converted to ITS-90.

% CALLER: sw_dens.m
% CALLEE: none

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=3
   error('sw_seck.m: Must pass 3 parameters')
end %if

% CHECK S,T,P dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);
[mp,np] = size(P);


% CHECK THAT S & T HAVE SAME SHAPE
if (ms~=mt) | (ns~=nt)
   error('check_stp: S & T must have same dimensions')
end %if

% CHECK OPTIONAL SHAPES FOR P
if     mp==1  & np==1      % P is a scalar.  Fill to size of S
   P = P(1)*ones(ms,ns);
elseif np==ns & mp==1      % P is row vector with same cols as S
   P = P( ones(1,ms), : ); %   Copy down each column.
elseif mp==ms & np==1      % P is column vector
   P = P( :, ones(1,ns) ); %   Copy across each row
elseif mp==ms & np==ns     % PR is a matrix size(S)
   % shape ok
else
   error('check_stp: P has wrong dimensions')
end %if

%***check_stp

%--------------------------------------------------------------------
% COMPUTE COMPRESSION TERMS
%--------------------------------------------------------------------
P = P/10;  %convert from db to atmospheric pressure units
T68 = T * 1.00024;

% Pure water terms of the secant bulk modulus at atmos pressure.
% UNESCO eqn 19 p 18

h3 = -5.77905E-7;
h2 = +1.16092E-4;
h1 = +1.43713E-3;
h0 = +3.239908;   %[-0.1194975];

AW  = h0 + (h1 + (h2 + h3.*T68).*T68).*T68;

k2 =  5.2787E-8;
k1 = -6.12293E-6;
k0 =  +8.50935E-5;   %[+3.47718E-5];

BW  = k0 + (k1 + k2*T68).*T68;

e4 = -5.155288E-5;
e3 = +1.360477E-2;
e2 = -2.327105;
e1 = +148.4206;
e0 = 19652.21;    %[-1930.06];

KW  = e0 + (e1 + (e2 + (e3 + e4*T68).*T68).*T68).*T68;   % eqn 19

%--------------------------------------------------------------------
% SEA WATER TERMS OF SECANT BULK MODULUS AT ATMOS PRESSURE.
%--------------------------------------------------------------------
j0 = 1.91075E-4;

i2 = -1.6078E-6;
i1 = -1.0981E-5;
i0 =  2.2838E-3;

SR = sqrt(S);

A  = AW + (i0 + (i1 + i2*T68).*T68 + j0*SR).*S;


m2 =  9.1697E-10;
m1 = +2.0816E-8;
m0 = -9.9348E-7;

B = BW + (m0 + (m1 + m2*T68).*T68).*S;   % eqn 18

f3 =  -6.1670E-5;
f2 =  +1.09987E-2;
f1 =  -0.603459;
f0 = +54.6746;

g2 = -5.3009E-4;
g1 = +1.6483E-2;
g0 = +7.944E-2;

K0 = KW + (  f0 + (f1 + (f2 + f3*T68).*T68).*T68 ...
        +   (g0 + (g1 + g2*T68).*T68).*SR         ).*S;      % eqn 16

K = K0 + (A + B.*P).*P;  % eqn 15
return
%----------------------------------------------------------------------------


