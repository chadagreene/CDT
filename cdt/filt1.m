function [yf,filtb,filta] = filt1(filtertype,y,varargin) 
% filt1 applies a zero-phase butterworth filter. (Requires Matlab's Signal
% Processing Toolbox.)
% 
%% Syntax
% 
%  yf = filt1(filtertype,y,'fc',Fc)
%  yf = filt1(filtertype,y,'Tc',Tc)
%  yf = filt1(filtertype,y,'lambdac',lambdac)
%  yf = filt1(...,'fs',Fs)
%  yf = filt1(...,'x',x)
%  yf = filt1(...,'Ts',Ts)
%  yf = filt1(...,'order',FilterOrder)
%  yf = filt1(...,'dim',dim)
%  [yf,filtb,filta] = filt1(...)
% 
%% Description
% 
% yf = filt1(filtertype,y,'fc',Fc) filters 1D signal y
% using a specified filtertype and cutoff frequency Fc. For 
% high-pass or low-pass filters Fc must be a scalar. For band-
% pass and band-stop filters Fc must be a two-element array. The 
% filtertype can be 
% 
%   * 'hp' high-pass with scalar cutoff frequency Fc
%   * 'lp' low-pass with scalar cutoff frequency Fc
%   * 'bp' band-pass with two-element cutoff frequencies Fc
%   * 'bs' band-stop with two-element cutoff frequencies Fc 
% 
% |yf = filt1(filtertype,y,'Tc',Tc)| specifies cutoff period(s)
% rather than cutoff frequencies. This syntax assumes T = 1/f and is exactly
% the same as the 'lambdac' option, but perhaps a little more intuitive for
% working with time series. 
% 
% yf = filt1(filtertype,y,'lambdac',lambdac) specifies cutoff
% wavelength(s) rather than cutoff frequencies.  This syntax assumes
% lambda = 1/f. 
% 
% yf = filt1(...,'fs',Fs) specifies a sampling frequency Fs. 
% If neither 'fs', 'x', nor 'Ts' are specified, Fs = 1 is assumed.    
% 
% yf = filt1(...,'x',x) specifies a vector of  monotonically-
% increasing, equally-spaced sampling times or x locations corresponding
% to y, which is used to determine sampling frequency. If neither 'fs', 
% 'x', nor 'Ts' are specified, Fs = 1 is assumed.  
% 
% yf = filt1(...,'Ts',Ts) specifies a sampling period or sampling distance
% such that Fs = 1/Ts. If neither 'fs', 'x', nor 'Ts' are specified, 
% Fs = 1 is assumed.    
% 
% yf = filt1(...,'order',FilterOrder) specifies the order (sometimes 
% called rolloff) of the Butterworth filter. If unspecified, 
% FilterOrder = 1 is assumed. 
% 
% yf = filt1(...,'dim',dim) specifies a dimension along which to operate. 
% By default, filt1 operates along the first nonsingleton dimension for 1D or 
% 2D arrays, but operates down dimension 3 for 3D gridded datasets. 
% 
% [yf,filtb,filta] = filt1(...) also returns the filter numerator 
% filta and denominator filtb. 
% 
%% Example 
% For examples, type 
% 
%  cdt filt1
% 
%% Author Info
% The filt1 function was written by Chad A. Greene of the University of
% Texas at Austin's Institute for Geophysics (UTIG), October 2015. 
% http://www.chadagreene.com
% 
% See also butter, filtfilt, and scatstat1. 

%% Initial error checks: 

assert(license('test','signal_toolbox')==1,'The filt1 function requires Matlab''s Signal Processing Toolbox.')
assert(nargin>3,'Not enough input arguments.') 
assert(sum(strcmpi({'hp';'lp';'bp';'bs';'high';'low';'bandpass';'stop'},filtertype))==1,'Filter type must be ''hp'', ''lp'', or ''bp''.'),
assert(sum([strcmpi(varargin,'fc') strcmpi(varargin,'lambdac') strcmpi(varargin,'Tc')])==1,'Must declare a cutoff frequency (or frequencies) ''fc'',  cutoff wavelength(s) ''lambdac'', or cutoff period(s) ''Tc''.')

%% Define defaults: 

order = 1; 
Fs = 1; 

%% Parse Inputs: 

% Replace filtertype string if necessary: 
filtertype = strrep(filtertype,'hp','high'); 
filtertype = strrep(filtertype,'lp','low'); 
filtertype = strrep(filtertype,'bp','bandpass'); 
filtertype = strrep(filtertype,'bs','stop'); 

% Is a sampling frequency defined? 
tmp = strcmpi(varargin,'fs'); 
if any(tmp) 
    Fs = varargin{find(tmp)+1}; 
end

% Define sampling period: 
tmp2 = strcmp(varargin,'Ts'); 
if any(tmp2)
    Fs = 1/varargin{find(tmp2)+1}; 
end

% Define sampling vector: 
tmp3 = strcmp(varargin,'x'); 
if any(tmp3) 
    x = varargin{find(tmp3)+1}; 
    assert(isvector(x)==1,'Input x must be a vector.')
    assert(length(x)==length(y),'Dimensions of input vector x must match dimensions of input signal vector y.') 
    
    Ts = unique(diff(x));
    assert(all([isscalar(Ts) isfinite(Ts)])==1,'Input vector x must be equally spaced.')
    Fs = 1/Ts; 
end

% Make sure user didn't try to define a sampling frequency AND a sampling period: 
assert(any(tmp)+any(tmp2)+any(tmp3)<2,'I am confused. It looks like you have attempted to define a sampling frequency and a sampling period.  Check inputs of filt1.') 

% Cutoff Frequency: 
tmp = strcmpi(varargin,'fc'); 
if any(tmp) 
    cutoff_freqs = varargin{find(tmp)+1}; 
end

% Cutoff wavelength: 
tmp2 = strncmpi(varargin,'lambdac',4); 
if any(tmp2) 
    cutoff_freqs = 1./varargin{find(tmp2)+1}; 
end
% ...(or cutoff period, if that's what the user is into)
tmp2 = strcmpi(varargin,'Tc'); 
if any(tmp2) 
    cutoff_freqs = 1./varargin{find(tmp2)+1}; 
end
assert(any(tmp)+any(tmp2)<2,'I am confused. It looks like you have attempted to define a cutoff frequency and a cutoff period.  Check inputs of filt1.') 

% Filter order: 
tmp = strncmpi(varargin,'order',3); 
if any(tmp) 
    order = varargin{find(tmp)+1}; 
end

% Dimension of operation: 
tmp = strncmpi(varargin,'dimension',3); 
if any(tmp)
   dim = varargin{find(tmp)+1}; 
   assert(ismember(dim,[1 2 3]),'Error: filt1 can only operate along dimension 1, 2, or 3.')
else
   if ndims(y)==3 % if it's a 3D matrix, operate down dim 3
      dim = 3; 
   else
      dim = find(size(y)>1,1,'first'); % if it's 2D, operate down the first nonsingleton dimension. 
   end
end

%% Error checks on inputs: 

assert(isscalar(Fs)==1,'Input error: Undefined sampling frequency or period.')

switch filtertype 
    case {'low','high'} 
        assert(isscalar(cutoff_freqs)==1,'Low-pass and High-pass filters require a scalar cutoff frequency.') 
        
    case {'stop','bandpass'} 
        assert(numel(cutoff_freqs)==2,'Bandpass and bandstop filters require a low and high frequency.') 
        cutoff_freqs = sort(cutoff_freqs); 
        
    otherwise
        error('Unrecognized filter type.') 
end

%% Reshape y if needed: 
      
switch dim
   case 1
      % do nothing
   case 2
      y = permute(y,[2 1]); 
   case 3
      mask = all(isfinite(y),3); 
      y = cube2rect(y,mask); 
   otherwise
      error('There''s really no way we should have gotten here.') 
end

%% Construct filter: 

nyquist_freq = Fs/2;             % Nyquist frequency
Wn=cutoff_freqs/nyquist_freq;    % non-dimensional frequency
[filtb,filta]=butter(order,Wn,filtertype); % construct the filter
yf=filtfilt(filtb,filta,y);   % filter the data with zero phase 

%% Unreshape: 

switch dim
   case 1
      % do nothing
   case 2
      yf = ipermute(yf,[2 1]); 
   case 3
      yf = rect2cube(yf,mask); 
   otherwise
      error('It''s even more confounding this time.') 
end

end