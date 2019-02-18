function h = hline(y,varargin)
% hline creates horizontal lines on a plot. 
% 
%% Syntax 
% 
%  hline(y) 
%  hline(y,LineSpec) 
%  hline(...,'Name',Value,...)
%  h = hline(...)
% 
%% Description
% 
% hline(y) plots horizontal lines at the locations y. 
%
% hline(y,LineSpec) sets the line style, marker symbol, and color.
% 
% hline(...,'Name',Value,...) specifies line properties using one or more 
% Name,Value pair arguments. For a list of properties, see Line Properties. 
% Use this option with any of the input argument combinations in the previous 
% syntaxes.
% 
% h = hline(...) returns a handle h of the plotted lines. 
% 
%% Examples 
% For examples, type 
% 
%  cdt hline
%
%% Author Info
% This function and supporting documentation were written by Chad A.
% Greene, 2018. 
% 
% See also hfill and vline. 

%% Error checks: 

narginchk(1,Inf) 
assert(isnumeric(y),'Input y must be numeric.')

%% Special adjustments: 
% For the case where x is two elements, the plot function will interpret as "draw a diagonal 
% line", so here we make it three elements: 

if numel(y)==2
   y = [y(:);NaN]; 
end

%% Plot: 

% Check initial hold state: 
ish = ishold; 
if ~ish
   hold on; 
end

h = plot(xlim,repmat(y(:),[1 2]),varargin{:}); 

%% Clean up: 

% Return hold state to the way we found it: 
if ~ish
  hold off; 
end

if nargout==0
   clear h
end

end