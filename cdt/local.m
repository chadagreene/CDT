function y = local(A,mask,varargin) 
% local returns a 1D array of values calculated from a region of interest in a 3D matrix. 
% For example, if you have a big global 3D sea surface temperature dataset, this function
% makes it easy to obtain a time series of the average sst within a region of interest. 
% 
%% Syntax 
% 
%  y = local(A)
%  y = local(A,mask)
%  y = local(A,mask,'weight',weight)
%  y = local(A,mask,@function) 
%  y = local(...,FunctionInputs,...)
%  y = local(...,'omitnan')
% 
%% Description 
% 
% y = local(A) produces a time series or profile from the mean values of each 2D 
% slice along dimension 3 of the 3D matrix A. 
% 
% y = local(A,mask) calculates the mean value within the 2D logical mask for each
% slice along dimension 3 of A. For matrix A of dimensions MxNxP, the dimensions of
% mask must be MxN and the dimensions of output y are Px1. 
% 
% y = local(A,mask,'weight',weight) computes the weighted average, where weight
% is a 2D matrix contaning weights (such as grid cell area) and the dimensions
% of weight match the dimensions of mask. 
% 
% y = local(A,mask,@function) applies any function to the data values which make up each element
% of y. The default @function is @mean, but you may use @max, @std, or just about
% any other function you can think of. You can even define your own anonymous function. 
%  
% y = local(...,FunctionInputs,...) allows extra inputs to the specified function. For 
% example, the std function allows the standard deviation weighting scheme to be 
% either 0 or 1; to specify the former, use y = local(A,mask,@std,0). 
% 
% y = local(...,'omitnan') ignores NaNs.  
% 
%% Examples 
% For examples type 
% 
%    cdt local
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas Institute for Geophysics
% (UTIG), Februrary 2017.  http://www.chadagreene.com
% 
% See also geomask, cdtarea, and cube2rect. 

%% Error checks: 

narginchk(1,Inf)
assert(ndims(A)>=2,'Input error: Matrix A must be 2D or 3D.') 
if nargin==1
   mask = true(size(A,1),size(A,2)); 
end
assert(isequal([size(A,1) size(A,2)],size(mask)),'Input error: lat lon grids must match the first two dimensions of A.') 
assert(islogical(mask),'Error: Input mask must be logical.')

if sum(mask(:))==1
   warning('CDT:local:onetrue', ...
     ['The mask you have specified contains only one "true" grid cell. This is ',...
      'okay, but because of the way the local function works, you might need to specify ',...
      'the dimension 1 in your input arguments. For example, ',...
      '\n \n',...
      'local(A,mask,@mean,1,''omitnan'')',...
      '\n \n',...
      'or',...
      '\n \n',...
      'local(A,mask,@std,[],1,''omitnan'')',...
      '\n \n',...
      'The local function will still operate along dimension 3 of the input ',...
      'matrix A, even though you will tell it dimension 1, and I realize that ',...
      'is a little confusing but for now it is the only way I can think of ',...
      'to address the issue for any arbitrary input function.'],'')
end
      

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

% Check for area-average weighting: 
tmp = strncmpi(varargin,'weight',3); 
if any(tmp) 
   weighting = true; 
   assert(isequal(fn,@mean),'Input error: weighted averaging can only be performed with the default @mean function.') 
   weight = varargin{find(tmp)+1}; 
   assert(isequal([size(A,1) size(A,2)],size(weight)),'Error: Size of weights must match the first two dimensions of A.') 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
else
   weighting = false; 
end

%% 

A = cube2rect(A,mask); 

if weighting
      
   % Reshape it the same way as A: 
   weight = permute(weight,[3 1 2]);
   weight = reshape(weight,size(weight,1),size(weight,2)*size(weight,3));
   weight = weight(:,mask(:)); 

   % Compute weighted mean as sum(A*Area)/sum(Area):
   y = sum(bsxfun(@times,A,weight),2,varargin{:})./sum(weight,varargin{:}); 
   
else
   
   y = fn(A',varargin{:})'; 
   
end



% 
% if islogical(mask)
%    weighting = false;
% else 
%    weighting = true;
%    if ~isequal(fn,@wmean) % If the function isn't wmean, make sure it's mean. 
%       assert(isequal(fn,@mean),'Error: Weighting can only be used for averages. Either use a different function or use a logical mask.') 
%    end
%    fn = @wmean; 
% end   
% 


% %% Reshape A such that rows correspond to time, and columns are different pixels: 
% 
% A = permute(A,[3 1 2]); 
% A = reshape(A,size(A,1),size(A,2)*size(A,3)); 
% A = A(:,mask(:)); 
% 
% %% Compute user-specified value: 
% 
% if weighting
%       
%    % Reshape it the same way as A: 
%    weight = permute(weight,[3 1 2]);
%    weight = reshape(weight,size(weight,1),size(weight,2)*size(weight,3));
%    weight = weight(:,mask(:)); 
% 
%    % Compute weighted mean as sum(A*Area)/sum(Area):
%    y = sum(bsxfun(@times,A,weight),2)./sum(weight); 
%    
% else
%    
%    y = fn(A')'; 
%    
% end

end



