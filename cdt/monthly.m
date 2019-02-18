function Xm = monthly(X,t,months,varargin)
% monthly calculates statistics of a variable for specified months of the year. 
% 
%% Syntax
% 
%  Xm = monthly(X,t,months)
%  Xm = monthly(...,'dim',dimension)
%  Xm = monthly(...,@fn)
%  Xm = monthly(...,'omitnan') 
%  Xm = monthly(...,options) 
% 
%% Description
% 
% Xm = monthly(X,t,months) returns the mean of X for all months specified by
% the numbers 1 through 12. For example, if months is specified as 1, Xm will
% be the mean of all X values for January. If months is [12 1 2], Xm will be 
% the mean of all DJF. Times t correspond to X and can be in datenum, datetime, 
% or datestr format. 
%
% Xm = monthly(...,'dim',dimension) specifies a dimension of operation. By default, 
% if X is a 1D array, the t is assumed to correspond to the first nonsingleton 
% dimension of X; if X is a 2D matrix, the t is assumed to correspond to the 
% rows of X; and if X is a 3D matrix, time is assumed to be dimenion 3 of X. 
%
% Xm = monthly(...,@fn) specifies any function such as @max, @std, or your own
% anonymous function to apply to X. The default function is @mean. 
% 
% Xm = monthly(...,'omitnan') ignores NaN values in the calculation. 
% 
% Xm = monthly(...,options) specifies any optional inputs, which will depend
% on the @fn applied to the data. 
% 
%% Examples, 
% For examples, type 
% 
%  cdt monthly
% 
%% Author Info
% This function was written by Chad X. Greene in 2019. 
% 
% See also: season, climatology, and sinefit. 

%% Error checks: 

narginchk(3,Inf)
assert(isnumeric(X),'Error: Input X must be numeric.')
assert(all(mod(months,1)==0),'Error: months must be any of the numbers 1 through 12.') 
assert(all([max(months)<=12 min(months)>=1]),'Error: months must be any of the numbers 1 through 12.') 

%% Parse inputs: 

% Set defaults: 
fn = @mean; 

% Define the function: 
tmp = true(size(varargin)); 
for k = 1:length(varargin)
   if isa(varargin{k},'function_handle')
      fn = varargin{k}; % sets the function
      tmp(k) = false; 
   end
end
varargin = varargin(tmp); % deletes this input so the rest can be dumped into fn() later.  

% Dimension of operation: 
tmp = strncmpi(varargin,'dimension',3); 
if any(tmp)
   dim = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
   assert(ismember(dim,[1 2 3]),'Error: trend can only operate along dimension 1, 2, or 3.')
else
   if ndims(X)==3 % if it's a 3D matrix, operate down dim 3
      dim = 3; 
   else
      dim = find(size(X)>1,1,'first'); % if it's 2D, operate down the first nonsingleton dimension. 
   end
end

% Make sure time vector matches X: 
assert(isequal(length(t),size(X,dim)),'Error: length of t must match the size of X along the dimension of operation.') 

%% Preprocess

% Columnate and convert t to datenum (if it isn't already): 
t = datenum(t(:)); 

% Get months corresponding to each t: 
[~,mo,~] = datevec(t); 

% Get indices corresponding to the selected months: 
ind = ismember(mo,months); 

% Trim to the desired months and reshape such that time goes down rows: 
switch dim
   case 1
      X = X(ind); 
   case 2
      X = X(:,ind)'; 
   case 3
      sizeX = size(X); 
      X = cube2rect(X(:,:,ind)); 
   otherwise
      error('The monthly function only works on 1D, 2D, or 3D matrices.') 
end

%% Perform the operation: 

Xm = fn(X,varargin{:}); 

%% Unreshape: 

switch dim
   case 1
      % do nothing
   case 2
      Xm = Xm'; 
   case 3
      Xm = rect2cube(Xm,sizeX(1:2)); 
   otherwise
      error('There is no known explanation for how we got here.') 
end

end