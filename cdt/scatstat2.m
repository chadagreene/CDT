function zbar = scatstat2(x,y,z,radius,fun,varargin)
% scatstat2 returns statistical values of all points within a given 
% radius of each value. This is similar to taking a two-dimensional moving mean, 
% but points do not need to be equally spaced.
% 
%% Syntax 
% 
%  zbar = scatstat2(x,y,z,radius)
%  zbar = scatstat2(x,y,z,radius,fun) 
%  zbar = scatstat2(...,options) 
% 
%% Description 
% 
% zbar = scatstat2(x,y,z,radius) returns the mean of all z values 
% within specified radius at each point (x,y).  
% 
% zbar = scatstat2(x,y,z,radius,fun) applies any function fun to z
% values, default fun is @mean, but it could be anything you want, 
% even your own anonymous function. 
% 
% zbar = scatstat2(...,options) allows any options that the function
% accepts. For example, 'omitnan'. 
% 
%% Examples
% For examples, type 
% 
%  cdt scatstat2 
% 
%% Author info: 
% This function was written by Chad A. Greene of the University 
% of Texas at Austin's Institute for Geophysics (UTIG), June 2016. 
% 
% See also: conv2 and scatstat1. 

%% Input checks: 

narginchk(4,Inf) 
assert(isequal(size(x),size(y),size(z))==1,'Input error: Dimensions of x, y, and z must all agree.') 
assert(isscalar(radius)==1,'Input error: radius must be a scalar.') 

% Check for user-defined function: 
if nargin==4
   fun = @mean; 
else
   assert(isa(fun,'function_handle')==1,'Input error: The fifth input must be a function handle beginning with @.')
end

%% Perform mathematics: 

% Preallocate output: 
zbar = NaN(size(x)); 

% Loop through each x value: 
for k = 1:length(x)
   
   % Indicies of all points within specified radius: 
   ind = hypot(x-x(k),y-y(k))<=radius; 
   
   % Mean of y values within radius:  
   zbar(k) = fun(z(ind),varargin{:}); 
end


end