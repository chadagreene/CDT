%% |cbarrow| documentation
% The |cbarrow| function places triangle-shaped endmembers on colorbars to
% indicate that data values exist beyond the extents of the values shown in
% the colorbar.  
% 
% This function works by creating a set of axes atop the current figure and 
% placing patch objects on the new axes.  Thus, editing a figure after
% calling |cbarrow| may cause some glitches.  Therefore, it is recommended to call
% |cbarrow| last when creating plots. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  cbarrow
%  cbarrow(Direction) 
%  cbarrow('delete')
%  h = cbarrow(...)
% 
%% Description
% 
% |cbarrow| places triangle-shaped endmembers on both ends of the current
% colorbar. 
% 
% |cbarrow(Direction)| specifies a single direction to place a colorbar end
% arrow.  |Direction| can be |'up'|, |'down'|, |'right'|, or |'left'|. 
% 
% |cbarrow('delete')| deletes previously-created |cbarrow| objects. 
% 
% |h = cbarrow(...)| returns a handle of the axes on which |cbarrow|
% objects are created.  
% 
%% Example 1: Both directions
% Consider this plot of sample data: 

surf(peaks)
axis tight
colorbar

%% 
% The _z_ range of the |peaks| data goes from about -6.55 to 8.08. By
% default, the extents of the colorbar are set to the range of the _z_
% data.  We can see this when we type 

caxis 

%% 
% Perhaps you want to see nuance in processes that occur in the range of 0
% to 3.  To do this, we'd typically set the range of the color axis
% accordingly like this: 

caxis([0 3]) 

%% 
% However, now the colorbar indicates that all bright yellow data points have a
% value of exactly 3, all dark blue data points have a value of exactly 0,
% and no data extends beyond these limits.  To indicate to viewers that in
% fact some data do extend beyond the 0 to 3 limits, place little arrows
% at the ends of the colorbar with: 

cbarrow

%% Example 2: One direction
% Need a colorbar that just points in one direction? Start with the |peaks| data 
% and set the colormap with <cmocean_documentation.html |cmocean|>.  
% The colormap below diverges about zero, but only values on
% the positive end of the colorbar are be clipped when we set the color
% axis from -7 to 7. Therefore, it only makes sense to place an arrow on the right-hand
% side of the colorbar: 

figure 
surf(peaks) 
axis tight
colorbar('southoutside') 
colormap(cmocean('balance'))
caxis([-7 7]) 
cbarrow('right') 

%% Known issues 
% This function only works once per figure.  If you have multiple subplots,
% you can only use it once, and you'll have to call |cbarrow| last.  Also, 
% editing plots after calling |cbarrow| can sometimes be a bit glitchy. 

%% Author Info
% The |newcolorbar| function was written by <http://www.chadagreene.com Chad
% A. Greene> of the University of Texas at Austin's Institute for
% Geophysics (UTIG), August 2015. 

