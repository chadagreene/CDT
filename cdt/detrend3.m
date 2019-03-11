function Ad = detrend3(A,varargin) 
% detrend3 performs linear least squares detrending along the third dimension
% of a matrix.
% 
%% Syntax
% 
%  Ad = detrend3(A) 
%  Ad = detrend3(A,t)
%  Ad = detrend3(...,'omitnan')
% 
%% Description
% 
% Ad = detrend3(A) removes the linear trend from the third dimension of A
% assuming slices of A are sampled at constant intervals. 
% 
% Ad = detrend3(A,t) specifies times t associated with each slice of A. Times
% t do not need to occur at regular intervals in time. 
% 
% Ad = detrend3(...,'omitnan') applies detrending even in grid cells that contain
% NaN values. If many grid cells contains spurious NaNs, you may find that this
% option is slower than the default. 
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

% Does the user want to detrend grid cells that contain spurious NaNs?
tmp = strncmpi(varargin,'omitnan',4); 
if any(tmp)
   omitnan = true; 
   varargin = varargin(~tmp); 
else
   omitnan = false;
end

%% Perform mathematics: 

% Center and scale t to improve fit: 
if omitnan
   t = (t(:)-mean(t,'omitnan'))/std(t,'omitnan'); % although times really shouldn't be NaNs, but maybe they are, and that's okay. 
else
   t = (t(:)-mean(t))/std(t); 
end

% Reshape, but only deal with the finite values: 
if omitnan
   mask = sum(isfinite(A),3)>1; 
else
   mask = all(isfinite(A),3); 
end
A = cube2rect(A,mask); 

% Detrend A: 
Ad = A - [t ones(N,1)]*([t ones(N,1)]\A); 


% Deal with spurious NaNs: 
if omitnan
   % Determine which elements of the y data are finite: 
   isf = isfinite(A); 
   
   % Which columns of data (or grid cells) contain some NaNs, but not all NaNs?   
   col = find(sum(isf)>1 & sum(isf)<length(t)); 
   
   % Loop through the columns (each a grid cell) that we have any hope of solving: 
   for k = 1:length(col)
      
      % For this grid cell, which indices are finite? 
      ind = isf(:,col(k)); 
      N = sum(ind); 
      
      Ad(ind,col(k)) = A(ind,col(k)) - [t(ind) ones(N,1)]*([t(ind) ones(N,1)]\A(ind,col(k))); 

   end
end

% Unreshape: 
Ad = rect2cube(Ad,mask); 


end