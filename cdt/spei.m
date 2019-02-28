function [s,tint] = spei(t,prec,pevap,varargin)
% spei computes the standardised precipitation-evapotranspiration index 
% based on a standardization of a simplified water balance based on the 
% climatology of a particular location. 
%
%% Syntax
%
%  s = spei(t,prec,pevap)
%  [s,tint] = spei(t,prec,pevap,'integrationtime',months)
%
%% Description
%
% s = spei(t,prec,pevap) computes the standardised precipitation-evapotranspiration
% index s, given precipitation prec and potential evaporation pevap corresponding 
% to times t. prec and pevap can be either be 1D vectors or 3D cubes, whose
% first two dimensions are spatial and whose third dimension corresponds to times 
% t. The dimensions of prec and pevap must agree. Times t can be datetime 
% or datenum format. 
%
% [s,tint] = spei(t,prec,pevap,'integrationtime',months) integrates over 1, 2, 3, 4, 6, 
% or 12 months. The default integration time is 1 month. Output tint contains
% the dates of the reduced time series.
%
%% Examples 
% For examples, type 
% 
%   cdt spei 
% 
%% Author Info
% The spei function were written by José Delgado and Wolfgang Schwanghart 
% (University of Potsdam).
% February 2019. 
% 
% See also pet and solar_radiation. 

p = inputParser;
addParameter(p,'integrationtime',[],@(x) ismember(x,[1 2 3 4 6 12])); % integration time in months
addParameter(p,'dateloc','end');
addParameter(p,'movmean',31);
parse(p,varargin{:});

% check inputs
% t, prec, and prevap must have same number of observations, but can be
% prec and prevap can be space-time cubes
if any([isvector(prec), isvector(pevap)])
    % if any of the input arrays is a vector, all should be vectors
    prec  = prec(:);
    pevap = pevap(:);
    t     = t(:); 
    tf = isequal(size(prec),size(pevap),size(t));
    if ~tf
        error('Inconsistent size of input vectors.')
    end
    iscube = false;
else
    % input arrays are data cubes
    if ~isequal(size(prec),size(pevap))
        error('Inconsistent size of data cubes.');
    end
    if ~isequal(numel(t),size(prec,3))
        error('Inconsistent size of time vector and data cubes.')
    end
    
    gridsize = [size(prec,1) size(prec,2)];
    iscube   = true;
    
    prec  = cube2rect(prec);
    pevap = cube2rect(pevap);
end

D = prec - pevap;
% set values to double
D = double(D);

if ~isempty(p.Results.movmean) && isempty(p.Results.integrationtime)
    D = movmean(D,[p.Results.movmean-1 0],'omitnan','Endpoints','fill');
    D(1:p.Results.movmean,:) = nan;
end

if ~isempty(p.Results.integrationtime)
    % check time vector and apply time integration
    t       = t(:);
    [y,m]   = datevec(t);
    inttime = p.Results.integrationtime;
    
    mrange    = ceil(m/inttime);
    [un,~,IX]  = unique([y mrange],'rows');
    
    % nr of elements in the output vector
    nout = numel(un);
end

% temporal averaging
if iscube
    if ~isempty(p.Results.integrationtime)
    Dave = zeros(nout,size(D,2),class(D));
    for r = 1:size(D,2)
        Dave(:,r) = accumarray(IX,D(:,r),[nout 1],@mean,nan);
    end
    else
        Dave = D;
    end
      
    Dave = num2cell(Dave,1);
    
    % fit loglogistic distribution. 
    s    = cell(size(Dave));
    parfor r = 1:numel(Dave)
        pd    = fitdist(Dave{r}  - min(Dave{r}) + 1,'loglogistic');
        s{r}  = speifun(pd,Dave{r} - min(Dave{r}) + 1);
    end
    
    % Convert back to rect
    s = cell2mat(s);
    
    % Convert back to cube
    s = rect2cube(s,gridsize);  
else
    if ~isempty(p.Results.integrationtime)
        Dave = accumarray(IX,D,[nout 1],@mean,nan);
    else
        Dave = D;
    end
    pd = fitdist(Dave - min(Dave) + 1,'loglogistic');
    s  = speifun(pd,Dave - min(Dave) + 1);
end

% Finally, return time vector
if ~isempty(p.Results.integrationtime)
    dateloc = validatestring(p.Results.dateloc,{'start','end','centered'});
    IX2  = (1:numel(y))';
    switch dateloc
        case 'centered'
            tint = accumarray(IX,IX2,[nout 1],@(IX2) datenum(mean([max(t(IX2)) min(t(IX2))])));
        case 'start'
            tint = accumarray(IX,IX2,[nout 1],@(IX2) datenum(min(t(IX2))));
        case 'end'
            tint = accumarray(IX,IX2,[nout 1],@(IX2) datenum(max(t(IX2))));
    end
    tint = datetime(tint,'ConvertFrom','datenum');
else
    tint = t;
end
end
%% 
function s = speifun(pd,x)

Fx = cdf(pd,x);
P  = 1-Fx;
si = P>0.5;
P(si) = 1-P(si);

W  = sqrt(-2*log(P));
s  = W - (2.515517 + 0.802853*W + 0.010328*W.^2)./...
         (1 + 1.432788*W + 0.189269*W.^2 + 0.001308*W.^3);
s(si) = -s(si);
end


