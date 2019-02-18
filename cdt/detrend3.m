function Ad = detrend3(A,varargin) 
% detrend3 performs linear least squares detrending along the third dimension
% of a matrix.
% 
%% Syntax
% 
%  Ad = detrend3(A) 
%  Ad = detrend3(A,t)
% 
%% Description
% 
% Ad = detrend3(A) removes the linear trend from the third dimension of A
% assuming slices of A are sampled at constant intervals. 
% 
% Ad = detrend3(A,t) specifies times t associated with each slice of A. Times
% t do not need to occur at regular intervals in time. 
% 
%% Examples
% For examples, type 
% 
%  cdt detrend3 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas Institute 
% for Geophysics (UTIG), January 2017. http://www.chadagreene.com 
% 
% See also trend, detrend, and polyfit. 

%% Error checks

assert(ndims(A)==3,'Input error: Input A must be 3 dimensional. For other size inputs use Matlab''s built-in detrend. ') 
narginchk(1,Inf) 

%% Set defaults and parse inputs: 

N = size(A,3); % number of samples
t = (1:N)';    % default "time" vector

% Did the user input a t vector? 
if nargin>1
   if isnumeric(varargin{1})
      t = squeeze(varargin{1}); 
      assert(isvector(t)==1,'Input error: Time reference vector t must be a vector.') 
   end
end

%% Perform mathematics: 

% Center and scale t to improve fit: 
t = (t(:)-mean(t))/std(t); 

% Reshape, but only deal with the finite values: 
mask = all(isfinite(A),3); 
A = cube2rect(A,mask); 

% Detrend A: 
Ad = A - [t ones(N,1)]*([t ones(N,1)]\A); 

% Unreshape: 
Ad = rect2cube(Ad,mask); 


end