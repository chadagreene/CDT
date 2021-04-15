
function pden = sw_pden(S,T,P,PR)

% SW_PDEN    Potential density
%===========================================================================
% SW_PDEN  $Id: sw_pden.m,v 1.1 2003/12/12 04:23:22 pen078 Exp $
%          Copyright (C) CSIRO, Phil Morgan  1992.
%
% USAGE:  pden = sw_pden(S,T,P,PR)
%
% DESCRIPTION:
%    Calculates potential density of water mass relative to the specified
%    reference pressure by pden = sw_dens(S,ptmp,PR).
%
% INPUT:  (all must have same dimensions)
%   S  = salinity    [psu      (PSS-78) ]
%   T  = temperature [degree C (ITS-90)]
%   P  = pressure    [db]
%   PR = Reference pressure  [db]
%       (P may have dims 1x1, mx1, 1xn or mxn for S(mxn) )
%
% OUTPUT:
%   pden = Potential denisty relative to the ref. pressure [kg/m^3]
%
% AUTHOR:  Phil Morgan 1992/04/06, Lindsay Pender (Lindsay.Pender@csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%   A.E. Gill 1982. p.54
%   "Atmosphere-Ocean Dynamics"
%   Academic Press: New York.  ISBN: 0-12-283522-0
%=========================================================================

% Modifications
% 03-12-12. Lindsay Pender, Converted to ITS-90.

% CALLER:  general purpose
% CALLEE:  sw_ptmp.m sw_dens.m

%-------------
% CHECK INPUTS
%-------------
if nargin ~= 4
   error('sw_pden.m: Must pass 4 parameters ')
end %if

% LET sw_ptmp.m DO DIMENSION CHECKING

%------
% BEGIN
%------
ptmp = sw_ptmp(S,T,P,PR);
pden = sw_dens(S,ptmp,PR);

return
%=========================================================================


