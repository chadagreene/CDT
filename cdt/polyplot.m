function [h,p,delta] = polyplot(x,y,varargin) 
% polyplot plots a polynomial fit to scattered x,y data. This function
% can be used to easily add a linear trend line or other polynomial 
% fit to a data plot. 
% 
%% Syntax
%
%  polyplot(x,y)
%  polyplot(x,y,n)
%  polyplot(...,'weight',w)
%  polyplot(...,'Name',Value,...)
%  polyplot(...,'error')
%  h = polyplot(...)
% 
%% Description 
% 
% polyplot(x,y) places a least-squares linear trend line through 
% scattered x,y data. 
%
% polyplot(x,y,n) specifies the degree n of the polynomial fit to 
% the x,y data. Default n is 1. 
%
% polyplot(...,'weight',w) uses the polyfitw function to allow for 
% weighted least squares fits. 
% 
% polyplot(...,'Name',Value,...) formats linestyle using LineSpec 
% property name-value pairs ('e.g., 'linewidth',3). If 'error' bounds are 
% plotted, only boundedline properties are accepted. 
% 
% polyplot(...,'error') includes lines corresponding to approximately
% +/- 1 standard deviation of errors delta. At least 50% of data should 
% lie within the bounds of error lines. Error bounds are plotted with boundedline. 
%
% h = polyplot(...) returns handle(s) h of plotted objects.
% 
%% Examples 
% For examples, type 
% 
%  cdt polyplot
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas
% Institute for Geophysics (UTIG) in Austin, Texas, January 2015. 
% http://www.chadagreene.com
% 
% See also plot, polyfit, polyval, and plotpsd. 

%% Error checks: 

assert(numel(x)==numel(y),'Number of elements in x must equal number of elements in y.') 
assert(isnumeric(y)==1,'Input y must be numeric.') 

if isdatetime(x)
   isd = true; 
   x = datenum(x); 
else
   assert(isnumeric(x)==1,'Input x must be numeric.') 
   isd = false; 
end

%% Set Defaults: 

n = 1;                        % degree of the polynomial
xfit = [min(x(:)) max(x(:))]; % x values for fit (only two points necessary for default linear case) 
ploterror = false;            % do not plot shaded error region
weighted = false;             % Not a weighted polyfit by default. 

%% Parse optional inputs: 

if nargin>2
   if isscalar(varargin{1}) 
      % assume it's the order of the fit
      n = varargin{1}; 
      assert(mod(n,1)==0,'Polynomial degree n must be an integer.')
      assert(n>=0,'Polynomial degree n cannot be negative.')
      varargin(1)=[]; 
      xfit = linspace(min(x),max(x),1024); 
   end

   tmp = strncmpi(varargin,'err',3); 
   if any(tmp)
      ploterror = true; 
      varargin = varargin(~tmp); 
   end

   tmp = strncmpi(varargin,'weight',3); 
   if any(tmp)
      weighted = true; 
      w = varargin{find(tmp)+1}; 
      tmp(find(tmp)+1) = true; 
      varargin = varargin(~tmp); 
   end
end

%% Do mathematics:

% indices of finite data:
ind = isfinite(y); 

% Columnate inputs and limit to data with finite y values to ensure polyfit will work: 
x = x(ind); 
y = y(ind); 

% Get the least-squares polynomial fit: 
if weighted
   w = w(ind); 
   [p,S,mu] = polyfitw(x,y,n,w);
else 
   [p,S,mu] = polyfit(x,y,n);
end
[yfit,delta] = polyval(p,xfit,S,mu);

%% Plot: 

% If input was datetime, convert back now: 
if isd
   xfit = datetime(xfit,'ConvertFrom','datenum'); 
end

% Plot fit +/- 1 standard deviation of error: 
if ploterror
   % boundedline probably will not work for datetime axes yet. Not until patch objects start getting along with datetime axes.
   [h(1),h(2)] = boundedline(xfit,yfit,delta,varargin{:}); 
else 
   h = plot(xfit,yfit,varargin{:}); 
end

%% Clean up: 

if nargout==0
    clear h; 
end

end