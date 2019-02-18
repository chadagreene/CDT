function ybar = scatstat1(x,y,radius,fun,varargin)
% scatstat1 returns statistical values of all points within a given 
% 1D radius of each value. This is similar to taking a moving mean, but 
% points do not have to be equally spaced, nor do x values need to be
% monotonically increasing. 
% 
%% Syntax 
% 
%  ybar = scatstat1(x,y,radius)
%  ybar = scatstat1(x,y,radius,fun) 
%  ybar = scatstat1(...,options) 
% 
%% Description 
% 
% ybar = scatstat1(x,y,radius) returns the mean of all y values 
% within specified radius at each point x.  
% 
% ybar = scatstat1(x,y,radius,fun) applies any function fun to y
% values, default fun is @mean, but it could be anything you want, 
% even your own anonymous function. 
% 
% ybar = scatstat1(...,options) allows any options that the function
% accepts. For example, 'omitnan'.
% 
%% Examples 
% For examples, type 
% 
%  cdt scatstat1 
% 
%% Author info: 
% This function was written by Chad A. Greene of the University 
% of Texas at Austin's Institute for Geophysics (UTIG), June 2016. 
% 
% See also: smooth and scatstat2. 

%% Input checks: 

narginchk(3,Inf) 
assert(isequal(size(x),size(y))==1,'Input error: x and y must be the same size.') 
assert(isscalar(radius)==1,'Input error: radius must be a scalar.') 

% Check for user-defined function: 
if nargin==3
   fun = @mean; 
else
   assert(isa(fun,'function_handle')==1,'Input error: The fourth input must be a function handle beginning with @.')
end

%% Perform mathematics: 

% Preallocate output: 
ybar = NaN(size(x)); 

% Loop through each x value: 
for k = 1:length(x)
   
   % Indicies of all points within specified radius: 
   ind = abs(x-x(k))<=radius; 
   
   % Mean of y values within radius:  
   ybar(k) = fun(y(ind),varargin{:}); 
end

end