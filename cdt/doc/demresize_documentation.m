%% |demresize| documentation
% |demresize| works like |imresize|, but also resizes corresponding map coordinates. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents> 
% 
%% Syntax 
% 
%  [Zr,xr,yr] = demresize(Z,x,y,sc) 
%  [Zr,xr,yr] = demresize(...,'method') 
%  [Zr,xr,yr] = demresize(...,'Name',Value,...) 
%
%% Description 
%
% |[Zr,xr,yr] = demresize(Z,x,y,sc)| resizes Z using |imresize|, and corresponding
% vector or 2D grid coordinates |x| and |y| to a scalar scale |sc|. 
% 
% |[Zr,xr,yr] = demresize(...,'method')| specifies an interpolation method. Default
% is |'bicubic'|. 
% 
% |[Zr,xr,yr] = demresize(...,'Name',Value,...)| specifies any input name-value
% pairs accepted by |imresize|. 
% 
%% Example: 
% Consider this 20x20 grid: 

[X,Y,Z] = peaks(20); 
X = X+10; % (for clear distinction from y)

figure 
imagescn(X,Y,Z)

%% 
% These black dots mark the center points of each pixel in the 20x20 grid:

hold on
plot(X,Y,'k.') 

%% 
% Let's suppose you want to resize the grid to 1/3 of its original grid
% resolution. Here's how you would do that: 

[Zr,Xr,Yr] = demresize(Z,X,Y,1/3); 

% Plot as scatter circles with black edge markers: 
scatter(Xr(:),Yr(:),100,Zr(:),'filled','markeredgecolor','k') 

%% 
% Or if you prefer to see the new grid as its own |imagescn| plot: 

figure
imagescn(Xr,Yr,Zr)

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of NASA's Jet Propulsion Laboratory. 