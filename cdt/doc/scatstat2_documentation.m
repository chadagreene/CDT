%% |scatstat2| documentation 
% The |scatstat2| function returns statistical values of all points within a given 
% radius of each value. This is similar to taking a moving mean, but 
% points do not need to be equally spaced.
% 
% See also <scatstat1_documentation.html |scatstat1|>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  zbar = scatstat2(x,y,z,radius)
%  zbar = scatstat2(x,y,z,radius,fun) 
%  ybar = scatstat1(...,options) 
% 
%% Description 
% 
% |zbar = scatstat2(x,y,z,radius)| returns the mean of all |z| values 
% within specified radius at each point (x,y).  
% 
% |zbar = scatstat2(x,y,z,radius,fun)| applies any function fun to |z|
% values, default |fun| is |@mean|, but it could be anything you want, 
% even your own anonymous function. 
% 
% |zbar = scatstat2(...,options)| allows any options that the function
% accepts. For example, 'omitnan'. 
% 
%% Example: Local median 
% Consider this noisy data set of 5000 scattered points:

N = 5000; 
x = randi(750,N,1); 
y = randi(750,N,1);

% z contains *real* structure, plus lots of noise:
z = sind(x) + cosd(y) + 3*randn(size(x));  

scatter(x,y,10,z,'filled') 
axis image 
title 'noisy scattered 2D data'

%% 
% It almost looks like there's nothing there but noise. Filter out the 
% high-frequency noise by taking the local median within a 75 unit radius: 

z_median = scatstat2(x,y,z,75,@median); 

scatter(x,y,10,z_median,'filled') 
axis image 
title 'local median' 

%% Author info: 
% This function was written by <http://www.chadagreene.com Chad A. Greene> of the University 
% of Texas at Austin's Institute for Geophysics (UTIG), June 2016. 
