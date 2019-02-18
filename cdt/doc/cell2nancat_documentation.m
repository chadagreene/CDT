%% |cell2nancat| documentation 
% The |cell2nancat| function concatenates elements of a cell into a NaN-separated vector. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax 
% 
%  xv = cell2nancat(xc)
%  [xv,yv,...,zv] = cell2nancat(xc,yc,...,zc)
% 
%% Description 
% 
% |xv = cell2nancat(xc)| concatenates the numeric arrays of cell array |xc| into
% a single vector separated by NaNs. 
% 
% |[xv,yv,...,zv] = cell2nancat(xc,yc,...,zc)| as above but for any number of 
% cell arrays. 
% 
%% Example 
% CDT comes with data for all the national and US states boundaries. Here's
% the format it's in: 

load borderdata
whos % prints name & size of each variable in workspace

%% 
% Thos are all cell arrays. Each of those 302 arrays contains the borders of 
% a different state or country. To see what that looks like, here are the 
% names and latitudes of the first three countries: 

[places(1:3) lat(1:3)]

%% 
% If you want to plot all the borderlines, your first inclination might be 
% to loop through each of the 302 entries and plot them individually, like this: 

hold on
for k = 1:302
   plot(lon{k},lat{k})
end

%% 
% However, looping is computationally slow and you might not want 300+ different
% objects plotted in your figure. So instead, you can turn each cell array into a vector and 
% plot everything together. 
% 
% Here's how |cell2nancat| works: Give it a cell array, and get a vector in return: 

latv = cell2nancat(lat);

whos lat latv

%% 
% Now that 302x1 cell array has been turned into a 574729x1 vector 
% array containing all the borderlines from |lat|. To use the function 
% on multiple cell arrays, just enter them all into |cell2nancat|: 

[latv,lonv,clatv,clonv] = cell2nancat(lat,lon,clat,clon); 

plot(lonv,latv,'b') % blue borderlines 
hold on
plot(clonv,clatv,'r.') % landmass centroids as red dots

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 
