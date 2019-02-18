function h = globeimage(varargin) 
% globeimage creates a "Blue Marble" 3D globe image.
% 
%% Syntax 
% 
%  globeimage
%  globeimage('gray') 
%  globeimage(I)
%  globeimage('radius',GlobeRadius)
%  h = globeimage(...)
% 
%% Description
% 
% globeimage plots a Blue Marble Earth image on a 3D globe.
% 
% globeimage('gray') plots the earth image in grayscale. 
% 
% globeimage(I) stretches the image I such that its top and bottom extend to the poles
% and its edges meet at the International Date Line. 
% 
% globeimage(...,'radius',GlobeRadius) specifies the radius of the globe.
% The Default GlobeRadius is 6371, the standard radius of the Earth in kilometers.
% 
% h = globeimage(...) returns the handle h of the plotted object. 
%
%% Examples
% For examples type 
% 
%  cdt globeimage
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globeplot and earthimage. 
%
%% Error checks: 


%% Parse Inputs: 

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp);
else
   radius = 6371; % the default radius, corresponding to Earth's average radius in kilometers.
end

% Does the user want a grayscale image? 
tmp = strncmpi(varargin,'gr',2); % allows 'gray' or 'grey' 
if any(tmp)
   grayscale = true; 
   varargin = varargin(~tmp); 
else
   grayscale = false; 
end

% Assume if anything is left over it's an image. 
if ~isempty(varargin)
   C = varargin{1}; 
else
   C = imread('bluemarble.png'); 
end

%% Load data: 

[lat,lon] = cdtgrid(0.25); 

%% Make adjustments: 

% Change to grayscale:
if grayscale
   C = repmat(rgb2gray(C),[1 1 3]); 
end

% Wrap the seam: 
if diff(lon(1:2))==0
   lon = [lon(:,end)-360 lon lon(:,1)+360]; 
   lat = [lat(:,end) lat lat(:,1)]; 
   C = [C(:,end,:) C C(:,1,:)]; 
else
   lon = [lon(end,:)-360;lon;lon(1,:)+360]; 
   lat = [lat(end,:);lat;lat(1,:)]; 
   C = [C(end,:,:);C;C(1,:,:)];    
end

%% Perform Mathematics: 

[x,y,z] = sph2cart(lon*pi/180,lat*pi/180,radius);

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = surface(x,y,z,C,'FaceColor','texturemap','EdgeColor','none','CDataMapping','direct');

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Clean up: 

if nargout==0
   clear h
end

end