%% |shadem| documentation
% The great Roger Miller once sang, _As long as there's a hill there's a valley /
% Long as there's a valley then the river can flow free / As long as
% there's a Sun there's a shadow / As long as there's a shadow there's a
% place for you and me._ While it's possible that he was referring to
% sneakin' around with some little lover, it's just as likely that he was singing praises of
% |shadem|, this hill-shading function for Matlab.  
% 
% |shadem| adjusts lighting to give a sense of depth to the display of 
% gridded elevation data. Although it was designed for use with the Matlab's 
% Mapping Toolbox, this function can just as easily be used for |pcolor| or
% |surface| plots of any type and the Mapping Toolbox is _not_ required. 
% 
% Matlab's Mapping Toolbox is packaged with several sub-par functions
% that are intended to create shaded relief maps, but the built-in 
% shading functions are difficult to use, create unattractive maps, and
% cannot be used with a colorbar. 
% 
% Where |surflsrm|, |surflm|, |shaderel|, and |meshlsrm| each require an iterative
% process of guess-and-check to determine visually appealing lighting azimuth and 
% elevation, |shadem| allows interaction with the map from the mouse
% and keyboard: Sunlight comes from wherever you click on your map, and
% intensity of the shading effect can be adjusted by pressing the up and
% down keys. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  shadem
%  shadem('ui') 
%  shadem(...,LightAngle) 
%  shadem(...,LightingType)
%  shadem(...,MaterialType)  
%  shadem(...,gain)
%  shadem(...,'sun')
%  shadem(...,'obj',ObjectHandle)  
%  [lighth,MaterialType,gain,LightingType,LightAngle] = shadem(...)
%  shadem('reset') 
% 
%% Description  
% 
% |shadem| applies simple lighting to surfaces and patch objects on the current axes.
% 
% |shadem('ui')| illuminates the current axes and opens a user
% interface. When the user interface is running, controls are as follows 
% 
% * *Mouse Click* illuminates surfaces from the direction of the mouse
% click, at an elevation given by proximity to the center of the image.
% Clicking near the far right side of a map will make light come from the
% right at a low angle (low elevation). Clicking closer to the center of the image will
% illuminate topography from above (high angle). 
% * *p* sets |LightingType| to |'phong'| method (default).
% * *f* sets |LightingType| to |'flat'| method.
% * *g* sets |LightingType| to |'gouraud'| method (discontinued in R2014b).
% * *n* sets |LightingType| to |'none'| turns lighting off.
% * *d* sets |MaterialType| to |'dull'| (default).
% * *space* sets |MaterialType| to Matlab's |'default'| material (but note the
% default material in this program is |'dull'|.) 
% * *m* sets |MaterialType| to |'metal'|. 
% * *s* sets |MaterialType| to |'shiny'|.
% * *up key* turns |gain| up.
% * *down key* turns |gain| down.
% * *w* sets light source color to white (default). 
% * *q* sets light source to a color of sunlight corresponding to sun elevation angle.
% * *Return* confirms current settings and terminates the user interface.
% Hit Return only when you are satisfied with the way your map looks. 
% * *Esc* returns the map to its initial state and exits the user
% interface. 
% 
% |shadem(...,LightAngle)| specifies |LightAngle| as a two-element array in the form |[az el]|, 
% where |az| is the azimuthal (horizontal) rotation of the light source and |el|
% is the vertical elevation of the light source.  0 azimuth lies at the six o'clock position on the 
% map and positive degrees move counterclockwise around the map. An
% elevation of 90 degrees places light source directly above the map,
% creating a "high noon" type of shadow, whereas elevation angles closer to 
% zero degrees create "sunrise" or "sunset" shadows. Interpretation of azimuth and elevation 
% is the same as that of the |view| or |lightangle| commands. Default |LightAngle| is |[90 45]|. 
% Any two-element array input to the |shadem| function is
% assumed to be a declaration of |LightAngle|. 
% 
% |shadem(...,LightingType)| selects the algorithm used to calculate the effects of light 
% objects on all surface and patch objects in the current axes. Options are
% 
% * |'phong'| (default) 
% * |'flat'| 
% * |'gouraud'| (discontinued in R2014b) 
% * |'none'| (but I'm not sure why you'd do select this option in |shadem|)
% 
% |shadem(...,MaterialType)| sets lighting characteristics of surface
% and patch objects. |MaterialType| can be 
%
% * |'dull'| (default) 
% * |'default'| (albeit not the default |MaterialType| in |shadem|)
% * |'metal'|
% * |'shiny'|
% 
% |shadem(...,gain)| specifies intensity of shading by exaggerating or minimizing
% the _z_ component of the active surface. This is helpful when _x_ and _y_
% coordinates of data mapping might range from -0.5 to 0.5 map units, while
% _z_ data ranges from -4000 to 3000 meters.  Default |gain| is |0|.
% Negative |gain| values reduce the hillshading effect; positive values
% increase the effect.  Any scalar input to |shadem| is interpreted as
% a |gain| value. 
% 
% |shadem(...,'sun')| sets color of the lighting object as a function of light 
% elevation angle to mimic the color of sunlight at sunrise/sunset, noon,
% or any angle in between.
% 
% |shadem(...,'obj',ObjectHandle)| specifies a surface object as a
% target when multiple surface objects exist in the current set of axes. 
% This usage is a bit clunky, may result in strange maps, and is not fully 
% endorsed by the author of the function. Nonetheless, the ability to specify 
% an active surface sometimes helps the author of this function, and he
% thinks that maybe sometimes it could help you too. 
% 
% |[lighth,MaterialType,gain,LightingType,LightAngle] = shadem(...)|
% returns a handle of the |lightangle| object |lighth|, |MaterialType|,
% |gain| value, |LightingType|, and |LightAngle| azimuth and elevation. 
% 
% |shadem('reset')| resets shading by deleting light objects. Note
% that this may not completely undo all settings put in place by previous 
% calls of |shadem|. In some cases this program alters _z_ data values, 
% and the |'reset'| command does not return _z_ values to their original
% state. 
% 
%% Example 1: 2D |pcolor|
% Consider this gridded surface: 

pcolor(repmat(peaks,2))
shading interp
colorbar

%%
% Use |shadem| to give the surface a sense of depth, and make it shiny: 

shadem shiny

%% Example 2: 3D |surf| 
% This program also works with 3D data.

figure 
surf(peaks) 
shading interp

%% 
% Apply |shadem| with Matlab's |'default'| material propterties. Let
% light enter from 60 degrees in the horizontal at 50 degrees elevation: 

shadem([60 50]) 

%% Example 3: Global topography, unprojected coordinates
% For this example, use <cdtgrid_documentation.html |cdtgrid|> to make a quarter-degree 
% global grid and <topo_interp_documentation.html |topo_interp|> to get the corresponding
% topography. Set the colormap with <cmocean_documentation.html |cmocean|>: 

% quarter-degree lat,lon grid: 
[lat,lon] = cdtgrid(1/4); 

% global topography: 
z = topo_interp(lat,lon); 
%
figure
pcolor(lon,lat,z) 
shading interp
cmocean('topo','pivot') % sets the colormap

%% 
% Add hillshade to the global topography map like this

shadem(-17,[225 80])

%% 
% In the figure above, we used a gain value of -17. The amount of gain you use is related
% to how the units of x and y (in the case above, lon and lat) compare to the units of z. 
% If x,y, and z are all in the same units, a gain value of zero might be appropriate. 

%% Example 4: Adding another variable 
% Hillshade is great for providing context, so even when topography isn't the main point
% of a map, you can still use relief shading to show how a variable interacts with topography. 
% Case in point: the plot above depicts topography both with hillshade, and with the cmocean 
% _topo_ colormap. But even if we take the colormap away, the relief shading is still evident. 
% here's the same map as above, but setting the colormap to pure white: 

colormap([1 1 1]) 

%% 
% So perhaps you have some other variable you're really trying to put into perspective. For 
% example, the distance to the nearest coast line, which can be obtained with <dist2coast_documentation.html |dist2coast|>. 
% For the same grid as Example 3, get the distances to the coast, and use <island_documentation.html |island|> 
% to set the land values to negative distances: 

% Get distances to the coast for the grid from example 3: 
D = dist2coast(lat,lon); 

% Set land values to negative: 
land = island(lat,lon); 
D(land) = -D(land); 

figure
surf(lon,lat,z,D)
shading interp
view(2)
axis tight 
cmocean('balance','pivot') 
cb = colorbar; 
ylabel(cb,'distance to nearest coast (km)') 

%% 
% Now use |shadem| to put that map in the context of global topography:

shadem(-19)

%% Example 5: Global topography with Matlab's Mapping Toolbox
% If you have Matlab's mapping toolbox, repeat Example 3, but for a |worldmap|: 

figure
worldmap('world') 
cla % removes grid lines
pcolorm(lat,lon,z) 
cmocean('topo','pivot')
shadem(7,[225 75]) 

%% Known Issue
% I have received feedback that the |LightAngle| cannot be adjusted when
% using the Mapping Toolbox with Matlab release R2014b.  As I understand
% it, this bug only affects the Mapping Toobox release 2014b and has been
% fixed in R2015a. 

%% Author Info 
% The |shadem| function and supporting documentation were created by
% <http://www.chadagreene.com Chad A. Greene> of the University of Texas 
% at Austin's <http://www.ig.utexas.edu/research/cryosphere/ Institute for
% Geophysics (UTIG)>. January 2015. 
