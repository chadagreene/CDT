function h = patchsc(x,y,z,varargin) 
% patchsc plots patch objects with face colors scaled by numeric values. 
%
%% Syntax
% 
%  patchsc(x,y,z)
%  patchsc(...,'colormap',cmap)
%  patchsc(...,'caxis',ColorAxisLimits)
%  patchsc(...,'PatchProperty',Value,...)
%  h = patchsc(...)
% 
%% Description 
% 
% patchsc(x,y,z) plots cell arrays x,y color-scaled by the numeric values in z. Dimensions
% of z must match the dimensions of cell arrays x and y. x and y can contain multiple sections
% separated by NaNs. 
% 
% patchsc(...,'colormap',cmap) specifies a colormap to which face colors will be mapped. If 
% a colormap is not specified, your default colormap will be used. 
% 
% patchsc(...,'caxis',ColorAxisLimits) sets color axis limits. This is different from other 
% functions like imagesc or surf, which allow setting color limits after plotting. patchsc
% does not allow changing the color axis limits after plotting. Default limits are taken
% as [min(z) max(z)]. 
% 
% patchsc(...,'PatchProperty',Value,...) specifies any patch property. 
% 
% h = patchsc(...) returns handles of all the patch objects. The data element corresponding 
% to each patch object is included in the handle 'tag' property. 
% 
%% Examples
% For examples, type 
% 
%  cdt patchsc 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas
% Institute for Geophysics (UTIG), May 2017. 
% 
% See also: patch and fill. 


%% Input checks: 

assert(nargin>=3,'Input error: patchsc requires at least 3 inputs.') 
assert(isequal(size(x),size(y))==1,'Input error: dimensions of x and y must match.') 
assert(iscell(x)==1,'Input error: x and y must be cell arrays.') 
assert(iscell(y)==1,'Input error: x and y must be cell arrays.') 
assert(isnumeric(z)==1,'Input error: z must be numeric.') 

%% Set defaults: 

cmap = colormap; 
limits = [min(z) max(z)]; % color axis limits

%% Parse optional inputs: 

if nargin>3
   
   % Check for user-defined colormap: 
   tmp = strcmpi(varargin,'colormap'); 
   if any(tmp) 
      cmap = varargin{find(tmp)+1}; 
      assert(size(cmap,2)==3,'Input error: colormap dimensions must be Nx3.')
      tmp(find(tmp)+1)=1; 
      varargin = varargin(~tmp); 
   end
   
   % Check for user-defined color axis limits: 
   tmp = strcmpi(varargin,'caxis'); 
   if any(tmp) 
      limits = varargin{find(tmp)+1}; 
      assert(numel(limits)==2,'Input error: color axis limits must be a two-element array.')
      tmp(find(tmp)+1)=1; 
      varargin = varargin(~tmp); 
   end
   
   
end

%% 

% Convert z values to RGB with the mat2rgb function (a subfunction at the end of this file) 
RGB = mat2rgb(z,cmap,limits); 

% Preallocate graphics handle: 
Nobjects = sum(cellfun(@sum,cellfun(@isnan,x,'uniformoutput',false))); 
if verLessThan('matlab', '8.4.0')
   h = nan(Nobjects,1); 
else
   h = gobjects(Nobjects,1); 
end

counter = 1; 
hold on
for k = 1:length(z)
   
   % This allows multiple nan-separated patch objects within each cell
   yk = y{k}; 
   xk = x{k}; 
   yk = yk(:); % columnates for consistent performance
   xk = xk(:); 
   
   nanz = [0;find(isnan(yk))];
   hold on
   
   for kk = 1:length(nanz)-1
      h(counter) = patch( xk(nanz(kk)+1:nanz(kk+1)-1), yk(nanz(kk)+1:nanz(kk+1)-1), RGB(k,:),varargin{:}); 
      set(h(counter),'tag',num2str(k))
      if isnan(z(k))
         set(h(counter),'FaceAlpha',0); 
      end
      counter = counter+1; 
   end

end
caxis(limits)
colormap(gca,cmap)

%% Clean up

if nargout==0 
   clear h
end

end


%% * * * * * * SUBFUNCTIONS * * * * * * 

function RGB = mat2rgb(val,cmap,limits)
% 
% 
% Chad Greene wrote this, July 2016. 

if nargin==2
   limits = [min(val) max(val)]; 
end

gray = mat2gray(val,limits); 

ind = gray2ind(gray,size(cmap,1));

RGB = cmap(ind+1,:); 

end