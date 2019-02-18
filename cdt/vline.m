function h = vline(x,varargin)
% vline creates vertical lines on a plot. 
% 
%% Syntax 
% 
%  vline(x) 
%  vline(x,LineSpec) 
%  vline(...,'Name',Value,...)
%  h = vline(...)
% 
%% Description
% 
% vline(x) plots vertical lines at the locations x. 
%
% vline(x,LineSpec) sets the line style, marker symbol, and color.
% 
% vline(...,'Name',Value,...) specifies line properties using one or more 
% Name,Value pair arguments. For a list of properties, see Line Properties. 
% Use this option with any of the input argument combinations in the previous 
% syntaxes.
% 
% h = vline(...) returns a handle h of the plotted lines. 
% 
%% Examples 
% For examples, type 
% 
%  cdt vline
%
%% Author Info
% This function and supporting documentation were written by Chad A.
% Greene, 2018. 
% 
% See also vfill and hline. 

%% Error checks: 

narginchk(1,Inf) 
assert(isnumeric(x),'Input x must be numeric.')

%% Special adjustments: 
% For the case where x is two elements, the plot function will interpret as "draw a diagonal 
% line", so here we make it three elements: 

if numel(x)==2
   x = [x(:);NaN]; 
end

%% Plot: 

% Check initial hold state: 
ish = ishold; 
if ~ish
   hold on; 
end

h = plot(repmat(x(:),[1 2]),ylim,varargin{:}); 

%% Clean up: 

% Return hold state to the way we found it: 
if ~ish
  hold off; 
end

if nargout==0
   clear h
end

end