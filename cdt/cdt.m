function [] = cdt(functionName) 
% cdt displays a help window with documenation for Climate Data Tools functions. 
% 
%% Syntax 
% 
%  cdt 
%  cdt functionName 
% 
%% Description
% 
% cdt typing cdt into the command window opens a Help menu with a list of functions available 
% in the Climate Data Tools package.  
% 
% cdt functionName specifies a function name for which you'd like to view documentation.
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at Austin
% Institute for Geophysics (UTIG), February 2017. 
% http://www.chadagreene.com 
% 
% See also: help and showdemo. 

try
   showdemo(strcat(functionName,'_documentation')); 
catch
   if nargin==1
      disp(['Cannot find documentation for a CDT function called ',functionName,'.'])
      disp('Opening the CDT Contents page.')
   end
   showdemo('CDT_Contents') 
end

end
   