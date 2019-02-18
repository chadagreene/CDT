%% |labelborders| documentation 
% The |labelborders| function labels borders of nations or US states on an 
% unprojected map, and does *not* require Matlab's Mapping Toolbox
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  labelborders(place)
%  labelborders(...,TextProperty,TextValue)
%  h = labelborders(...)
% 
%% Description 
% 
% |labelborders(place)| labels the borders of a place, which can be any country or US state.  place may also be 
% 'countries' to plot all national borders, 'states' to label all US state borders, or 'Continental US' to 
% plot only the continental United States (sorry Guam).  Note: to plot the nation of Georgia, use 'Georgia'.
% To plot the US state of Georgia, specify 'Georgia.' with a period. 
%
% |labelborders(...,TextProperty,TextValue)| specifies text formatting.
%
% |h = labelborders(...)| returns a handle |h| of plotted text object(s).  
%
%% Example 1
% Here are some borders plotted with the <borders_documentation.html |borders|> 
% function. Label Russia with simple black text and label Canada with silly
% big green text with a yellow background:

borders
labelborders 'Russia' 

labelborders('Canada','fontsize',30,...
   'color',rgb('green'),'backgroundcolor',rgb('yellow'))

%% Example 2: 
% Plot an <earthimage_documentation.html |earthimage|>, zoom in on Europe, 
% and place gray italic text labels on the map:  

figure
earthimage
axis([-10 30 35 60]) % zooms in on Europe
labelborders('countries','color',rgb('gray'),'fontangle','italic')

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 