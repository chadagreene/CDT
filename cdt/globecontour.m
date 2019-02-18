function h = globecontour(lat,lon,Z,varargin) 
% globecontour plots contour lines on a globe from gridded data. 
% Note: these contours are not contour graphics objects and are 
% not linked to the current colormap. 
% 
%% Syntax 
% 
%  globecontour(lat,lon,Z)
%  globecontour(lat,lon,Z,n)
%  globecontour(lat,lon,Z,v)
%  globecontour(...,PropertyName,PropertyValue)
%  globecontour(...,'radius',GlobeRadius)
%  h = globecontour(...)
% 
%% Description
% 
% globecontour(lat,lon,Z) plots contour lines for the georeferenced data in
% Z on a globe with radius defined as 6371, where 6371 corresponds to the
% average radius of the Earth in kilometers. The inputs lat and lon are the
% same size as Z and can be defined for arbitrary domains using the
% meshgrid function.
%
% globecontour(lat,lon,Z,n) plots n equally-spaced contour lines
% corresponding to the georeferenced data in Z.
% 
% globecontour(lat,lon,Z,v) plots contour lines at heights specified by the
% vector v.
% 
% globecontour(...,PropertyName,PropertyValue) specifies the line
% properties to control contour line appearance and behavior.
% 
% globecontour(...,'radius',GlobeRadius) specifies the radius of the globe
% as GlobeRadius.
% 
% h = globecontour(...) returns the handle h of the plotted objects. 
% 
%% Examples
% For examples type 
% 
%  cdt globecontour
% 
%% Author Info 
% This function and supporting documentation were written by Natalie S.
% Wolfenbarger and Chad A. Greene for Climate Data Tools for Matlab, 2019. 
% 
% See also: globepcolor and globesurf. 
%
%% Error checks: 

narginchk(3,Inf) % asserts at least two inputs. 
assert(islatlon(lat,lon),'The first two inputs in globecontour must be geo coordinates, but the values you have given me seem to be outside the normal limits of degrees.')
assert(isequal(size(lat),size(lon),size(Z)),'Dimensions of lat, lon, and C must all agree.') 

%% Parse Inputs: 

ContoursSpecified = false; % Assume user didn't specify contours. 

% Check for contourc inputs: 
if nargin>3
   if isnumeric(varargin{1})
      ContoursSpecified = true; 
      Contours = varargin{1}; 
      tmp = true(size(varargin)); 
      tmp(1) = false; 
      varargin = varargin(tmp); 
   end
end

tmp = strncmpi(varargin,'radius',3); % checks for optional inputs matching "rad" 
if any(tmp)
   radius = varargin{find(tmp)+1}; 
   assert(isscalar(radius),'Globe radius must be a scalar.') 
   tmp(find(tmp)+1) = 1; 
   varargin = varargin(~tmp); % deletes ths input so the rest of the inputs can be dropped into plot3 later. 
else
   radius = 6371; % the default radius, corresponding to the average Earth radius in kilometers.
end

%% Wrap the seam: 

if diff(lon(1:2))==0
   lon = [lon(:,end)-360 lon lon(:,1)+360]; 
   lat = [lat(:,end) lat lat(:,1)]; 
   lon = lon(1,:); % just take the vectors for contourc
   lat = lat(:,1); 
   Z = [Z(:,end) Z Z(:,1)]; 
else
   lon = [lon(end,:)-360;lon;lon(1,:)+360]; 
   lat = [lat(end,:);lat;lat(1,:)]; 
   lon = lon(:,1); 
   lat = lat(1,:); 
   Z = [Z(end,:);Z;Z(1,:)]';    
end

%% Perform Mathematics: 

if ContoursSpecified
   C = contourc(lon,lat,Z,Contours);
else
   C = contourc(lon,lat,Z);
end
   
% use C2xyz to convert the contour matrix to cartesian coordinates: 
[Clon,Clat] = C2xyz(C); % C2xyz is a subfunction provided below

% Concatenate cell arrays into nan-separated arrays: 
Clon = cell2nancat(Clon); % cell2nancat is a subfunction provided below
Clat = cell2nancat(Clat); 

[x,y,z] = sph2cart(Clon*pi/180,Clat*pi/180,radius);

%% Plot: 

if ~ishold
   view(3)
   hold on
end

h = plot3(x,y,z,varargin{:}); 

daspect([1 1 1]) % sets aspect ratio to 1:1:1 (so the sphere isn't squashed)
axis off

%% Clean up: 

if nargout==0
   clear h 
end

end

%% Subfunctions only beyond this point.

function B = cell2nancat(A) 
%cell2nancat concatenates elements of a cell into a NaN-separated vector. 
% 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics (UTIG), January 2016. 
% http://www.chadagreene.com 
% 
% See also: cell2mat, nan, and cat. 

%% Input checks:

narginchk(1,1) 
assert(iscell(A),'Input error: Input must be a cell array.')

%% Perform mathematics and whatnot: 

% Append a NaN to each array inside A: 
Anan = cellfun(@(x) [x(:);NaN],A,'un',0);

% Columnate: 
B = cell2mat(Anan(:));

end

function [x,y,z] = C2xyz(C)
% C2XYZ returns the x and y coordinates of contours in a contour
% matrix and their corresponding z values. C is the contour matrix given by 
% the contour function. 
% 

%% Citing Antarctic Mapping Tools
% This function was developed for Antarctic Mapping Tools for Matlab (AMT). If AMT is useful for you,
% please cite our paper: 
% 
% Greene, C. A., Gwyther, D. E., & Blankenship, D. D. Antarctic Mapping Tools for Matlab. 
% Computers & Geosciences. 104 (2017) pp.151-157. 
% http://dx.doi.org/10.1016/j.cageo.2016.08.003
% 
% @article{amt,
%   title={{Antarctic Mapping Tools for \textsc{Matlab}}},
%   author={Greene, Chad A and Gwyther, David E and Blankenship, Donald D},
%   journal={Computers \& Geosciences},
%   year={2017},
%   volume={104},
%   pages={151--157},
%   publisher={Elsevier}, 
%   doi={10.1016/j.cageo.2016.08.003}, 
%   url={http://www.sciencedirect.com/science/article/pii/S0098300416302163}
% }
%   
%% Syntax
% 
%  [x,y] = C2xyz(C)
%  [x,y,z] = C2xyz(C)
% 
%% Description 
% 
% [x,y] = C2xyz(C) returns x and y coordinates of contours in a contour
% matrix C
% 
% [x,y,z] = C2xyz(C) also returns corresponding z values. 
% 
% 
%% Example
% Given a contour plot, you want to know the (x,y) coordinates of the contours, 
% as well as the z value corresponding to each contour line. 
%
% C = contour(peaks); 
% [x,y,z] = C2xyz(C);
% 
% This returns 1 x numberOfContourLines cells of x values and y values, and
% their corresponding z values are given in a 1 x numberOfContourLines
% array. If you'd like to plot a heavy black line along all of the z=0
% contours and a dotted red line along the z = -2 contours, try this: 
% 
% hold on; % Allows plotting atop the preexisting peaks plot. 
% for n = find(z==0); % only loop through the z = 0 values. 
%     plot(x{n},y{n},'k','linewidth',2)
% end
% 
% for n = find(z==-2) % now loop through the z = -2 values. 
%     plot(x{n},y{n},'r:','linewidth',2)
% end
% 
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% Created by Chad Greene, August 2013. 
% 
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% See also contour, contourf, clabel, contour3, and C2xy.


m(1)=1; 
n=1;  
try
    while n<length(C)
        n=n+1;
        m(n) = m(n-1)+C(2,m(n-1))+1; 
        
    end
end

for nn = 1:n-2
     x{nn} = C(1,m(nn)+1:m(nn+1)-1); 
     y{nn} = C(2,m(nn)+1:m(nn+1)-1); 
     if nargout==3
        z(nn) = C(1,m(nn));
     end
end

end
