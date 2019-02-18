function [h_trans,h_marker,h_bed] = transect(x,d,v,varargin)
% transect produces a color-scaled transect diagram of oceanographic data 
% from CTD profiles collected at different locations and/or times.  
% 
%% Syntax 
% 
%  transect(x,d,v)
%  transect(...,'LineProperty',Value)
%  transect(...,'bed',BedDepth)
%  transect(...,'bedcolor',ColorSpec)
%  transect(...,'extrap')
%  transect(...,'interp','InterpMethod)
%  transect(...,'di',di)
%  transect(...,'xi',xi)
%  [h_trans,h_marker,h_bed] = transect(...)
% 
%% Description 
% 
% transect(x,d,v) creates a color-scaled transect diagram of the variable v
% at the horizontal locations (or times) x and depths d. x must be a numeric
% array of values indicating the locations or times of each CTD profile. Inputs
% d and v must each be cell arrays containing depths and measurements at each
% CTD location. 
% 
% transect(...,'LineProperty',Value) sets the line or marker style for each 
% datapoint. By default, each datapoint is indicated by a black dot, but profiles
% can just as easily be indicated with differenty marker types or lines of 
% specified color, style, thickness, etc. 
% 
% transect(...,'bed',BedDepth) specifies bed depths to create a patch object
% indicating the bed profile along the transect. 
% 
% transect(...,'bedcolor',ColorSpec) specifies color of the bed. Default bedcolor
% is black. 
% 
% transect(...,'extrap') turns on the option to extrapolate beyond the extents
% of data. By default, transect does not extrapolate, but the option is available
% to fill in gaps, such as between lowest datapoint and the seabed. 
% 
% transect(...,'interp','InterpMethod) specifies an interpolation method (see
% the Methods section below). Default is 'linear'.
% 
% transect(...,'di',di) specifies interpolation depths di. By default, transect 
% creates a grid by interpolating to 1000 equally-spaced depths between the 
% shallowest and deepest measurement. 
% 
% transect(...,'xi',xi) specifies interpolation locations (or times) xi. By 
% default, transect interpolates to 2000 equally-spaced points xi between the 
% minimum and maximum values of x.  
% 
% [h_trans,h_marker,h_bed] = transect(...) returns handles of the transect plot, 
% the markers, and the bed patch object. 
% 
%% Methods
% This function interpolates twice to create a gridded profile of variable 
% v. The first round interpolates the data from each CTD profile to equally-
% spaced depths di. The second round interpolates horizontally to equally-spaced
% locations or times xi. By default, both interpolations are linear and no 
% extrapolation is performed. 
% 
%% Examples: 
% For examples, type 
% 
%  cdt transect
% 
%% Author info
% This function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin, 2018. 
% 
% See also: transectc.

%% Initial error checks: 

narginchk(3,Inf) 
assert(isnumeric(x),'Error: x must be a numeric array.') 
assert(iscell(d),'Error: d must be a cell array.') 
assert(iscell(v),'Error: v must be a cell array.') 
assert(isequal(numel(x),numel(d),numel(v)),'Dimensions of x, d, and v must all agree.') 

%% Set defaults: 

plotbed = false; 
bedcolor = [0 0 0]; 
defaultmarker = 'k.'; 
InterpMethod = 'linear'; 
extrap = false; % interpolation extrapolation method
userdi = false; % user-defined di
userxi = false; % user-defined xi

%% Parse Inputs: 

% Bed elevation: 
tmp = strcmpi(varargin,'bed'); 
if any(tmp)
   plotbed = true; 
   bed = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); % discards this name-value pair
end

% Bed color: 
tmp = strncmpi(varargin,'bedcolor',6); 
if any(tmp)
   assert(plotbed,'Error: If you specify a bed color, you must also specify bed depths.')
   bedcolor = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); % discards this name-value pair
end

% Interpolation method: 
tmp = strncmpi(varargin,'interpolation',6); 
if any(tmp)
   InterpMethod = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); % discards this name-value pair
end

% Interpolation extrapolation: 
tmp = strncmpi(varargin,'extrapolate',6); 
if any(tmp)
   extrap = true; 
   varargin = varargin(~tmp); % discards this name-value pair
end

% Depth interpolation points: 
tmp = strcmpi(varargin,'di'); 
if any(tmp)
   userdi = true; 
   di = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); % discards this name-value pair
end

% Location (or time) interpolation points: 
tmp = strcmpi(varargin,'xi'); 
if any(tmp)
   userxi = true; 
   xi = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); % discards this name-value pair
end

% Any remaining varargin inputs *should* only be marker properties now. 

%% Ready the data: 

% Get an array of d values so we know the depth ranges we're working with: 
darray = cell2mat(d(:)); 

% Common depths to interpolate to: 
if ~userdi
   di = linspace(min(darray),max(darray),1000); 
end

% Final x locations to interpolate to: 
if ~userxi
   xi = linspace(min(x),max(x),2000); 
end

%% Interpolate
% This section interpolates twice: First vertically, then horizontally.

% Preallocate the first grid: 
V1 = nan(length(di),length(x)); 

% Loop through each CTD location: 
for k = 1:length(x) 
   if extrap
      V1(:,k) = interp1(d{k},v{k},di,InterpMethod,'extrap'); 
   else
      V1(:,k) = interp1(d{k},v{k},di,InterpMethod); 
   end
end    
   
% Preallocate the final grid: 
V = NaN(length(di),length(xi)); 

% Loop through each depth level: 
for k = 1:length(di)
   if extrap
      V(k,:) = interp1(x,V1(k,:),xi,InterpMethod,'extrap');
   else
      V(k,:) = interp1(x,V1(k,:),xi,InterpMethod); 
   end
end

%% Plot: 

ish = ishold; % initial hold state.

% Plot background color: 
h_trans = imagesc(xi,di,V); 
h_trans.AlphaData = isfinite(V); 
axis ij % flips axes vertically.
hold on

% Plot bed patch: 
if plotbed
   xbed = [x(:)' x(end) x(1)]; 
   dbed = [bed(:)' max(bed) max(bed)];
   h_bed = patch(xbed,dbed,'k'); 
   set(h_bed,'FaceColor',bedcolor,'EdgeColor','none'); 
end

% Plot markers: 
for k = 1:length(x)
   h_marker(k) = plot(repmat(x(k),size(d{k})),d{k},defaultmarker,varargin{:}); 
end

%% Clean up: 

% Return the hold state to the way we found it: 
if ~ish 
   hold off
end

% Delete handles if the user doesn't want 'em: 
if nargout==0
   clear h*
end

end

