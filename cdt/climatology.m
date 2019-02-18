function [Ac,tc] = climatology(A,t,varargin) 
% climatology gives typical values of a variable as it varies throughout the year. 
% The output of this function includes the overall mean (whereas the output
% of the season function does not.)
% 
%% Syntax 
% 
%  [Ac,tc] = climatology(A,t) 
%  [Ac,tc] = climatology(...,'daily')  
%  [Ac,tc] = climatology(...,'monthly') 
%  [Ac,tc] = climatology(...,'detrend',DetrendOption) 
%  [Ac,tc] = climatology(...,'dim',dimension) 
%  Ac = climatology(...,'full') 
% 
%% Description 
% 
% [Ac,tc] = climatology(A,t) gives the typical values of variable A as it changes throughout the year.
% Times times t are in datenum or datetime format. If t is daily, output tc is 1 to 366 and Ac will contain average values
% for each of the 366 days of the year. If inputs are monthly, tc is 1:12 and Ac will contain average values
% for each of the 12 months of the year. 
%
% [Ac,tc] = climatology(...,'daily') specifies directly that inputs are daily resolution. The climatology function
% will typically figure this out automatically, but if you have large missing gaps in your data you may wish
% to ensure correct results by specifying daily. 
% 
% [Ac,tc] = climatology(...,'monthly') as above, but forces monthly solution. 
%
% [Ac,tc] = climatology(...,'detrend',DetrendOption) specifies a baseline relative to which seasonal anomalies are 
% determined. Options are 'linear', 'quadratic', or 'none'. By default, anomalies are calculated after 
% removing the linear least squares trend, but if, for example, warming is strongly nonlinear, you may prefer
% the 'quadratic' option. Default is 'linear'. 
%
% [Ac,tc] = climatology(...,'dim',dimension) specifies a dimension along which to assess seasons. By default, 
% if A is 1D, seasonal cycle is returned along the nonsingleton dimension; if A is 2D, climatology is performed
% along dimension 1 (time marches down the rows); if A is 3D, climatology is performed along dimension 3. 
% 
% Ac = climatology(...,'full') returns Ac for the entire time series A. This is a convenient option for looking
% at the components of a long time series separately. 
% 
%% Examples
% For examples, type 
% 
%   cdt climatology
%
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% Institute for Geophysics (UTIG), July 2017. 
% http://www.chadagreene.com
% 
% See also: deseason, sinefit, and climatology. 

%% Initial error checks: 

assert(nargin>=2,'Input error: the climatology function reqires at least to inputs.') 
assert(ismember(length(t),size(A))==1,'Error: length of t must match dimensions of A.') 
assert(isvector(t)==1,'Error: time vector t must be a vector.') 

%% Set defaults: 

fullout = false; % by default, do not return the full length of the time series. 

t = datenum(t); 
if (max(t)-min(t))<364
   warning(['The time series is only ',num2str(max(t)-min(t)+1),' days long, so estimating a seasonal cycle from this dataset might not make sense.'])
end

% Try to determine temporal resolution automatically: 
dt = diff(t); 

% If most time steps are less than 10 days, evaluate the daily signal: 
if median(dt(isfinite(dt)))<10 
   res = 'daily'; 
else
   res = 'monthly'; 
end

DetrendOption = 'linear'; 
dim = 0; % use default dimension options unless otherwise specified
ND = ndims(A);

if isvector(A)
   ND = 1; 
end

%% Parse inputs: 

if nargin>2
   
   if any(strcmpi(varargin,'daily'))
      res = 'daily'; 
   end
   
   if any(strncmpi(varargin,'monthly',5))
      res = 'monthly'; 
   end
   
   
   if any(strcmpi(varargin,'full'))
      fullout = true; 
   end
   
   tmp = strncmpi(varargin,'detrend',4); 
   if any(tmp)
      DetrendOption = varargin{find(tmp)+1}; 
   end
   
   tmp = strncmpi(varargin,'dimension',3); 
   if any(tmp)
      dim = varargin{find(tmp)+1}; 
      assert(isscalar(dim)==1,'Input error: dimension must be 1 through 2.') 
      assert(dim>0,'Input error: dimension must be 1 or 2.') 
      assert(dim<3,'Input error: dimension must be 1 or 2.') 
      assert(ND==2,'You can only specify a dimension if A is a 2D matrix.') 
   end
end

%% Get input data into standardized shape: 
% Analysis will be performed such that time marches down the rows of Ar. Ar means a reshaped version of A. 


switch ND
   case 1 
      Ar = A; 
      if isrow(Ar)
         Ar = Ar'; 
         wasrow = true; 
      else
         wasrow = false; 
      end
      
   case 2
      Ar = A; 
      if dim==2
         Ar = permute(A,[2 1]); 
      end
      
   case 3 
      Ar = cube2rect(A); 
      
   otherwise
      error('Something went wrong and I have no clue how we got here.') 
      
end
        
if isrow(t) 
   t = t'; 
end

N = length(t); 
assert(N==size(Ar,1),'Error: Length of t must match the dimension along A.') 

%% Detrend 

% Center and scale t to improve fit: 
tsc = (t(:)-mean(t))/std(t); 

meanAr = mean(Ar,'omitnan'); 
      
switch DetrendOption(1:3)
   case 'non'
      % do nothing. 
   
   case 'lin'
      Ar = Ar - [tsc ones(N,1)]*([tsc ones(N,1)]\Ar); 

   case 'qua'
      Ar = Ar - [tsc.^2 tsc ones(N,1)]*([tsc.^2 tsc ones(N,1)]\Ar); 
            
   otherwise
      error('Unrecognized detrending method.') 
end

%% Calculate seasonal cycle

switch res
   case 'daily' 
      % Day of year: 
      tc = floor(doy(t)); 

      if fullout
         Ac = nan(size(Ar)); 
      else
         Ac = nan(366,size(Ar,2)); 
      end
      
      for k = 1:365
         ind = tc==k;
         if fullout
            tmp = finitemean(Ar(ind,:)); 
            Ac(ind,:) = repmat(tmp,sum(ind),1);
         else
            Ac(k,:) = finitemean(Ar(ind,:));
         end
      end

      % For day 366, we can't take the average of only the days 366 b/c that could introduce strange
      % sensitivities or jumps in the average compared to surrounding days. So let's use the average
      % of ALL days 365, 366, and 1 of the year: 
      ind = tc==1 | tc==365 | tc==366;
      
      if fullout
         tmp = finitemean(Ar(ind,:)); 
         Ac(tc==366,:) = repmat(tmp,sum(tc==366),1);
         tc = t; 
      else
         Ac(366,:) = finitemean(Ar(ind,:));
         tc = 1:366;
      end
      
   case 'monthly' 
      
      
      if fullout
         Ac = nan(size(Ar)); 
      else
         Ac = nan(12,size(Ar,2)); 
      end
      
      [~,mo,~] = datevec(t); 
      
      for k = 1:12 
         ind = mo==k; 
         if fullout
            tmp = finitemean(Ar(ind,:)); 
            Ac(ind,:) = repmat(tmp,sum(ind),1);
         else
            Ac(k,:) = finitemean(Ar(ind,:));
         end
      end


end

%% Build climatology: 
% It's just the seasonal component plus the mean: 

Ac = Ac + meanAr; 

%% Reshape to match input 

switch ND
   case 1 
      if wasrow
         Ac = Ac'; 
         tc = tc'; 
      end
      
   case 2 
      if dim==2
         Ac = ipermute(Ac,[2 1]); 
      end
      
   case 3 
      Ac = rect2cube(Ac,size(A)); 
end
      

end



%% Subfunctions 

function mn = finitemean(M)
% mean of finite values

nanz = isnan(M);
M(nanz) = 0;

n = sum(~nanz,1);
n(n==0) = NaN; 
mn = sum(M,1)./n;
end
