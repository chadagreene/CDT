%% |patchsc| documentation
% |patchsc| plots patch objects with face colors scaled by numeric values. 
%
% <CDT_Contents.html Back to Climate Data Tools Contents>.
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
% |patchsc(x,y,z)| plots cell arrays |x,y| color-scaled by the numeric values in |z|. Dimensions
% of |z| must match the dimensions of cell arrays |x| and |y|. |x| and |y| can contain multiple sections
% separated by NaNs. 
% 
% |patchsc(...,'colormap',cmap)| specifies a colormap to which face colors will be mapped. If 
% a colormap is not specified, your default colormap will be used. 
% 
% |patchsc(...,'caxis',ColorAxisLimits)| sets color axis limits. This is different from other 
% functions like |imagesc| or |surf|, which allow setting color limits after plotting. |patchsc|
% does not allow changing the color axis limits after plotting. Default limits are taken
% as |[min(z) max(z)]|. 
% 
% |patchsc(...,'PatchProperty',Value,...)| specifies any patch property. 
% 
% |h = patchsc(...)| returns handles of all the patch objects. The data element corresponding 
% to each patch object is included in the handle |'tag'| property. 
% 
%% Examples
% For this example, make a map of Latin American countries, color-scaled 
% by their average elevation. Start by loading the data that the <borders_documentation.html 
% |borders|> function uses to plot national outlines, and then trim the dataset
% down to include only Latin America:

load('borderdata.mat'); 

% Indices of Latin American countries: 
ind = [8 17 21 33 38 39 41 48 49 55 59 75 77 78 79 109 120 158,...
   159 161 162 165 174 211 214 226 241 242]; 

% Trim the dataset to Latin America: 
lat = lat(ind); 
lon = lon(ind); 
z = z(ind); 

%% 
% Now let's take a look at the data we're plotting: 

whos lat lon z

%%
% Note that |lat| and |lon| are cell arrays, each containing the outlines of 
% a different country, whereas |z| is a numeric array that just contains one
% number--the average elevation--for each country. That's exactly how |patchsc| 
% likes its data, so let's plot it up: 

% Plot countries color-scaled by average elevation: 
patchsc(lon,lat,z) 

axis equal tight
cb = colorbar; 
ylabel(cb,'national average elevation (m)') 

%% 
% In the plot above, the colorbar axis goes down to -220 m. That's because 
% the national average elevation dataset was created from a coarse resolution
% grid, which interpolated across Guadeloupe to give it an average negative value. 
% It would be great if we could fix it by simply typing 
% 
%  caxis([0 1500]) 
% 
% to reset the color axis limits, but unfortunately that won't work for |patchsc| 
% objects, because they aren't dynamically tied to the colormap. So instead, 
% we must plot it again, specifying the caxis limits when we call |patchsc|: 

figure
patchsc(lon,lat,z,'caxis',[0 1500]) 

axis equal tight
cb = colorbar; 
ylabel(cb,'national average elevation (m)') 

%% 
% Do it again, this time specifying the <cmocean_documentation.html |cmocean|>
% _amp_ colormap: 

figure
patchsc(lon,lat,z,'caxis',[0 1500],'colormap',cmocean('amp')) 

axis equal tight
cb = colorbar; 
ylabel(cb,'national average elevation (m)') 

%% 
% You can also specify any patch property, including facealpha, linewidth, edgecolor, etc. 
% So this time set the caxis limits, the colormap, the edge color, the edge 
% linewidth, and the transparency: 

figure
patchsc(lon,lat,z,'caxis',[0 1500],'caxis',[2 24],...
   'colormap',cmocean('amp'),...
   'edgecolor','blue',...
   'linewidth',3,...
   'facealpha',0.5) 

axis equal tight
cb = colorbar; 
ylabel(cb,'national average elevation (m)') 

%% Author Info 
% This function and supporting documentation were written by Chad A. Greene of the University
% of Texas Institute for Geopyhsics (UTIG), May 2017. This function is part of the 
% <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
