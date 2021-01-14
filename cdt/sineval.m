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

