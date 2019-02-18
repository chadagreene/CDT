function h = hfill(yl,yu,ColorSpec,varargin)
% hfill creates horizontal filled regions on a plot. 
% 
%% Syntax
% 
%  hfill(yl,yu)
%  hfill(...,ColorSpec)
%  hfill(...,ColorSpec,'PatchProperty','PatchValue')
%  hfill(...,'bottom')
%  h = hfill(...)
% 
%% Description 
%
% hfill(yl,yu) creates a horizontal shaded region between lower bounds
% yl and upper bounds yu. Inputs yl and yu must each contain 1 element
% per shaded region. 
%
% hfill(...,ColorSpec) defines the face color of the patch(es) created by
% hfill. ColorSpec can be one of the Matlab color names (e.g. 'red'),
% abbreviations (e.g. 'r', or rgb triplet (e.g. [1 0 0]). 
%
% hfill(...,ColorSpec,'PatchProperty','PatchValue') defines patch properties
% such as 'EdgeColor' and 'FaceAlpha'. 
% 
% hfill(...,'bottom') places the newly created patch(es) at the bottom of
% the uistack.  
%
% h = hfill(...) returns handle(s) of newly created patch objects. 
% 
%% Examples
% For examples, type 
% 
%  cdt hfill
% 
%% Author Info 
% This function was written by Chad A. Greene in 2013. Rewritten
% for CDT in 2018. 
%
% See also hline and vfill. 

%% Error Checks: 

narginchk(2,Inf) 
assert(numel(yl)==numel(yu),'Number of lower bounds yl must match the number of upper bounds yu.') 

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
xl = xlim; 
initialHoldState = ishold(gca);
hold on

% The x locations of each patch: 
x = [xl(1) xl(2) xl(2) xl(1) xl(1)]; 

% Plot each patch separately: 
for k = 1:numel(yu)
   y = [yl(k) yl(k) yu(k) yu(k) yl(k)]; 
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