%% |cbdate| documentation
% The |cbdate| function formats colorbar ticks as dates strings. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  cbdate
%  cbdate(h)
%  cbdate(datenums)
%  cbdate(datenums,dateformat) 
%  cbdate(datestrs)
%  cbdate('horiz') 
%  h = cbdate(...) 
% 
%% Description
% 
% |cbdate| converts tick marks of current colorbar to date strings. 
%
% |cbdate(h)| specifies a colorbar handle |h| on which to perform |cbdate|. If
% no handle is specified, cbdate will try to find a current colorbar. 
% 
% |cbdate(datenums)| specifies datenums to set as tick marks. 
%
% |cbdate(datenums,dateformat)| specifies date formatting as described in the 
% documentation for datestring. For example, |'mmm yyyy'| will print date
% strings as Nov 2014. 
%
% |cbdate(datestrs)| specifies date strings to use as colorbar ticks. 
% 
% |cbdate('horiz')| must be declared if the colorbar is horizontal
% (pre-R2014b). 
% 
% |h = cbdate(...)| returns a colorbar handle |h|. 
% 
%% Example
% You've plotted some data with its color scaled as a function of date. The
% plot looks like this: 

t = datenum(2014,1:24,15); 
y = sin(t/200); 

figure('pos',[100 100 700 400])
scatter(t,y,60,t,'filled'); 
datetick('x','yyyy')

colorbar

%% 
% 7.361 x 10^5 does not mean much to most folks. Let's change those datenum
% ticks on the colorbar to date strings: 

cbdate
%% 
% Your original data were monthly data, centered on the 15th of each month,
% so it does not make much sense to have colorbar tick labels label days.
% Monthly resolution is about the best we can describe. So let's format
% those tick labels to show only the month: 

cbdate('mmmm')

%% 
% Or perhaps you'd like your tick labels referenced to specific input data points. 
% The variable |t| is in |datenum| format, so it can be used as an input directly to |cbdate|. 
% Here we label every third month:

cbdate(t(1:3:end))

%% 
% Or perhaps you want to label two specific dates:

cbdate({'apr 1, 2014';'jan 12, 2015'})

%% 
% Perhaps your colorbar is horizontal: 

colorbar('location','north');
cbdate('horiz','mmm-yy')

%% Author Info: 
% This function was written by <http://www.chadagreene.com Chad A. Greene>
% of the University of Texas Institute for Geophysics
% (<http://www.ig.utexas.edu/people/students/cgreene/ UTIG>) in November of
% 2014. Updated for the Climate Data Toolbox for Matlab in 2019. 