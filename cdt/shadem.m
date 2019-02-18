function [lighth,MaterialType,gain,LightingType,LightAngle] = shadem(varargin) 
% shadem applies relief shading or "hillshade" to a map. 
% 
% shadem adjusts lighting to give a sense of depth to the display of 
% gridded elevation data. Although it was designed for use with the Matlab's 
% Mapping Toolbox, this function can just as easily be used for pcolor or
% surface plots of any type and the Mapping Toolbox is not required.  
% 
% Matlab's Mapping Toolbox comes with several sub-par functions
% that are intended to create shaded relief maps, but the built-in 
% shading functions are difficult to use, create unattractive maps, and
% cannot be used with a colorbar. 
% 
% Where surflsrm, surflm, shaderel, and meshlsrm each require an iterative
% process of guess-and-check to determine visually appealing lighting azimuth and 
% elevation, shadem allows interaction with the map from the mouse
% and keyboard: Sunlight comes from wherever you click on your map, and
% intensity of the shading effect can be adjusted by pressing the up and
% down keys. 
% 
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
% shadem applies simple lighting to surfaces and patch objects on the current axes.
% 
% shadem('ui') illuminates the current axes and opens a user
% interface. When the user interface is running, controls are as follows: 
% 
%                 - LightAngle -
%   Mouse Click  illuminates surfaces from the direction of the mouse
%                click, at an elevation given by proximity to the center of the image.
%                Clicking near the far right side of a map will make light come from the
%                right at a low angle (low elevation). Clicking closer to the center of the
%                image will illuminate topography from above (high angle). 
% 
%                 - LightingType -
%             p  sets LightingType to 'phong' method (default).
%             f  sets LightingType to 'flat' method.
%             g  sets LightingType to 'gouraud' method (discontinued in R2014b).
%             n  sets LightingType to 'none' turns lighting off.
%             
%                 - MaterialType -
%             d  sets MaterialType to 'dull' (default).
%         space  sets MaterialType to Matlab's 'default' material (but note the
%                default material in this program is 'dull'.)
%             m  sets MaterialType to 'metal'. 
%             s  sets MaterialType to 'shiny'.
% 
%                 - Light Color -
%             w  sets light source color to white (default). 
%             q  sets light source to a color of sunlight corresponding to sun elevation angle. 
% 
%                 - Gain -
%        up key  turns gain up.
%      down key  turns gain down.
% 
%                 - Exiting -
%        Return  confirms current settings and terminates the user interface.
%                Hit Return only when you are satisfied with the way your map looks. 
%           Esc  returns the map to its initial state and exits the user interface.  
% 
% 
% shadem(...,LightAngle) specifies LightAngle as a two-element array in the form
% [az el], where az is the azimuthal (horizontal) rotation of the light source and el
% is the vertical elevation of the light source.  0 azimuth lies at the six o'clock
% position on the map and positive degrees move counterclockwise around the map. An
% elevation of 90 degrees places light source directly above the map, creating a "high 
% noon" type of shadow, whereas elevation angles closer to zero degrees create "sunrise"
% or "sunset" shadows. Interpretation of azimuth and elevation is the same as that of 
% the view or lightangle commands. Default LightAngle is [90 45]. Any two-element array 
% input to the shadem function is assumed to be a declaration of LightAngle. 
% 
% shadem(...,LightingType) selects the algorithm used to calculate the effects of light 
% objects on all surface and patch objects in the current axes. Options are
%      'phong' (default) 
%      'flat' 
%      'gouraud' (discontinued in R2014b) 
%      'none' (but I'm not sure why you'd do select this option in shadem)
% 
% shadem(...,MaterialType) sets lighting characteristics of surface
% and patch objects. MaterialType can be 
%      'dull' (default) 
%      'default' (albeit not the default MaterialType in shadem)
%      'metal'
%      'shiny'
% 
% shadem(...,gain) specifies intensity of shading by exaggerating or minimizing
% the z component of the active surface. This is helpful when x and y
% coordinates of data mapping might range from -0.5 to 0.5 map units, while
% z data ranges from -4000 to 3000 meters.  Default gain is 0.
% Negative gain values reduce the hillshading effect; positive values
% increase the effect.  Any scalar input to shadem is interpreted as
% a gain value. 
% 
% shadem(...,'sun') sets color of the lighting object as a function of light 
% elevation angle to mimic the color of sunlight at sunrise/sunset, noon,
% or any angle in between.
%
% shadem(...,'obj',ObjectHandle) specifies a surface object as a
% target when multiple surface objects exist in the current set of axes. 
% This usage is a bit clunky, may result in strange maps, and is not recommended. 
% 
% [lighth,MaterialType,gain,LightingType,LightAngle] = shadem(...)
% returns a handle of the lightangle object lighth, MaterialType,
% gain value, LightingType, and LightAngle azimuth and elevation. 
% 
% shadem('reset') resets shading by deleting light objects. Note
% that this may not completely undo all settings put in place by previous 
% calls of shadem. In some cases this program alters z data values, 
% and the 'reset' command does not return z values to their original
% state. 
%
%% Examples 
% For examples, type 
% 
%  cdt shadem 
% 
%% Citation
% This function was originally part of Antarctic Mapping Tools for Matlab 
% (Greene et al., 2017). If this function is useful for you, please cite 
% that paper as
% 
% Greene, C. A., Gwyther, D. E., & Blankenship, D. D. Antarctic Mapping Tools for Matlab. 
% Computers & Geosciences. 104 (2017) pp.151-157. 
% http://dx.doi.org/10.1016/j.cageo.2016.08.003
% 
%% Author Info 
% The shadem function and supporting documentation were created by
% Chad A. Greene of the University of Texas at Austin's Institute for
% Geophysics (UTIG) in January of 2015. 
% 
% See also pcolorm, geoshow, surflsrm, surflm, surfm, shaderel, and meshlsrm. 

% September 2015: Currently the ability to apply relief shading to images is in beta.   

%% Declare defaults: 


axes_handle  = gca;       % (currently cannot be set) 
runui        = false;     % run user interface unless 'set' is declared by user. 
MaterialType = 'dull';    % material, I know, 'default' should be the default material, but maps are not usually even slightly shiny   
LightingType = 'phong';   % 'phong' looks best in almost every case. 
LightAngle   = [90 45];   % light from right side at 45 degrees elevation. 
gain         = 0;         % exaggeration of z values for lighting.
setSunlight  = false;     % color light source dependending on elevation  
workOnImage  = false; 
was_surface  = false;     % not a surface, but a pcolor or an image

%% Parse Inputs: 

% Reset? (Will delete previously-set lighting objects, but does not return z values to their original values if z values were adjusted)   
if any(strcmpi(varargin,'reset'))
    assert(nargin==1,'The reset command in shadem cannot be called with any other commands.')  
    lighting none;
    delete(findobj(gca,'Type','Light')); 
    return 
end

% Run the user interface? 
if any(strcmpi(varargin,'ui'))
    runui = true; 
end

% Which object to manipulate? (this might not always work. It's so much better when there's only one surface object in your axes.)   
tmp = strncmpi(varargin,'obj',3); 
if any(tmp)
    obj = varargin{find(tmp)+1}; 
    assert(ishandle(axes_handle)==1,'Unrecognized object handle.') 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
else
    axch = findobj(axes_handle,'type','surface'); % axis children
    if isempty(axch)
        axch = findobj(axes_handle,'type','image'); % axis children
        assert(isempty(axch)==0,'Cannot find a surface or image to work on.') 
        workOnImage = true; 
        obj = axch(1); % takes the most recent image object
    else
        obj = axch(1); % takes the most recent surface object
    end
end

% Set material type: 
tmp = strcmpi(varargin,'shiny')|strcmpi(varargin,'metal')|strcmpi(varargin,'dull')|strcmpi(varargin,'default'); 
if any(tmp) 
    MaterialType = varargin{tmp}; 
end

% Set lighting type 
tmp = strcmpi(varargin,'phong')|strcmpi(varargin,'gouraud')|strcmpi(varargin,'flat')|strcmpi(varargin,'none'); 
if any(tmp) 
    LightingType = varargin{tmp}; 
end

% Assume any numeric inputs are either gain or LightAngle: 
for k = find(cellfun(@isnumeric,varargin))
    if isscalar(varargin{k})
        gain = varargin{k}; 
    else
        LightAngle = varargin{k};
        assert(numel(LightAngle)==2,'There''s some kind of error in your inputs for shadem. There should be a maximum of two numeric inputs: a scalar (gain) and/or a two-element array (LightAngle). You have entered a number that is neither scalar nor two-element array.') 
    end
end

% Sunlight color: 
if any(strncmpi(varargin,'sun',3))
    setSunlight = true; 
end

%% Define sunlight colors in case we need them: 

morn = [182 126 91];  % corresponds to sunset or sunrise
noon = [192 191 173]; % these values are rather approximate. 
cmap = [linspace(morn(1),noon(1),91)' linspace(morn(2),noon(2),91)' linspace(morn(3),noon(3),91)']/255;

%% Get starting data

% Get xlim and ylim for centering mouse clicks: 
xl = xlim; 
yl = ylim; 
xc = mean(xlim); 
yc = mean(ylim); 
minlength = min([xc-xl(1) yc-yl(1)]); 

cdata = get(obj,'cdata'); 
xdata = get(obj,'xdata');     
ydata = get(obj,'ydata'); 
if workOnImage
    startingz = 0.01; 
else
    
   startingz = get(obj,'zdata'); % this variable will be changed
	startingzrecord = startingz;  % this variable will not be changed
    
    % If zdata is all zeros (or very close) assume user has input z in the form
    % of cdata. Then set zdata to cdata so fancy lighting can happen: 
    if max(abs(startingz(:)))<eps
        startingz = cdata; 

        % Sometimes geoshow throws away good data, and when it does, 
        % we have to do the same: 
        if size(xdata,1) == size(cdata,1)+1
            set(obj,'xdata',xdata(1:size(xdata,1)-1,1:size(xdata,2)-1));
            set(obj,'ydata',ydata(1:size(ydata,1)-1,1:size(ydata,2)-1));
        end
    else 
       
       was_surface = true; 
    end
end
    
%% Begin altering the image: 

if workOnImage
    hold on
    im = image(xdata,ydata,zeros([size(cdata,1) size(cdata,2) 3]));
    dx = (max(xdata(:))-min(xdata(:)))./(size(cdata,2)-1); 
    set(im,'AlphaDataMapping','none','AlphaData',shadecalc(cdata,dx,LightAngle(1),LightAngle(2),gain)); 
    
else
    
    % Set starting z: 
    set(obj,'zdata',startingz*pow2(gain)); % default gain has already been set to 0

    % Initialize lighting and material type: 
    lighting(axes_handle,LightingType); 
    lighth = lightangle(LightAngle(1),LightAngle(2)); 
    material(MaterialType)

    % Optional sunlight color: 
    if setSunlight
        set(lighth,'color',cmap(LightAngle(2)+1,:)); 
    end

end

% Place a pointer in the center of image: 
if runui
    InitialNumberTitle = get(gcf,'NumberTitle'); 
    InitialName = get(gcf,'Name'); 
    InitialHold = ishold; 
    hold on; 
    midpointer(1) = plot3(xc,yc,max(startingz(:)*pow2(gain))+1,'y+','markersize',14); 
    midpointer(2) = plot3(xc,yc,max(startingz(:)*pow2(gain))+1,'k+','markersize',10); 
    if ~workOnImage
        set(gcf,'Name',['LightingType ',LightingType,'; MaterialType ',MaterialType,'; gain ',num2str(gain),'; LightAngle [',num2str(LightAngle),']'],'NumberTitle','off')
    end
else 
    InitialHold = ishold; 
    hold on % This is a weird hack, but adding a transparent marker object seems to prevent the changes from not taking. 
    plot3(xc,yc,max(startingz(:)*pow2(gain))+1,'+','markersize',14,'color','none');
    if ~InitialHold
       hold off
    end
end

if ~workOnImage
   lightangle(lighth,LightAngle(1),LightAngle(2)); 
end

% Start interactive user interface if user declared 'ui' as an input: 
while runui
    w = waitforbuttonpress; 
    switch w 
        case 1 % (keyboard press) 
        	key = get(gcf,'currentcharacter'); 
            
            switch key
                case 27 % 27 is the escape key, which indicates everything should be returned to initial state 
                    
                    if workOnImage
                        delete([im,midpointer])
                    else
                        lighting none; 
                        delete([lighth,midpointer]); 
                        set(obj,'zdata',startingzrecord,'xdata',xdata,'ydata',ydata);
                    end
                    set(gcf,'Name',InitialName,'NumberTitle',InitialNumberTitle); 
                    
                    % Return axes to initial hold state:
                    if ~InitialHold
                        hold off
                    end
                    
                    if nargout==0
                        clear lighth MaterialType gain LightingType LightAngle
                    end
                    return % break out of the while loop
                    
                case 13 % The return key is 13, which means the user is happy and ready to set current lighting forever and ever. 
                   
                    plot3(mean(xlim),mean(ylim),mean(zlim),'+','color','none')
                    delete(midpointer)
                   
                    set(gcf,'Name',InitialName,'NumberTitle',InitialNumberTitle); 
                    
                    % Return axes to initial hold state: 
                    if ~InitialHold
                        hold off
                    end
                    
                     if ~workOnImage
                        lightangle(lighth,LightAngle(1),LightAngle(2)); 
                     end
                    if nargout==0
                        clear lighth
                    end
                    break % break out of the while loop

                case 30 % 30 is up. 
                    gain = gain+1;
                    if workOnImage
                        set(im,'AlphaDataMapping','none','AlphaData',shadecalc(cdata,dx,LightAngle(1),LightAngle(2),gain)); 
                    else
                        set(obj,'zdata',startingz*pow2(gain));
                        set(midpointer,'zdata',max(startingz(:)*pow2(gain))+1); 
                    end
                    
                case 31 % 31 is down. 
                    gain = gain-1; 
                    if workOnImage
                        set(im,'AlphaDataMapping','none','AlphaData',shadecalc(cdata,dx,LightAngle(1),LightAngle(2),gain)); 
                    else
                        set(obj,'zdata',startingz*pow2(gain));
                        set(midpointer,'zdata',max(startingz(:)*pow2(gain))+1); 
                    end
                    
                case 102 % 102 is f for flat
                    LightingType = 'flat'; 
                    lighting(axes_handle,LightingType); 
                    
                    
                case 103 % 103 is g for gouraud 
                    LightingType = 'gouraud';
                    lighting(axes_handle,LightingType); 
                    
                case 112 % 112 is p for phong
                    LightingType = 'phong';
                    lighting(axes_handle,LightingType); 
                    
                case 110 % 110 is n for none
                    LightingType = 'none';  
                    lighting(axes_handle,LightingType); 
                    
                case 115 % 115 is s for shiny
                    MaterialType = 'shiny'; 
                    material shiny
                    
                case 100 % 100 is d for dull
                    MaterialType = 'dull'; 
                    material dull
                    
                case 109 % 109 is m for metal 
                    MaterialType = 'metal'; 
                    material metal
                    
                case 32 % 32 is spacebar for default material
                    MaterialType = 'default'; 
                    material default 
                    
                case 119 % 119 is w for white light source 
                    setSunlight  = false; 
                    set(lighth,'color',[1 1 1]); 

                case 113 % 113 is q for sunlight-colored light source
                    setSunlight  = true; 
                    set(lighth,'color',cmap(LightAngle(2)+1,:)); 

                otherwise
                    % wait for a better command. 
            end
            
        case 0 % (mouse click) 
            % Estimate lightangle azimuth and elevation from mouse click
            % points. 
            mousept = get(gca,'currentPoint');
            x = mousept(1,1);
            y = mousept(1,2);
            
            % Estimate azimuth from x/y position:
            LightAngle(1) = round(atan2d(y-yc,x-xc)+90);
            
            % Estimate elevation as distance from center: 
            LightAngle(2) = floor(90*(1-hypot(x-xc,y-yc)/minlength)); 
            LightAngle(2) = max([0 LightAngle(2)]); % prevents negative elevation
            
            if workOnImage
                set(im,'AlphaDataMapping','none','AlphaData',shadecalc(cdata,dx,LightAngle(1),LightAngle(2),gain)); 
            else
                lightangle(lighth,LightAngle(1),LightAngle(2)); 
            end
            
            if setSunlight
                set(lighth,'color',cmap(LightAngle(2)+1,:)); 
            end
    end
        set(gcf,'Name',['LightingType ',LightingType,'; MaterialType ',MaterialType,'; gain ',num2str(gain),'; LightAngle [',num2str(LightAngle),']'])

end


if ~workOnImage
   try
   lightangle(lighth,LightAngle(1),LightAngle(2)); 
   end
end

% if all([~workOnImage  ~was_surface])    
%     % Push z data down so it doesn't cover up data on the zero plane: 
%     tmp = get(obj,'zdata'); 
%     set(obj,'zdata',tmp-max(tmp(:))-eps); 
% end


% Clean Up: 
if ~runui && nargout==0 
    clear lighth m gain
end

end



function hs = shadecalc(dem,dx,az,el,gain)

zf = 2^gain; 
% zf is scaling factor.
% Convert azimuth and elevation to radians: 
az = az*pi/180+90; 
el = el*pi/180; 

% calc slope and aspect (radians)
[fx,fy] = gradient(dem,dx,dx); % simple, unweighted gradient of immediate neighbours
[asp,grad]=cart2pol(fy,fx); 

grad=atan(zf*grad); 
asp(asp<pi)=asp(asp<pi)+pi/2;
asp(asp<0)=asp(asp<0)+2*pi;

hs =  cos(el).*cos(grad) + sin(el).*sin(grad).*cos(az-asp) ; % ESRIs algorithm
hs(hs<0)=0; % set hillshade values to min of 0.


end
