function varargout = cell2nancat(varargin) 
% cell2nancat concatenates elements of a cell into a NaN-separated vector. 
% 
%% Syntax 
% 
%  xv = cell2nancat(xc)
%  [xv,yv,...,zv] = cell2nancat(xc,yc,...,zc)
% 
%% Description 
% 
% xv = cell2nancat(xc) concatenates the numeric arrays of cell array xc into
% a single vector separated by NaNs. 
% 
% [xv,yv,...,zv] = cell2nancat(xc,yc,...,zc) as above but for any number of 
% cell arrays. 
% 
%% Examples
% For examples, type 
% 
%  cdt cell2nancat
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics (UTIG), January 2016. 
% http://www.chadagreene.com 
% 
% See also: cell2mat, nan, and cat. 

%% Input checks:

narginchk(1,Inf) 

%% Perform mathematics and whatnot: 

tmp = varargin{1}; 
if isvector(tmp{1})
   oneColumn = true; 
else
   oneColumn = false; 
end

for k = 1:length(varargin)
   assert(iscell(varargin{k}),'Input error: All inputs must be cell arrays.')

   % Append a NaN to each array inside A: 
   if oneColumn
      Anan = cellfun(@(x) [x(:); NaN],varargin{k},'un',0);
   else
      Anan = cellfun(@(x) [x(:,:); [NaN NaN]],varargin{k},'un',0);
   end

   % Columnate: 
   varargout{k} = cell2mat(Anan(:));
end

end