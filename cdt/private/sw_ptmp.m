
function PT = sw_ptmp(S,T,P,PR)

% SW_PTMP    Potential temperature
%===========================================================================
% SW_PTMP  $Id: sw_ptmp.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  ptmp = sw_ptmp(S,T,P,PR)
%
% DESCRIPTION:
%    Calculates potential temperature as per UNESCO 1983 report.
%
% INPUT:  (all must have same dimensions)
%   S  = salinity    [psu      (PSS-78) ]
%   T  = temperature [degree C (ITS-90)]
%   P  = pressure    [db]
%   PR = Reference pressure  [db]
%        (P & PR may have dims 1x1, mx1, 1xn or mxn for S(mxn) )
%
% OUTPUT:
%   ptmp = Potential temperature relative to PR [degree C (ITS-90)]
%
% AUTHOR:  Phil Morgan 92-04-06, Lindsay Pender (Lindsay.Pender@csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%    Eqn.(31) p.39
%
%    Bryden, H. 1973.
%    "New Polynomials for thermal expansion, adiabatic temperature gradient
%    and potential temperature of sea water."
%    DEEP-SEA RES., 1973, Vol20,401-408.
%=========================================================================

% Modifications
% 99-06-25. Lindsay Pender, Fixed transpose of row vectors.
% 03-12-12. Lindsay Pender, Converted to ITS-90.

% CALLER:  general purpose
% CALLEE:  sw_adtg.m

%-------------
% CHECK INPUTS
%-------------
if nargin ~= 4
   error('sw_ptmp.m: Must pass 4 parameters ')
end %if

% CHECK S,T,P dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);
[mp,np] = size(P);

[mpr,npr] = size(PR);


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
[mp,np] = size(P);


% CHECK OPTIONAL SHAPES FOR PR
if     mpr==1  & npr==1      % PR is a scalar.  Fill to size of S
   PR = PR(1)*ones(ms,ns);
elseif npr==ns & mpr==1      % PR is row vector with same cols as S
   PR = PR( ones(1,ms), : ); %   Copy down each column.
elseif mpr==ms & npr==1      % P is column vector
   PR = PR( :, ones(1,ns) ); %   Copy across each row
elseif mpr==ms & npr==ns     % PR is a matrix size(S)
   % shape ok
else
  error('check_stp: PR has wrong dimensions')
end %if

%***check_stp

%------
% BEGIN
%------

% theta1
del_P  = PR - P;
del_th = del_P.*sw_adtg(S,T,P);
th     = T * 1.00024 + 0.5*del_th;
q      = del_th;

% theta2
del_th = del_P.*sw_adtg(S,th/1.00024,P+0.5*del_P);
th     = th + (1 - 1/sqrt(2))*(del_th - q);
q      = (2-sqrt(2))*del_th + (-2+3/sqrt(2))*q;

% theta3
del_th = del_P.*sw_adtg(S,th/1.00024,P+0.5*del_P);
th     = th + (1 + 1/sqrt(2))*(del_th - q);
q      = (2 + sqrt(2))*del_th + (-2-3/sqrt(2))*q;

% theta4
del_th = del_P.*sw_adtg(S,th/1.00024,P+del_P);
PT     = (th + (del_th - 2*q)/6)/1.00024;
return
%=========================================================================

