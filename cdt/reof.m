function A = reof(eof_maps,pc,modes) 
% reof reconstructs a time series of eof anomalies from specified EOF modes. 
% 
%% Syntax
% 
%  A = reof(eof_maps,pc,modes)
% 
%% Description
% 
% A = reof(eof_maps,pc,modes) reconstructs a gridded time series of the 
% specified modes, from eigenmode maps eof_maps and principal component
% time series pc, which are both outputs of the eof function. 
% 
%% Examples
% For examples, type
% 
%  cdt reof
% 
%% Author Info
% This function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin.
% 
% See also eof. 

%% Input checks: 

narginchk(3,3)
assert(size(eof_maps,3)>=max(modes),'Error: mode numbers cannot exceed the number of eof maps.') 
assert(all(mod(modes,1)==0),'Error: Modes must be integer indices.') 

A = zeros(size(eof_maps,1),size(eof_maps,2),size(pc,2)); 

for k = 1:length(modes)
   A = A + expand3(eof_maps(:,:,modes(k)),pc(modes(k),:)); 
end

end

