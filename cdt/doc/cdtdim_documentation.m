%% |cdtdim| documentation 
% The |cdtdim| gives the approximate dimensions of each cell in a lat,lon grid assuming an
% ellipsoidal Earth. This function is similar to <cdtarea_documentation.html |cdtarea|>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax 
% 
%  [dx,dy] = cdtdim(lat,lon)
%  [dx,dy] = cdtdim(lat,lon,'km')
% 
%% Description
% 
% |[dx,dy] = cdtdim(lat,lon)| gives an approximate dimensions in meters of each grid cell given 
% by the geographical coordinate grids |lat,lon|. Inputs lat and lon must have matching dimensions,
% as if they were created by |meshgrid|. 
%
% |[dx,dy] = cdtdim(lat,lon,'km')| gives grid cell sizes in kilometers rather than the default meters.
%
%% Example 1: Cell size of a 10 degree grid
% Given a 10 degree global grid made by <cdtgrid_documentation.html |cdtgrid|>. 

[lat,lon] = cdtgrid(10); 

%% 
% Each grid cell has these dimensions: 

[dx,dy] = cdtdim(lat,lon,'km'); 

%% 
% If you look at the values of |dy|, you'll notice they are all the same.  That's because lines of latitude
% are always equally spaced (one degree of latitude is about 111 km).  So for our 10 degree grid, all the grid
% cells are unsurprisingly

unique(dy(:))

%% 
% about 1111 km apart. In the x-direction, however, each grid cell sizes depend on latitude.  Here's a look 
% at how the x dimensions of grid cells vary across the globe:

p = pcolor(lon,lat,dx); 
axis image
ylabel('latitude') 
xlabel('longitude') 
cb = colorbar; 
ylabel(cb,'grid cell zonal width (km)')

%% 
% If you look closely at the map above, you may notice that the values at the top of the world do not appear to 
% match the values at the bottom of the world.  That's due to an unfortunate behavior of |pcolor|, which discards
% a row and a column of data.  That behavior can be fixed by using interpolated shading or by using |imagesc| instead
% of |pcolor|, but I used |pcolor| above because it's an easy way to include grid lines. 

%% Example 2: Visualizing grid cell sizes with global data
% Here's another way to look at how grid cell sizes are calculated by |cdtdim|.  Start by loading 
% a sea surface temperature dataset which has a grid resolution of 0.75 degrees.  

load global_sst 

%% 
% And currently |lat| and |lon| are vectors, so turn them into matrices the same size as |sst| using |meshgrid|: 

[lon,lat] = meshgrid(lon,lat); 

%% 
% Now just like in Example 1, calculate the sizes |dx| and |dy| of each grid cell: 

[dx,dy] = cdtdim(lat,lon,'km'); 

%% 
% This time, instead of displaying grid cell size on an unprojected grid of lats and lons, let's turn |dx| and |dy| 
% into effective x and y values by taking the cumulative sum of |dx|'s and |dy|'s: 

x = cumsum(dx,2); 
y = cumsum(dy,1); 

%%
% We can plot the |x| and |y| locations as simply the cumulative sums starting from zero, but it's not gonna be pretty: 

plot(x,y,'b.') 
axis equal

%% 
% It makes more sense to center those values about the origin, which can be done by removing the mean x and y values. 
% If you have a post-2016b version of Matlab you can simply subtract |x-mean(x,2)| which performs implicit expansion, 
% but us plebians with old versions of Matlab have to use |bsxfun| to subtract: 

x = bsxfun(@minus,x,mean(x,2)); 
y = bsxfun(@minus,y,mean(y,1)); 

%% 
% With the means removed, we see the grid cell calculation performed by |cdtdim| and |cdtarea| resembles a <https://en.wikipedia.org/wiki/Sinusoidal_projection 
% sinusoidal map projection>: 

pcolor(x,y,sst) 
shading interp
axis image 
xlabel('x distance (km)') 
ylabel('y distance (km)') 
cmocean 'thermal'

%% Author Info 
% This function was written by <http://www.chadagreene.com Chad A. Greene> of the University of Texas Institute for 
% Geophysics (UTIG).  

