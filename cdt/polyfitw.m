function [p,S,mu] = polyfitw(x,y,n,w)
% polyfitw computes weighted polynomial fits. 
% 
%% Syntax
% 
%  p = polyfitw(x,y,n) 
%  p = polyfitw(x,y,n,w) 
%  [p,S,mu] = polyfitw(...)
%
%% Description  
% 
% p = polyfitw(x,y,n) calculates the *unweighted* polynomial fit of 
% x vs y to the nth order, exactly like polyfit. 
% 
% p = polyfitw(x,y,n,w) specifies weights to apply to each y value. For 
% measurements whose formal error estimates are given by err, try using 
% weights w = 1/err.^2.  
% 
% [p,S,mu] = polyfitw(...) returns the S structure and centering/scaling 
% values mu for use in polyval. Don't forget, if you return more than one
% output (meaning [p,S,mu] instead of just p), the values in p will be 
% scaled according to the values in mu. 
%
%% Examples 
% For examples, type 
% 
%   cdt polyfitw
% 
%% Author Info 
% Adapted from polyfit3 (Antoni J. Canos, 12-15-03) by Chad A. 
% Greene, April 2019. One big change: I now take the square root
% of the weights, because I think that's the correct way to do it. 
% 
% See also: polyval, polyfit. 

%% Input checks: 

narginchk(3,4)
assert(isscalar(n),'Input n must be a scalar.') 
assert(isequal(size(x),size(y)),'X and Y vectors must be the same size.')

if nargin<4
   w = ones(size(x));
else
   assert(isequal(size(x),size(w)),'Weights array must match dimensions of x and y.') 
end

%% Normalize and scale: 

% Columnate inputs x and y: 
x = x(:);
y = y(:);

% normalize and columnate weights:
w = sqrt(w(:)./mean(w)); % Taking square root, because I think this might be right? 

if nargout > 2
   mu = [mean(x); std(x)];
   x = (x - mu(1))/mu(2);
end

%% 

% Construct the Vandermonde matrix V = [x.^n ... x.^2 x ones(size(x))]
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
    V(:,j) = x.*V(:,j+1);
end

% Construct Weighted Vandermonde matrix.
% rewrite suggested by Andrey Kan: 
W = repmat(w, 1, size(V, 2));
WV=W.*V;
Wy=w.*y;

% Solve least squares problem, and save the Cholesky factor.
[Q,R] = qr(WV,0);
ws = warning('off'); 
p = R\(Q'*Wy);    % Same as p = WV\Wy;
warning(ws);

if size(R,2) > size(R,1)
   warning('Polynomial is not unique; degree >= number of data points.')
elseif condest(R) > 1.0e10
    if nargout > 2
        warning(sprintf( ...
            ['Polynomial is badly conditioned. Remove repeated data points.']))
    else
        warning(sprintf( ...
            ['Polynomial is badly conditioned. Remove repeated data points\n' ...
                '         or try centering and scaling as described in HELP POLYFIT.']))
    end
end
 
if nargout>1
   [~,R] = qr(W.*V,0);
   % S is a structure containing three elements: the Cholesky factor of the
   % Vandermonde matrix, the degrees of freedom and the norm of the residuals.
   S.R = R;
   S.df = max(0,length(y) - (n+1));
   
   r = sqrt(w).*(y - V*p);

   S.normr = norm(r);
end

p = p.';         % Polynomial coefficients are row vectors by convention.

end