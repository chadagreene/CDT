%% |labelbordersm| documentation 
% The |labelbordersm| function labels borders of nations or US states on a 
% map created by Matlab's Mapping Toolbox. For a version that does not require
% Matlab's Mapping Toolbox, use <labelborders_documentation.html |labelborders|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax 
% 
%  labelbordersm(place)
%  labelbordersm(...,TextProperty,TextValue)
%  h = labelbordersm(...)
% 
%% Description 
% 
% |labelbordersm(place)| labels the borders of a place, which can be any country or US state.  place may also be 
% 'countries' to plot all national borders, 'states' to label all US state borders, or 'Continental US' to 
% plot only the continental United States (sorry Guam).  Note: to plot the nation of Georgia, use 'Georgia'.
% To plot the US state of Georgia, specify 'Georgia.' with a period. 
%
% |labelbordersm(...,TextProperty,TextValue)| specifies text formatting.
%
% |h = labelbordersm(...)| returns a handle |h| of plotted text object(s).  
%
%% Example
% Here are some borders plotted with the <bordersm_documentation.html |bordersm|> 
% function. Label Russia with simple black text and label Canada with silly
% big green text with a yellow background:

bordersm
labelbordersm 'Russia' 

labelbordersm('Canada','fontsize',30,...
   'color',rgb('green'),'backgroundcolor',rgb('yellow'))

%% Example 2: 
% Label all the African countries: 

worldmap('Africa')

bordersm
labelbordersm

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 