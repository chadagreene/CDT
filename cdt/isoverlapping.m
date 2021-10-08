function tf = isoverlapping(BoundingBoxes,BoundingBox)
% isoverlapping determines whether geographic boundingboxes overlap.
% 
%% Syntax 
% 
%  tf = isoverlapping(S,S0)
%  tf = isoverlapping(BoundingBoxes,BoundingBox)
% 
%% Description 
% 
% tf = isoverlapping(S,S0) returns true for any of the BoundingBoxes in 
% the shapefile structure S that overlap with the BoundingBox identified by
% the shapefile structure S0. 
% 
% tf = isoverlapping(BoundingBoxes,BoundingBox) returns true for any of the 
% BoundingBoxes that overlap with BoundingBox. Here, BoundingBoxes must have
% the dimensions 2x2xN, which can be obtained by cat(3,S.BoundingBox). The 
% reference BoundingBox must have the dimensions 2x2. 
% 
%% Examples
% For examples, type 
% 
%  cdt isoverlapping 
% 
%% Author Info 
% Chad A. Greene, NASA Jet Propulsion Laboratory, Jauary 2021. 

%% Input Wrangling: 

narginchk(2,2) 

% Is the input in the form S.BoundingBox or simply BoundingBox? 
if isstruct(BoundingBoxes)
   BoundingBoxes = cat(3,BoundingBoxes.BoundingBox); 
end
assert(isequal([size(BoundingBoxes,1) size(BoundingBoxes,2)],[2 2]),'Dimensions of input BoundingBoxes must be 2x2xN.')

if isstruct(BoundingBox)
   BoundingBox = BoundingBox.BoundingBox; 
end
assert(isequal(size(BoundingBox),[2 2]),'Dimensions of input BoundingBox must be 2x2.')

%% Determine if there is any overlap: 

tf = squeeze(BoundingBoxes(1,1,:))<=BoundingBox(2,1) & ...
    squeeze(BoundingBoxes(2,1,:))>=BoundingBox(1,1) & ...
    squeeze(BoundingBoxes(1,2,:))<=BoundingBox(2,2) & ...
    squeeze(BoundingBoxes(2,2,:))>=BoundingBox(1,2);

end