function n = doy(t,option) 
% doy returns the day of year, numbered 1 through 366. 
% 
%% Syntax
% 
%  n = doy(t) 
%  n = doy(t,'decimalyear') 
%  n = doy(t,'remdecimalyear') 
% 
%% Description 
% 
% n = doy(t) gives the day of year (from 1 to 366.999) corresponding to the date(s) 
% given by t. Input dates can be datenum, datetime, or string format. 
% 
% n = doy(t,'decimalyear') gives the year in decimal form of input date t. It accounts 
% for leap years, so the decimal value for a given date will depend on whether it's a leap
% year. For example, July 4th of 2016 (a leap year) is 2016.5082 whereas July 4th of 2017
% (not a leap year) is 2017.5068. 
% 
% n = doy(t,'remdecimalyear') returns only the remainder of the decimal year, and is always
% in the range 0 to 1. 
% 
%% Examples: 
% For examples, type 
% 
%  cdt doy
%           
%% Author Info: 
% This function was written by Chad A. Greene of the University of Texas Institute for 
% Geophysics (UTIG), June 2017. 
% 
% See also day, datenum, datevec, and datestr. 

%% Error checks: 

narginchk(1,2)

%% Parse inputs: 

remdec = false; 
decyear = false; 

if nargin>1
   switch lower(option(1:3))
      case 'dec'
         remdec = true; 
         decyear = true; 
      case 'rem'
         remdec = true; 
      otherwise
         error('Unrecognized inputs.') 
   end
end

%% Perform mathematics: 

% If the input is a string, convert it to datenum: 
t = datenum(t); 

% Get the year of each input date: 
[yr,~,~] = datevec(t); 

% Datenum corresponding to the strike of midnight at New Years: 
tnye = datenum(yr,0,0,0,0,0); 

% The day of the year is the date minus the datenum of the New Year: 
n = t - tnye; 

if remdec 
   
   % Datenum of the ceiling new years: 
   tmax = datenum(yr+1,0,0,0,0,0); 
     
   % The year fraction is the day of year out of the total number of days in the year: 
   n = n./(tmax-tnye); 
   
   if decyear
      n = n+yr; 
   end
   
end

end
