%% |mask2outline| documentation
% |mask2outline| converts a logical mask into an outline or border. 
% 
%% Syntax 
% 
%  [xb,yb] = mask2outline(x,y,mask)
%  [xb,yb] = mask2outline(x,y,mask,'buffer',buf)
% 
%% Description 
% 
% |[xb,yb] = mask2outline(x,y,mask)| returns the coordinates |xb,yb| of the 
% outline of a 2D mask whose input coordinates pixel centers are given by 
% |x,y|. 
% 
% |[xb,yb] = mask2outline(x,y,mask,'buffer',buf)| specifies a buffer in units
% of |x,y| to place around the |mask|. For example, if the units of |x| and |y| are 
% meters and |buf=10e3|, then that places a 10 km buffer around the mask. The 
% buffer can be negative to buffer into the mask. 
% 
%% Example 
% Consider this mask: 

% Load the default peaks dataset: 
[X,Y,Z] = peaks(500); 

% Convert x,y coordinates to something like meters to make it intuitive:
X = X*1000;  
Y = (Y+5)*1000; 

% Define a mask as anything where Z>5: 
mask = Z>5; 

% Plot the mask: 
figure
imagescn(X,Y,mask)
xlabel 'eastings (m)' 
ylabel 'northings (m)'

%% 
% Let's say you want to find the coordinates that mark the boundary of the 
% mask: 

[xb,yb] = mask2outline(X,Y,mask); 

% Plot the border with a red outline: 
hold on
plot(xb,yb,'r','linewidth',2)

%% Buffer the border 
% Suppose you want to buffer the border by 600 meters: 

[xb,yb] = mask2outline(X,Y,mask,'buffer',600); 

% Plot the border with a red dotted outline: 
plot(xb,yb,'r:','linewidth',2)

%% Multipe sections
% Suppose your mask has multiple sections: 
mask = Z>3; 

% Plot the mask: 
figure
imagescn(X,Y,mask)
xlabel 'eastings (m)' 
ylabel 'northings (m)'

%% 
% The same method as above works. (This is really just an exercise in the 
% documentation to ensure consistent behavior in case of future changes 
% to the function). 

[xb,yb] = mask2outline(X,Y,mask); 

% Plot the border with a red outline: 
hold on
plot(xb,yb,'r','linewidth',2)

%% 
% Buffer in: This time we'll buffer _into_ each mask by 200 m: 

[xb,yb] = mask2outline(X,Y,mask,'buffer',-200); 

% Plot the border with a red dotted outline: 
plot(xb,yb,'r:','linewidth',2)

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the NASA's Jet Propulsion Laboratory, September 2020. 