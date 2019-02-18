function [C,h] = transectc(x,d,v,varargin)
% transectc produces a contour plot oceanographic data from CTD profiles 
% collected at different locations and/or times.  
% 
%% Syntax 
% 
%  transectc(x,d,v)
%  transectc(...,levels)
%  transectc(...,LineSpec)
%  transectc(...,'Name',Value)
%  transectc(...,'extrap')
%  transectc(...,'interp','InterpMethod)
%  transectc(...,'di',di)
%  transectc(...,'xi',xi)
%  [C,h] = transectc(...)
% 
%% Description 
% 
% transectc(x,d,v) creates a contour plot diagram of the variable v
% at the horizontal locations (or times) x and depths d. x must be a numeric
% array of values indicating the locations or times of each CTD profile. Inputs
% d and v must each be cell arrays containing depths and measurements at each
% CTD location. 
%
% transectc(...,levels) specifies the values of v to draw as contour lines. 
% If levels is a scalar value, then transectc draws that number of contour 
% lines. If levels is an array, a contour line is plotted for each value in 
% levels. To draw the contours at one value (k), specify levels as a two-element
% row vector [k k].
%
% transectc(...,LineSpec) specifies the style and color of the contour lines.
% 
% transectc(...,'Name',Value) specifies additional options for the contour plot
% using one or more name-value pair arguments. Specify the options after all other 
% input arguments. For a list of properties, see Contour Properties.
% 
% transectc(...,'extrap') turns on the option to extrapolate beyond the extents
% of data. By default, transectc does not extrapolate, but the option is available
% to fill in gaps, such as between lowest datapoint and the seabed. 
% 
% transectc(...,'interp','InterpMethod) specifies an interpolation method 
% used for the contouring. Default is 'linear'.
% 
% transectc(...,'di',di) specifies interpolation depths di. By default, transectc
% creates a grid by interpolating to 1000 equally-spaced depths between the 
% shallowest and deepest measurement. 
% 
% transectc(...,'xi',xi) specifies interpolation locations (or times) xi. By 
% default, transectc interpolates to 2000 equally-spaced points xi between the 
% minimum and maximum values of x.  
% 
% [C,h] = transectc(...) returns the contour matrix C and the handle h
% of the plotted objects.
% 
%% Methods
% This function grids unevenly spaced data by the method described in the 
% documentation for the transect function, then plots the gridded data with 
% Matlab's built-in contour function. 
% 
%% Examples: 
% For examples, type 
% 
%  cdt transectc
% 
%% Author info
% This function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin, 2018. 
% 
% See also: contour and transect.

%% Initial error checks: 

narginchk(3,Inf) 
assert(isnumeric(x),'Error: x must be a numeric array.') 
assert(iscell(d),'Error: d must be a cell array.') 
assert(iscell(v),'Error: v must be a cell array.') 
assert(isequal(numel(x),numel(d),numel(v)),'Dimensions of x, d, and v must all agree.') 

%% Set defaults: 

InterpMethod = 'linear'; 
extrap = false; % interpolation extrapolation method
userdi = false; % user-defined di
userxi = false; % user-defined xi

%% Parse Inputs: 


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

% Any remaining varargin inputs *should* only be contour inputs now. 

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

% Plot contours: 
[C,h] = contour(xi,di,V,varargin{:});
axis ij % flips axes vertically

%% Clean up: 

% Delete handles if the user doesn't want 'em: 
if nargout==0
   clear C h
end

end

