function [lat,lon] = binind2latlon(binind,varargin) 
% binind2latlon converts binned index values of a sinusoidal grid to geocoordinates. 
% 
% More information on the sinusoidal grid here: https://oceancolor.gsfc.nasa.gov/docs/format/l3bins/
%% Syntax
% 
%  [lat,lon] = binind2latlon(binind) 
%  [lat,lon] = binind2latlon(...,'rows',NumberOfRows) 
% 
%% Description 
% 
% [lat,lon] = binind2latlon(binind) gives the geo coordinates for the bin indices binind. 
% 
% [lat,lon] = binind2latlon(...,'rows',NumberOfRows) specifies the number of rows in the 
% grid. By default, binind2latlon will try to figure out the number of rows automatically, 
% but there's no guarantee it'll work. If you know the number of rows, specify them just
% to be sure. Common numbers of rows are as follows: 
% 
% * 180 rows for 1 a degree grid
% * 2160 rows for 5 minute grid
% * 4320 rows for a 1.5 minute grid
% 
%% Examples
% For examples type this into your Command Window: 
% 
%   showdemo binind2latlon_documentation
% 
%% Author Info 
% This function was written by Chad A. Greene of the University of Texas at Austin. 
% September 11, 2017. 

%% Input checks

narginchk(1,3) 
nargoutchk(2,2) 

%% Determine number of rows in sinusoidal grid:

% Start by assuming a a value based on maximum bin index: 

maxbin = max(binind); 

% One degree grid (111 km): 
if maxbin<50e3
   N = 180; 
end

% 5 minute grid (9.28 km) 
if maxbin>50e3 & maxbin<6e6
   N = 2160; 
end

% 2.5 minute grid (4.64 km) 
if maxbin>6e6
   N = 4320; 
end

% If user entered a number of rows, use that value instead: 
if nargin>1
  
   tmp = strcmpi(varargin,'rows'); 
   if any(tmp) 
      N = varargin{find(tmp)+1};
      assert(isscalar(N)==1,'Input error: the number of rows must be scalar.') 
   end
end

%% Form the grid

% Making the grid persistent will save a couple seconds each time if binind2latlon is called more than once. 
persistent lat_grd lon_grd grd fisf

if size(lat_grd,2)~=N
   grd = []; 
end

if isempty(grd) 

   % delta lat per row: 
   dlat = 180/N; 

   % centered latitude values corresponding to each row: 
   lat_array = ((-90+dlat/2):dlat:(90-dlat/2))'; 

   % Number of bins in each row: 
   bins_per_row = round(2*N*cosd(lat_array)); 

   % Preallocate an empty grid for bin numbers: 
   grd = nan(N,max(bins_per_row)); 

   % Also preallocate an empty longitude grid: 
   lon_grd = grd; 

   % Start a counter: 
   sm = 0; 

   % Solve row-by-row
   for row = 1:N

      % Assign bin numbers to each row: 
      grd(row,1:bins_per_row(row)) = sm+1:sm+bins_per_row(row); 
      sm = sm+bins_per_row(row); 

      % Get longitude values for this grid: 
      dlon = 360/bins_per_row(row); 
      lon_grd(row,1:bins_per_row(row)) = (-180+dlon/2):dlon:(180-dlon/2); 
   end

   % make a grid of latitudes to match the grid of bin numbers and longitudes: 
   lat_grd = repmat(lat_array,[1 max(bins_per_row)]); 
   
   lat_grd = rot90(flipud(lat_grd),-1); 
   lon_grd = rot90(flipud(lon_grd),-1); 
   grd = rot90(flipud(grd),-1);
   grd = grd(:); 
   fisf = find(isfinite(grd)); 
end

%% Connect bin indices to lat lon values: 

ind = interp1(grd(fisf),fisf,double(binind),'nearest'); 
lat = lat_grd(ind); 
lon = lon_grd(ind); 

end