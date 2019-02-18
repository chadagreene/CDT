function [eof_maps,pc,expvar] = eof(A,varargin)
% eof gives eigenmode maps of variability and corresponding principal component
% time series for spatiotemporal data analysis.  It is designed specifically for 3D matricies
% of data such as sea surface temperatures where dimensions 1 and 2 are spatial dimensions 
% (e.g., lat and lon; lon and lat; x and y, etc.), and the third dimension represents different 
% slices or snapshots of data in time.  
% 
%% Syntax
% 
%  eof_maps = eof(A) 
%  eof_maps = eof(A,n) 
%  eof_maps = eof(...,'mask',mask) 
%  [eof_maps,pc,expvar] = eof(...)
% 
%% Description 
% 
% eof_maps = eof(A) calculates all modes of variability in A, where A is a 3D matrix whose
% first two dimensions are spatial, the third dimension is temporal, and data are assumed to be 
% equally spaced in time.  Output eof_maps have the same dimensions as A, where each map along 
% the third dimension represents a mode of variability order of importance. 
% 
% eof_maps = eof(A,n) only calculates the first n modes of variability. For large datasets, 
% it's computationally faster to only calculate the number of modes you'll need.  If n is not
% specified, all EOFs are calculated (one for each time slice). 
% 
% eof_maps = eof(...,'mask',mask) only performs EOF analysis on the grid cells represented by 
% ones in a logical mask whose dimensions correspond to dimensions 1 and 2 of A.  This option
% is provided to prevent solving for things that don't need to be solved, or to let you do analysis
% on one region separately from another.  By default, any grid cells in A which contain any NaNs 
% are masked out.  
% 
% [eof_maps,pc,expvar] = eof(...) returns the principal component time series pc whose rows
% each represent a different mode from 1 to n and columns correspond to time steps.  For example, 
% pc(1,:) is the time series of the first (dominant) mode of varibility.  The third output expvar 
% is the percent of variance explained by each mode.  
% 
%% Example 
% For examples, type 
% 
%  cdt eof
%
%% Author Info 
% Chad A. Greene of the University of Texas Institute for Geophysics (UTIG) created this function
% mostly from the PCAtool functions by Guillame MAZE. If you'd like more options you can get Guillame's  
% PCAtool functions here: https://www.mathworks.com/matlabcentral/fileexchange/17915
% 
% See also: reof, detrend3, and deseason.

%% Error checks 

narginchk(1,inf) 

%% Input parsing

% Set defaults: 
n = size(A,3); 
mask = ~any(isnan(A),3); 

if nargin>1
   % Change n to anything the user requested: 
   if isscalar(varargin{1})
      n = varargin{1}; 
      assert(n<=size(A,3),'Input error: The number n cannot exceed the number of time steps in your data matrix A.  Time steps are inferred as the third dimension of A.') 
   end

   % Has the user defined a mask? 
   tmp = strcmpi(varargin,'mask'); 
   if any(tmp) 
      mask = varargin{find(tmp)+1}; 
      assert(isequal(size(mask),[size(A,1) size(A,2)])==1,'Input error: Mask dimensions must match the first two dimensions of the data matrix A.') 
      assert(islogical(mask)==1,'Input error: mask must be logical.') 
   end
end

%% Reshape 

A = permute(A,[3 1 2]); 
A = reshape(A,size(A,1),size(A,2)*size(A,3)); 
A = A(:,mask(:)); 

%% Calculate EOFs 

[E,pc,expvar] = mycaleof(A,n); % An edited version of Guillame MAZE's caleof function, which appears as a subfunction below. 

%% Un-reshape: 

eof_maps = nan(size(E,1),numel(mask));   
eof_maps(:,mask(:)) = E; 
eof_maps = reshape(eof_maps,size(E,1),size(mask,1),size(mask,2)); 
eof_maps = permute(eof_maps,[2 3 1]); 

%% Flip signs to provide consistent results:

ind = sign(pc(:,1))<0; 
eof_maps(:,:,ind) = eof_maps(:,:,ind)*(-1); 
pc(ind,:) = pc(ind,:)*-1; 

end

function [EOFs,pc,expvar] = mycaleof(A,N_eofs)
% => Compute the Nth first EOFs of matrix A(TIME,MAP).
% EOFs is a matrix of the form EOFs(N,MAP), PC is the principal
% components matrix ie it has the form PC(N,TIME) and EXPVAR is
% the fraction of total variance "explained" by each EOF ie it has
% the form EXPVAR(N).
% 2 - A faster "classic" one, same as method 1 but we use the
%     eigs Matlab function.
%
% See also EIG, EIGS, SVD, SVDS
%
% Ref: L. Hartmann: "Objective Analysis" 2002
% Ref: H. Bjornson and S.A. Venegas: "A manual for EOF and SVD - 
%      Analyses of climatic Data" 1997
%================================================================
%  Guillaume MAZE - LPO/LMD - March 2004
%  Revised July 2006
%  gmaze@univ-brest.fr
% Edited by Chad A. Greene of the University of Texas at Austin, Dec 31, 2016.


%% Preprocess: 

% Remove the time mean of each column
A = detrend(A,'constant');

%% Get Covariance Matrix 

% Get dimensions:
[N_timesteps,N_locations] = size(A);

% Get covariance matrix: 
if N_timesteps >= N_locations
   R = A' * A;
else 
   R = A * A';
end

%% Calculate eigenvectors and eigenvalues 
% Eigen analysis of the square covariance matrix

% Temporarily turn off warning because it'll automatically switch to eig for n==N and that's fine:  
warning('off','MATLAB:eigs:TooManyRequestedEigsForRealSym')
[V,D] = eigs(R,N_eofs); % matrix of eigenvectors V and diagonal matrix of eigenvalues D
warning('on','MATLAB:eigs:TooManyRequestedEigsForRealSym')

D(D<0) = 0; % <-This gets rid of complex solutions by assuming any negative eigenvectors are due to rounding error and are nothing more than numerical noise.  

%% 

if N_timesteps < N_locations
   V = A' * V;
   %   sq = (sqrt(diag(L))+eps)';
   sq = (sqrt(diag(D)))';
   sq = sq(ones(1,N_locations),:);
   V = V ./ sq;

   % Get PC by projecting eigenvectors on original data:
   pc = V'*A';
else
   pc = (A*V)';
end

EOFs = V'; 

%% Percent of variance explained by each principal component: 

expvar = 100*(diag(D)./trace(D))'; 

end
