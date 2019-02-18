function h = plotpsd(y,x_or_Fs,varargin)
% plotpsd plots a power spectral density of a time series using
% Matlab's inbuilt periodogram function. (Requires Matlab's Signal Processing
% Toolbox.) 
% 
%% Syntax 
% 
%  plotpsd(y,Fs) 
%  plotpsd(y,x) 
%  plotpsd(...,LineProperty,LineValue) 
%  plotpsd(...,'logx') 
%  plotpsd(...,'db') 
%  plotpsd(...,'lambda') 
%  h = plotpsd(...) 
% 
%% Description
% 
% plotpsd(y,Fs) plots a power spectrum of 1D array y at sampling frequency Fs
% using the periodogram function. Sampling frequency Fs must be a scalar.  
%
% plotpsd(y,x) plots a power spectrum of y referenced to an independent variable
% x. This syntax requires x and y to be of equal length and x must be equally
% spaced and monotically increasing.  For time series, x likely has units of time; 
% for spatial analysis x may have units of length.  
%
% plotpsd(...,LineProperty,LineValue) specifies the plot's line style with any
% combinations of LineSpec properties (e.g., 'color','r','linewidth',2, etc). 
%
% plotpsd(...,'logx') specfies a semilogx plot.  
%
% plotpsd(...,'db') plots power spectrum in decibels.  
%
% plotpsd(...,'lambda') labels horizontal axis as wavelengths rather than the default
% frequency. Note, this syntax assumes lambda = 1/f.   
%
% h = plotpsd(...) returns a handle h of the plotted graphics object. 
%
%% Examples
% For examples, type 
% 
%  cdt plotpsd
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics, October 2015.
% http://www.chadagreene.com.
% 
% See also periodogram and filt1. 

%% Input checks

assert(license('test','signal_toolbox')==1,'Sorry, the plotpsd function requies Matlab''s Signal Processing Toolbox.')
assert(isvector(y)==1,'Input y must be a vector.')

%% Set defaults

plotlogx = false; 
plotdb = false; 
plotlambda = false; 
period = false; 

%% Parse inputs 

% Did user declare sampling frequence or independent vector array? 
if isscalar(x_or_Fs) 
    Fs = x_or_Fs; 
else
    assert(numel(x_or_Fs)==numel(y),'I''m having trouble parsing inputs in plotpsd. The second input argument must be a sampling frequency or an independent vector array.')
    Fs = 1/unique(diff(x_or_Fs)); 
    assert(isscalar(Fs)==1,'If x must be equally spaced and monotonically increasing.') 
end

if nargin>2
    tmp = strncmpi(varargin,'logx',3); 
    if any(tmp) 
        plotlogx = true; 
        varargin = varargin(~tmp); 
    end
    
    tmp = strcmpi(varargin,'db'); 
    if any(tmp)
        plotdb = true; 
        varargin = varargin(~tmp); 
    end
    
    tmp = strncmpi(varargin,'lambda',4); 
    if any(tmp) 
        plotlambda = true; 
        varargin = varargin(~tmp); 
    end
        
end

%% Perform mathematics: 

[ydata,xdata] = periodogram(y,[],[],Fs);

%% Convert data to match user preferences: 

if plotdb
    ydata = pow2db(ydata); 
end

if plotlambda
    xdata = 1./xdata; 
end

%% Plot: 

if plotlogx
    h = semilogx(xdata,ydata,varargin{:}); 
else
    h = plot(xdata,ydata,varargin{:}); 
end

box off

if plotlambda
    set(gca,'XDir','reverse') 
end

%% Clean up: 

if nargout == 0
    clear h
end

end

