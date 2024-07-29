function ax = phasebar(varargin) 
% phasebar places a circular donunt-shaped colorbar for phase 
% from -pi to pi or -180 degrees to 180 degrees. 
% 
%% Syntax
% 
%  phasebar
%  phasebar(...,'location',Location) 
%  phasebar(...,'size',Size) 
%  phasebar('deg') 
%  phasebar('rad') 
%  ax = phasebar(...) 
% 
%% Description 
% 
% phasebar places a donut-shaped colorbar on the current axes. 
%
% phasebar(...,'location',Location) specifies the corner (e.g., 'northeast' or 'ne') 
% of the current axes in which to place the phasebar. Default location is the upper-right or 'ne' 
% corner. 
%
% phasebar(...,'size',Size) specifies a size fraction of the current axes.  Default is 0.3. 
%
% phasebar('deg') plots labels at every 90 degrees. 
%
% phasebar('rad') plots labels at every pi/2 radians. 
%
% ax = phasebar(...) returns a handle ax of the axes in which the new axes are plotted. 
% 
%% Example
% 
% Z = 200*peaks(900); 
% Zw = phasewrap(Z,'degrees'); 
% imagesc(Zw) 
% phasemap(12)
% phasebar('location','se')
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% at Austin's Institute for Geophysics (UTIG), May 2016. 
% This function includes Kelly Kearney's plotboxpos function as a subfunction. 
% 
% If the phasemap function is useful for you, please consider citing our 
% paper about it: 
% 
% Thyng, K.M., C.A. Greene, R.D. Hetland, H.M. Zimmerle, and S.F. DiMarco. 
% 2016. True colors of oceanography: Guidelines for effective and accurate 
% colormap selection. Oceanography 29(3):9?13. 
% http://dx.doi.org/10.5670/oceanog.2016.66
% 
% See also colorbar and phasemap. 

%% Set Defaults: 

usedegrees = false; 
axsize = 0.3; 
location = 'northeast'; 

% Try to automatically determine if current displayed data exist and are in radians or degrees: 
if max(abs(caxis))>pi
   usedegrees = true;
else
   usedegrees = false; 
end

% If no data are already displayed use radians: 
if isequal(caxis,[0 1])
   usedegrees = false; 
end

%% Parse inputs: 

tmp = strncmpi(varargin,'location',3); 
if any(tmp) 
   location = varargin{find(tmp)+1}; 
end

tmp = strncmpi(varargin,'size',3); 
if any(tmp) 
   axsize = varargin{find(tmp)+1}; 
   assert(isscalar(axsize),'Input error: axis size must be a scalar greater than zero and less than one.') 
   assert(axsize>0,'Input error: axis size must be a scalar greater than zero and less than one.') 
   assert(axsize<1,'Input error: axis size must be a scalar greater than zero and less than one.') 
end

if any(strncmpi(varargin,'radians',3)); 
   usedegrees = false; 
end

if any(strncmpi(varargin,'degrees',3)); 
   usedegrees = true; 
end

%% Starting settings: 

currentAx = gca; 
cm = colormap(currentAx); 
pos = plotboxpos(currentAx); 
xcol = get(currentAx,'XColor'); 

% Delete old phasebar if it exists: 
try
   oldphasebar = findobj(gcf,'tag','phasebar'); 
   if ~isempty(oldphasebar)
       peerax = arrayfun(@(x) x.UserData.peeraxis, oldphasebar);
       delete(oldphasebar(peerax == currentAx)); 
   end
end

%% Created gridded surface: 

innerRadius = 10; 
outerRadius = innerRadius*1.618; 

[x,y] = meshgrid(linspace(-outerRadius,outerRadius,300));
[theta,rho] = cart2pol(x,y); 

% theta = rot90(-theta,3); 
theta(rho>outerRadius) = nan; 
theta(rho<innerRadius) = nan; 

if usedegrees
   theta = theta*180/pi; 
end

%% Plot surface: 

ax = axes; 
pcolor(x,y,theta)
shading interp 

hold on

% Plot a ring: 
[xc1,yc1] = pol2cart(linspace(-pi,pi,360),innerRadius); 
[xc2,yc2] = pol2cart(linspace(-pi,pi,360),outerRadius); 
plot(xc1,yc1,'-','color',xcol,'linewidth',.2); 
plot(xc2,yc2,'-','color',xcol,'linewidth',.2); 

axis image off
colormap(ax, cm) 

if usedegrees
   caxis([-180 180]) 
else
   caxis([-pi pi]) 
end

%% Label: 

[xt,yt] = pol2cart((-1:2)*pi/2+pi/2,innerRadius); 

if usedegrees
   text(xt(1),yt(1),'0\circ','horiz','right','vert','middle'); 
   text(xt(2),yt(2),'90\circ','horiz','center','vert','top'); 
   text(xt(3),yt(3),'180\circ','horiz','left','vert','middle'); 
   text(xt(4),yt(4),'-90\circ','horiz','center','vert','bottom'); 
else
   text(xt(1),yt(1),'0','horiz','right','vert','middle'); 
   text(xt(2),yt(2),'\pi/2','horiz','center','vert','top'); 
   text(xt(3),yt(3),'\pi','horiz','left','vert','middle'); 
   text(xt(4),yt(4),'-\pi/2','horiz','center','vert','bottom'); 
end

%% Set position of colorwheel: 

switch lower(location)
   case {'ne','northeast'} 
      set(ax,'position',[pos(1)+(1-axsize)*pos(3) pos(2)+(1-axsize)*pos(4) axsize*pos(3) axsize*pos(4)]); 

   case {'se','southeast'} 
      set(ax,'position',[pos(1)+(1-axsize)*pos(3) pos(2) axsize*pos(3) axsize*pos(4)]); 
      
   case {'nw','northwest'} 
      set(ax,'position',[pos(1) pos(2)+(1-axsize)*pos(4) axsize*pos(3) axsize*pos(4)]); 
      
   case {'sw','southwest'} 
      set(ax,'position',[pos(1) pos(2) axsize*pos(3) axsize*pos(4)]); 
      
   otherwise
      error('Unrecognized axis location.') 
end
      
%% Clean up 

set(ax,'tag','phasebar', 'userdata', struct('peeraxis', currentAx));

% Make starting axes current again: 
axes(currentAx); 

uistack(ax,'top'); 

if nargout==0 
   clear ax
end

end




%% Kelly Kearney's plotboxpos: 

function pos = plotboxpos(h)
%PLOTBOXPOS Returns the position of the plotted axis region
%
% pos = plotboxpos(h)
%
% This function returns the position of the plotted region of an axis,
% which may differ from the actual axis position, depending on the axis
% limits, data aspect ratio, and plot box aspect ratio.  The position is
% returned in the same units as the those used to define the axis itself.
% This function can only be used for a 2D plot.  
%
% Input variables:
%
%   h:      axis handle of a 2D axis (if ommitted, current axis is used).
%
% Output variables:
%
%   pos:    four-element position vector, in same units as h

% Copyright 2010 Kelly Kearney

% Check input

if nargin < 1
    h = gca;
end

if ~ishandle(h)  ~strcmp(get(h,'type'), 'axes')
    error('Input must be an axis handle');
end

% Get position of axis in pixels

currunit = get(h, 'units');
set(h, 'units', 'pixels');
axisPos = get(h, 'Position');
set(h, 'Units', currunit);

% Calculate box position based axis limits and aspect ratios

darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');

if ~darismanual && ~pbarismanual
    
    pos = axisPos;
    
else

    dx = diff(get(h, 'XLim'));
    dy = diff(get(h, 'YLim'));
    dar = get(h, 'DataAspectRatio');
    pbar = get(h, 'PlotBoxAspectRatio');

    limDarRatio = (dx/dar(1))/(dy/dar(2));
    pbarRatio = pbar(1)/pbar(2);
    axisRatio = axisPos(3)/axisPos(4);

    if darismanual
        if limDarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/limDarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * limDarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    elseif pbarismanual
        if pbarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/pbarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * pbarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    end
end

% Convert plot box position to the units used by the axis

temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', get(h, 'parent'));
set(temp, 'Units', currunit);
pos = get(temp, 'position');
delete(temp);

end

