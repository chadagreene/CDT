function h = vfill(xl,xu,ColorSpec,varargin)
% vfill creates vertical filled regions on a plot. 
% 
%% Syntax
% 
%  vfill(xl,xu)
%  vfill(...,ColorSpec)
%  vfill(...,ColorSpec,'PatchProperty','PatchValue')
%  vfill(...,'bottom')
%  h = vfill(...)
% 
%% Description 
%
% vfill(xl,xu) creates a vertical shaded region between lower bounds
% xl and upper bounds xu. Inputs xl and xu must each contain 1 element
% per shaded region. 
%
% vfill(...,ColorSpec) defines the face color of the patch(es) created by
% vfill. ColorSpec can be one of the Matlab color names (e.g. 'red'),
% abbreviations (e.g. 'r', or rgb triplet (e.g. [1 0 0]). 
%
% vfill(...,ColorSpec,'PatchProperty','PatchValue') defines patch properties
% such as 'EdgeColor' and 'FaceAlpha'. 
% 
% vfill(...,'bottom') places the newly created patch(es) at the bottom of
% the uistack.  
%
% h = vfill(...) returns handle(s) of newly created patch objects. 
% 
%% Examples
% For examples, type 
% 
%  cdt vfill
% 
%% Author Info 
% This function was written by Chad A. Greene in 2013. Rewritten
% for CDT in 2018. 
%
% See also vline and hfill. 

%% Error Checks: 

narginchk(2,Inf) 
assert(numel(xl)==numel(xu),'Number of lower bounds xl must match the number of upper bounds xu.') 

%% Parse inputs: 

if nargin<3 
   ColorSpec = [0.0627    0.4784    0.6902]; 
end

% Set the patch at the bottom of the stack? 
tmp = strncmpi(varargin,'bottom',3); 
if any(tmp)
   plotbehind = true; 
   varargin = varargin(~tmp); 
else
   plotbehind = false; 
end

%% Mathematics and plotting: 

% Initial axis properties: 
yl = ylim; 
initialHoldState = ishold(gca);
hold on

% The y locations of each patch: 
y = [yl(1) yl(1) yl(2) yl(2) yl(1)]; 

% Plot each patch separately: 
for k = 1:numel(xu)
   x = [xl(k) xu(k) xu(k) xl(k) xl(k)]; 
   h(k) = fill(x,y,ColorSpec,varargin{:}); 
end

% Put it on the bottom if user asked for it this way: 
if plotbehind
    uistack(h,'bottom');
end

%%  Clean up: 

% Return hold state: 
if ~initialHoldState
    hold off;
end

if nargout==0
    clear h; 
end

end