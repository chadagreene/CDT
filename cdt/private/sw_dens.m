
function dens = sw_dens(S,T,P)

% SW_DENS    Density of sea water
%=========================================================================
% SW_DENS  $Id: sw_dens.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = sw_dens(S,T,P)
%
% DESCRIPTION:
%    Density of Sea Water using UNESCO 1983 (EOS 80) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (ITS-90)]
%   P = pressure    [db]
%       (P may have dims 1x1, mx1, 1xn or mxn for S(mxn) )
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
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%    Millero, F.J., Chen, C.T., Bradshaw, A., and Schleicher, K.
%    " A new high pressure equation of state for seawater"
%    Deap-Sea Research., 1980, Vol27A, pp255-264.
%=========================================================================

% Modifications
% 99-06-25. Lindsay Pender, Fixed transpose of row vectors.
% 03-12-12. Lindsay Pender, Converted to ITS-90.

% CALLER: general purpose
% CALLEE: sw_dens0.m sw_seck.m

% UNESCO 1983. eqn.7  p.15

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=3
   error('sw_dens.m: Must pass 3 parameters')
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

%------
% BEGIN
%------
densP0 = sw_dens0(S,T);
K      = sw_seck(S,T,P);
P      = P/10;  % convert from db to atm pressure units
dens   = densP0./(1-P./K);
return
%--------------------------------------------------------------------


