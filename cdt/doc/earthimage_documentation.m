%% |earthimage| documentation
% |earthimage| plots an unprojected image base map of Earth. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  earthimage
%  earthimage('gray') 
%  earthimage('watercolor',rgbValues)
%  earthimage('center',centerLon)
%  earthimage(...,'bottom')
%  h = earthimage(...)
% 
%% Description
% 
% |earthimage| plots an image base map of Earth in unprojected coordinates. 
% 
% |earthimage('gray')| plots the image in grayscale. 
% 
% |earthimage('watercolor',rgbValues)| specifies the color of the ocean
% with a three-element [R G B] vector (e.g., |[1 0 0]| for red). 
% 
% |earthimage('center',centerLon)| specifies a center longitude, which can be 
% anything between -180 and 360. Default |centerLon| is |0|. 
%
% |earthimage(...,'bottom')| places the earth image at the bottom of the 
% graphical stack (beneath other objects that have already been plotted).
% 
% |h = earthimage(...)| returns a handle h of the plotted image. 
% 
%% Example 1: Simple
% For a simple base map image, just type |earthimage|: 

earthimage

%% 
% You can then go about adding other layers to the base map with normal
% Matlab plotting functions, where x is used for longitudes and y is used 
% for latitudes: 

hold on
borders('countries','color',0.5*[1 1 1])
xlabel 'degrees longitude'
ylabel 'degrees latitude'

%% Example 2: Grayscale
% For a grayscale image, specify |'gray'|: 

figure
earthimage gray

%% Example 3: Transparent Ocean
% To make the ocean transparent, specify |'watercolor','none'|:

earthimage('watercolor','none')

%% Example 4: Grayscale land with transparent ocean
% Get grayscale land and transparent oceans like this: 

earthimage('gray','watercolor','none')

%% Example 4: Colorful land with a black ocean
% To specify a specific ocean color, enter the RGB values of the 
% color you want the ocean to be. For example, plot make the ocean
% black by specifying the values |[0 0 0]| for |'watercolor'|: 

earthimage('watercolor',[0 0 0])

%% Example 5: Grayscale land with a pink ocean
% If you don't know the RGB values 
% of your favorite color, use the <rgb_documentation.html |rgb|> function
% instead: 

earthimage('gray','watercolor',rgb('pink'))

%% Example 6: Centered on the Pacific
% By default, the central longitude is 0 degrees, the Prime Meridian. But if you'd 
% like the map to be centered on a different longitude, just specify the center longitude
% like this: 

figure
earthimage('center',120)
xlabel 'longitude'
ylabel 'latitude'

%% Author info
% This function and supporting documentation were written by Chad A. Greene, 
% for the Cimate Data Toolbox for Matlab, 2018. 
