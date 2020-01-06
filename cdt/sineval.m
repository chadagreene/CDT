function y = sineval(ft,t) 
% sineval produces a sinusoid of specified amplitude and phase with
% a frequency of 1/yr. 
% 
%% Syntax
% 
%  y = sineval(ft,t)
% 
%% Description 
% 
% y = sineval(ft,t) evaluates a sinusoid of given fit parameters ft 
% at times t. Times t can be in datenum, datetime, or datestr format, 
% and parameters ft correspond to the outputs of the sinefit function
% and can have 2 to 5 elements, which describe the following: 
% 
%   2: ft = [A doy_max] where A is the amplitude of the sinusoid, and doy_max 
%      is the day of year corresponding to the maximum value of the sinusoid. 
%      The default TermOption is 2.
%   3: ft = [A doy_max C] also estimates C, a constant offset.
%   4: ft = [A doy_max C trend] also estimates a linear trend over the entire
%      time series in units of y per year.
%   5: ft = [A doy_max C trend quadratic_term] also includes a quadratic term
%      in the solution, but this is experimental for now, because fitting a 
%      polynomial to dates referenced to year zero tends to be scaled poorly.
% 
%% Examples
% For examples, type: 
% 
%  cdt sineval
% 
%% Author Info
% Written by Chad A. Greene
% 
% See also sinefit and polyval. 

%% Error checks: 

narginchk(2,2) 
assert(numel(ft)>=2,'Error: Input parameters ft must contain at least an amplitude and a phase term.') 

%% Allow for 3d field: 

nterms = 2; % the default 

switch ndims(ft) 
   case {1,2} 
      A = ft(:,1); 
      ph = ft(:,2); 
      if size(ft,2)>2
         C = ft(:,3); 
         nterms = 3; 
         if size(ft,2)>3
            tr = ft(:,4); 
            nterms = 4; 
            if size(ft,2)>4
               quad_term = ft(:,5); 
               nterms = 5; 
            end 
         end
      end
      
   case 3 % this is essentially map view 
      A = ft(:,:,1); 
      ph = ft(:,:,2); 
      if size(ft,3)>2
         C = ft(:,:,3); 
         nterms = 3; 
         if size(ft,3)>3
            tr = ft(:,:,4); 
            nterms = 4; 
            if size(ft,3)>4
               quad_term = ft(:,:,5); 
               nterms = 5; 
            end 
         end
      end
      
   otherwise 
      error('Invalid format of ft.') 
end 
      
%% Evaluate sinusoid: 

% normalize phase: 
ph = 0.25 - ph/365.24; 

% Convert times to fraction of year: 
yr = doy(t,'decimalyear'); 

switch nterms
   case 2
       y = A.*sin((yr + ph)*2*pi); 
   case 3 
       y = A.*sin((yr + ph)*2*pi) + C; 
   case 4
       y = A.*sin((yr + ph)*2*pi) + C + tr.*yr; 
   case 5
       y = A.*sin((yr + ph)*2*pi) + C + tr.*yr + quad_term.*yr.^2; 
   otherwise 
      error('Unrecognized sinusoidal fit model.') 
end


end



function n = doy(t,option) 
% doy returns the Julian day of year. 
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
% doy('july 4, 2017')
% ans =
%         185.00
%         
% doy(datenum('july 4, 2017'))
% ans =
%         185.00
%         
% doy(datetime('july 4, 2017'))
% ans =
%         185.00
%         
% doy('july 4, 2017','decimalyear')
% ans =
%        2017.51
%        
% doy('july 4, 2017','remdecimalyear')
% ans =
%           0.51
%           
%% Author Info: 
% This function was written by Chad A. Greene of the University of Texas Institute for 
% Geophysics (UTIG), June 2017. 
% 
% See also datenum, datevec, and datestr. 

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
