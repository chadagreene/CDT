function h = earthimage(varargin)
% plots an unprojected image base map of Earth. 
% 
%% Syntax
% 
%  earthimage
%  earthimage('gray') 
%  earthimage('watercolor',rgbValues)
%  earthimage('center',centerLon)
%  earthimage(...'bottom')
%  h = earthimage(...)
% 
%% Description
% 
% earthimage plots an image base map of Earth in unprojected coordinates. 
% 
% earthimage('gray') plots the image in grayscale. 
% 
% earthimage('watercolor',rgbValues) specifies the color of the ocean
% with a three-element [R G B] vector (e.g., [1 0 0] for red). 
% 
% earthimage('center',centerLon) specifies a center longitude, which can be 
% anything between -180 and 360. Default centerLon is 0. 
%
% earthimage(...,'bottom') places the earth image at the bottom of the 
% graphical stack (beneath other objects that have already been plotted).
% 
% h = earthimage(...) returns a handle h of the plotted image. 
% 
%% Examples 
% For examples, type 
% 
%  cdt earthimage
% 
%% Author Info
% This function was written by Chad A. Greene, 2018. 
% 
% See also: borders, image, and globe. 

%% Parse inputs: 

% set defaults: 
grayscale = false; 
adjustOcean = false; 
clearOcean = false; % a transparent ocean
centerLon = 0; % central longitude 
bot = false; % put the image on the bottom of the graphical stack?  

% Check for user-defined changes to the defaults:
if nargin>0
   
   % Does the user want a grayscale image? 
   if any([strncmpi(varargin,'grayscale',4) strncmpi(varargin,'greyscale',4)])
      grayscale = true; 
   end
   
   if any(strncmpi(varargin,'bottom',3))
      hold on
      bot = true; 
   end

   % Does the user want to specify a color of the ocean? 
   tmp = strncmpi(varargin,'watercolor',4); 
   if any(tmp)
      adjustOcean = true; 
      OceanColor = varargin{find(tmp)+1}; 

      if strcmpi(OceanColor,'none')
         clearOcean = true; 
      else
         assert(all([isnumeric(OceanColor) numel(OceanColor)==3 max(OceanColor)<=1 min(OceanColor)>=0]),'Ocean color must be a 3-element numeric array with all elements in the range 0 to 1.')
         OceanColor = round(OceanColor*255); % converts to uint8 range
      end
   end   
   
   tmp = strncmpi(varargin,'center',4); 
   if any(tmp)
      centerLon = varargin{find(tmp)+1}; 
      assert(isscalar(centerLon),'Error: Center longitude must be a scalar between -180 and 360.')
   end
end

%% Load Data

I = imread('bluemarble.png');

% Create a 1D arrays of lat and lon values: 
res = 180/1024; % resolution in degrees
lat = (90-res/2):-res:(-90+res/2);
lon = (-180+res/2):res:(180-res/2);

% Recenter if the user requested it: 
if centerLon ~= 0
   [lat,lon,I] = recenter(lat,lon,I,'center',centerLon); 
end

%% Make optional adjustments 

% Change to grayscale:
if grayscale
   I = repmat(rgb2gray(I),[1 1 3]); 
end

% Recolor ocean: 
if adjustOcean
   
   % Get ocean mask: 
   [Lon,Lat] = meshgrid(lon,lat); 
   ocean = ~island(Lat,Lon); 
   
   % Recolor the ocean (unless the user chose 'watercolor','none':
   if ~clearOcean
      R = I(:,:,1); 
      G = I(:,:,2); 
      B = I(:,:,3); 
      R(ocean) = OceanColor(1); 
      G(ocean) = OceanColor(2); 
      B(ocean) = OceanColor(3); 
      I = cat(3,R,G,B); 
   end
end   

%% Plot image

% Make note of the axis limits: 
ax = axis;

% Plot the image
h = image(lon,lat,I); 

% Set the coordinates straight:
axis xy

% If axes were already open, set the axis limits back to the way they were:
if ~isequal(ax,[0 1 0 1])
   axis(ax) 
end

if clearOcean
   h.AlphaData = ~ocean; 
end

if bot
   uistack(h,'bottom')
end

%% Clean up: 

if nargout==0
   clear h
end


end