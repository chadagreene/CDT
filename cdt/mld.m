function [pmld, mldtbl, pth, h] = mld(varargin)
%MLD Calculate mixed layer depth following Holte and Talley, 2009.
%
% pmld = mld(pres, temp)
% pmld = mld(pres, temp, salt)
% pmld = mld(..., param1, val1, ...)
% [pmld, mldtbl, pth, h] = mld(...)
%
% This function calculates mixed layer depth in a water column, following
% the algorithms of Holte & Talley, 2009:
%
% ﻿Holte J, Talley L (2009) A new algorithm for finding mixed layer depths
% with applications to argo data and subantarctic mode water formation. J
% Atmos Ocean Technol 26:1920–1939  
%
% The paper presents a variety of metrics that can be used to calculate
% MLD, using temperature, salinity, and/or potential density profiles.
% This function offers the option to either return a single one of the MLD
% calculations or the "best" according to the Holte & Talley algorithm;
% note that the Holte & Talley algorithm was designed with oceanic Argo
% float profiles in  mind, and therefore the hybrid algorithm is may not be
% the most applicable for profiles with non-oceanic features or a much
% finer or coarser depth/pressure resolution. 
%
% Note that the threshold method is one of the most common algorithms used
% to calculate mixed layer depth, and is also one of the quickest to run,
% so it is likely a good place to start if you just need a basic MLD
% calculation.    
%
% This function is an adaptation of the findmld.m code included as
% Supplementary Information with Holte & Talley, 2009.  It has been
% modified for clarity and efficiency, and to allow more flexibility in the
% input and output parameters.  Any discrepancies between this code and the
% original should be attributed to the authors of this toolbox and not to
% Holte & Talley.      
%
% Input arguments:
%
%   pres:           vector of pressure values (db).  Values should be
%                   strictly increasing positive values.  
%
%   temp:           vector of temperature values (deg C) at the given
%                   pressure values.
%
%   salt:           vector of salinity values; if not included, only
%                   temperature-based MLD will be calculated.  If included,
%                   salinity and potential density-based MLDs will be
%                   added as applicable to the chosen metric.
%
% Optional input arguments, passed as parameter/value pairs [default]:
%
%   metric:         mixed layer depth metric to use for output
%                   'threshold':  first depth, measured from reference
%                                 depth down, where profile value differs
%                                 from the reference depth value by more
%                                 than a threshold amount. Applicable to
%                                 temperature and density profiles only.
%
%                   'gradient':   first depth, measured from reference
%                                 depth down, where profile gradient
%                                 exceeds an indicated threshold amount.
%                                 If the gradient never exceeds the
%                                 threshold, the depth of highest absolute
%                                 gradient is used. For salinity profiles,
%                                 simply looks for maximum gradient.
%
%                   'fit':        a line is fit to the top, vertical-ish
%                                 part of the profile and to the
%                                 highest-gradient, horizontal-ish part of
%                                 the profile.  The mixed layer depth is
%                                 set to the pressure where these lines
%                                 intersect, or 0 if they don't intersect.      
%
%                   'extrema':    pressure of the extreme values.  For
%                                 temperature, the maximum value is found,
%                                 and for salinity and  density, the
%                                 minimum.   
%
%                   'subsurface': This method attempts to find subsurface
%                                 anomalies at the base of the mixed layer
%                                 that are the result of surface cooling
%                                 and mixing events.  The profiles are
%                                 characterized by a temperature gradient
%                                 maximum in close proximity to the
%                                 temperature maximum (or minima, for
%                                 salinity).  If found, the mld value
%                                 reflects the shallower of the two values;
%                                 if not found, it is set to 0. Applicable
%                                 to temperature and salinity profiles
%                                 only.
%           
%                   'hybrid':     All applicable potential MLD values are
%                                 calculated, and the Holte & Talley 2009
%                                 algorithm is used to choose which is the
%                                 best estimate for a given profile.   
%                   ['best']
%
%   refpres:        reference pressure (db).  Calculations are based on
%                   this point of the profile downward; points above are
%                   ignored, with the intent to eliminate any diurnal
%                   heating artifacts at the surface.
%                   [10]
%
%   tthresh:        threshold value used for temperature threshold
%                   calculation (deg C).
%                   [0.2]
%
%   tgradthresh:    threshold value used for temperature gradient
%                   calculation (deg C m^-1) 
%                   [0.005]
%
%   dthresh:        threshold value used for density threshold calculation
%                   (kg m^-3)
%                   [0.03]
%
%   dgradthresh:    threshold value used for density gradient calculation
%                   (kg m^-4)
%                   [0.0005]
%
%   errortol:       error tolerance used to choose which points to include
%                   in the surface-verticalish-line in the fit algorithm.
%                   Cutoff is set to the deepest point where the normalized
%                   sum squared error of the fit is less than this
%                   tolerance.
%                   [1e-10]
%
%   range:          range parameter used to identify clusters of MLD values
%                   during the hybrid algorithm, i.e. r in Holte &
%                   Talley, 2009, section 3b. (db)
%                   [25]
%
%   deltad:         maximum distance allowed between maximim[minimum]
%                   value and gradient in temperature[salinity] subsurface
%                   calculation. (db)
%                   [100]
%
%   tcutoffu:       upper value of temperature change cutoff when
%                   classifying a temperature profile as winter-like during
%                   the hybrid algorithm. (deg C)
%                   [0.5]
%
%   tcutoffl:       lower value of temperature change cutoff when
%                   classifying a temperature profile as winter-like during
%                   the hybrid algorithm. (deg C)
%                   [-0.25]
%
%   dcutoff:        potential density change cutoff above which a profile
%                   is classified as winter-like during the hybrid
%                   algorithm. (kg m^-3)
%                   [-0.06]
%
%   plot:           logical scalar, true to create a figure with the
%                   profiles and mixed layer depth points.
%                   [false]
%
%   tblformat:      format for mldtbl output, either 'array' or 'table'.
%                   The table format is more self-describing, since the
%                   columns and rows are clearly labeled, but the creation
%                   of a table array can add significant time to the
%                   function execution; array output is recommended if
%                   calling this function many times. (Note that if this
%                   function is called with only one output, this becomes
%                   irrelevant).
%                   ['table']
%
% Output arguments:
%
%   pmld:           1 x 3 vector of mixed layer depth pressures.  Elements
%                   correspond to temperature-, salinity-, and
%                   potential-densitiy-based estimates; if only temperature
%                   is passed as an input, a scalar value is returned.
%
%   mldtbl:         3 x 5 array or table (see tblformat input) holding all
%                   calculated mixed layer depth pressure candidates that
%                   were calculated. Rows corresponds to temperature,
%                   salinity, and potential density, and columns to the 5
%                   MLD metrics excluding "best" (see above) 
%
%   pth:            1 x 3 vector, indicating which algorithm pathway was
%                   used for the best-MLD estimate.  Only applicable if
%                   "best" metric is used, and primarily for debugging
%                   purposes.
%
%   h:              structure of graphics handle arrays, only applicable if
%                   plot = true

% Copyright 2019 Kelly Kearney


%-----------------------
% Setup
%-----------------------

% Parse and check basic properties of input

p = inputParser;
p.addRequired('pres', @(x) validateattributes(x, {'numeric'}, {'vector', 'increasing'}));
p.addRequired('temp');
p.addOptional('sal', []);

p.addParameter('metric',      'hybrid', @(x) validateattributes(x, {'string', 'char'}, {'scalartext'}));
p.addParameter('tthresh',     0.2);
p.addParameter('tgradthresh', 0.005);
p.addParameter('dthresh',     0.03);
p.addParameter('dgradthresh', 0.0005);
p.addParameter('errortol',    1e-10);
p.addParameter('range',       25);
p.addParameter('deltad',      100);
p.addParameter('tcutoffu',    0.5);
p.addParameter('tcutoffl',   -0.25);
p.addParameter('dcutoff',    -0.06);
p.addParameter('plot',        false);
p.addParameter('refpres',     10); % reference pressure
p.addParameter('tblformat',   'table', @(x) validateattributes(x, {'string', 'char'}, {'scalartext'}));

% p.addParameter('variables', {'temp','salt','pdens'});
% p.addParameter('algorithm', {'threshold', 'gradient', 'extrema', 'subsurface', 'fit'});

p.parse(varargin{:});
Opt = p.Results;

% Check input vectors for pressure, temperature, and salinity

tonly = false;

pres = Opt.pres;
temp = Opt.temp;
sal  = Opt.sal;
if ~isequal(size(temp), size(pres))
    error('temp array must be same size as pressure array');
end
if isempty(Opt.sal)
    tonly = true;
    sal = nan(size(pres)); % just as a placeholder to keep code cleaner
else
    if ~isequal(size(sal), size(pres))
        error('salt array must be same size as pressure array');
    end
end

pres = pres(:); % some calculations assume column vectors
temp = temp(:);
sal = sal(:); 

% Remove any part of the profiles above the reference depth

m = length(pres); 
[~,starti] = min((pres - Opt.refpres).^2);

pres = pres(starti:m);
sal  = sal( starti:m);
temp = temp(starti:m);
m = length(pres);

if m <= 2
    error('Too few data points below reference pressure; check refpres input againt your profile pressures');
end

% Calculate the potential density anomaly, with a reference pressure of 0 

if ~tonly
    pden = gsw_rho(sal,temp,pres)-1000;
end

% Set up mld output array

vopt = {'temp','salt','pdens'};
aopt = {'threshold', 'gradient', 'fit', 'extrema', 'subsurface'};

mldval = nan(3, 5);

% Validate metric and tblformat strings

validatestring(Opt.metric,    [aopt 'hybrid'],      'mld', 'metric');
validatestring(Opt.tblformat, {'array', 'table'}, 'mld', 'tblformat');

% Flag to run algorithms

if strcmp(Opt.metric, 'hybrid')
    runalg = true(size(aopt));
else
    runalg = ismember(aopt, Opt.metric);
end

% Default plotting placeholders (used for alg. 5 only)

pmaxtgrad = NaN;
pminsgrad = NaN;

%-----------------------
% Temperature-based 
% algorithms
%-----------------------

% Threshhold-value

if runalg(1)
    mldval(1,1) = alg1_threshold(pres, temp, Opt.tthresh);
end

% Threshold-gradient

if runalg(2)
    mldval(1,2) = alg2_gradient(pres, temp, Opt.tgradthresh);
end
    
% Fit

if runalg(3)
    [mldval(1,3), tdiff, ptop(1,:), pslp(1,:)] = alg3_fit(pres, temp, Opt.errortol);
end
    
% Extrema

if runalg(4)
    mldval(1,4) = alg4_extrema(pres, temp, 'max');
end

% Subsurface (co-ocurring subsurface extreme value and max gradient

if runalg(5)
    [mldval(1,5), pmaxtgrad] = alg5_subsurface(pres, temp, 'max', Opt.deltad);
end

%-----------------------
% Salinity-based 
% algorithms
%-----------------------

if ~tonly
    
    % Gradient
    
    if runalg(2)
        mldval(2,2) = smoothedgradientmax(pres, sal, 'extreme');
    end
    
    % Fit
    
    if runalg(3)
        [mldval(2,3), ~, ptop(2,:), pslp(2,:)] = alg3_fit(pres, sal, Opt.errortol);
    end
    
    % Extrema
    
    if runalg(4)
        mldval(2,4) = alg4_extrema(pres, sal, 'min');
    end
    
    % Subsurface

    if runalg(5)
        [mldval(2,5), pminsgrad] = alg5_subsurface(pres, sal, 'min', Opt.deltad);
    end
end

%-----------------------
% Density-based 
% algorithms
%-----------------------

if ~tonly
     
    % Threshhold
    
    if runalg(1)
        mldval(3,1) = alg1_threshold(pres, pden, Opt.dthresh);
    end
        
    % Gradient
   
    if runalg(2)
        mldval(3,2) = alg2_gradient(pres, pden, Opt.dgradthresh);
    end
    
    % Fit

    if runalg(3)
        [mldval(3,3), ddiff, ptop(3,:), pslp(3,:)] = alg3_fit(pres, pden, Opt.errortol);
    end
    
    % Extrema
    
    if runalg(4)
        mldval(3,4) = alg4_extrema(pres, pden, 'min');
    end
end

%-----------------------
% Find the best estimate
%-----------------------

if all(runalg)
    % First, determine if the profiles resemble summer or winter profiles.
    % This is based on the gradient across the mixed layer transition point as
    % measured by the fit algorithm.

    twinter = tdiff > Opt.tcutoffl && tdiff < Opt.tcutoffu;

    if ~tonly
        dwinter = twinter;
        if ddiff > Opt.dcutoff
            if tdiff > Opt.tcutoffu
                dwinter = true;
            elseif tdiff < Opt.tcutoffl
                dwinter = false;
            end
        end
    end

    % Temperature MLD algorithm

    if ~twinter
        pmld(1) = mldval(1,3);
        pth(1) = 1;
        if tdiff<0 && pmld(1) > mldval(1,1)
            pmld(1) = mldval(1,1);
            pth(1) = 2;  
        end
        if pmld(1) > mldval(1,1)
            if mldval(1,4) < mldval(1,1) && mldval(1,4) > Opt.range 
                pmld(1) = mldval(1,4);
                pth(1) = 3;
            else
                pmld(1) = mldval(1,1);
                pth(1) = 4;
            end
        end       
    else
        if abs(mldval(1,3)-mldval(1,1)) < Opt.range && ...
           abs(mldval(1,5)-mldval(1,1)) > Opt.range && ...
           mldval(1,3)<mldval(1,5)
            pmld(1) = mldval(1,3);
            pth(1) = 5;
        else
            if mldval(1,5) > pres(1)+Opt.range
               pmld(1) = mldval(1,5);
               pth(1) = 6; 
                a = [abs(mldval(1,2)-mldval(1,3)) ...
                     abs(mldval(1,2)-mldval(1,1)) ...
                     abs(mldval(1,1)-mldval(1,3))];
                if sum(a<Opt.range)>1
                    pmld(1) = mldval(1,3);
                    pth(1) = 7;                
                end
                if pmld(1)>mldval(1,1)
                    pmld(1) = mldval(1,1);
                    pth(1) = 8;
                end
            else
                if mldval(1,3)-mldval(1,1) < Opt.range
                    pmld(1) = mldval(1,3);
                    pth(1) = 9;
                else
                    pmld(1) = mldval(1,2);
                    pth(1) = 10;
                    if pmld(1) > mldval(1,1)
                        pmld(1) = mldval(1,1);
                        pth(1) = 11;
                    end     
                end
            end
        end

        if pmld(1) == 0 && abs(pmld(1)-mldval(1,1))>Opt.range
            pmld(1) = mldval(1,4); 
            pth(1) = 12;
            if mldval(1,4) == pres(1)
                pmld(1) = mldval(1,1);
                pth(1) = 13;
            end
            if mldval(1,4)>mldval(1,1)
                pmld(1) = mldval(1,1);
                pth(1) = 14;
            end        
        end
    end


    if ~tonly

        % Salinity MLD algorithm

        if ~dwinter
            pmld(2) = mldval(2,3);  
            pth(2) = 1;
            if pmld(2) - mldval(3,1) > Opt.range
                pmld(2) = mldval(3,1);
                pth(2) = 2;
            end
            if mldval(2,3)-mldval(2,2) < 0 && mldval(3,1)-mldval(2,2) > 0
                pmld(2) = mldval(2,2);
                pth(2) = 3;
            end
            if mldval(2,3)-mldval(2,5) < Opt.range && mldval(2,5) > Opt.range
                pmld(2) = mldval(2,5);
                pth(2) = 4;
            end
            if abs(mldval(3,1)-mldval(2,5)) < Opt.range && mldval(2,5) > Opt.range
                pmld(2) = mldval(2,5);
                pth(2) = 5;
            end  
            if pmld(1)-mldval(3,1)<0 && abs(pmld(1)-mldval(3,1))<Opt.range
                pmld(2) = pmld(1);  
                pth(2) = 6;
                if abs(pmld(1)-mldval(2,3))<Opt.range && mldval(2,3)-mldval(3,1)<0
                    pmld(2) = mldval(2,3); 
                    pth(2) = 7;
                end
            end
            if abs(pmld(1)-mldval(3,1))<abs(pmld(2)-mldval(3,1))
                if pmld(1)>mldval(3,1)
                    pmld(2) = mldval(3,1);
                    pth(2) = 8;
                end
            end
        else
            if mldval(2,5) > Opt.range
                pmld(2) = mldval(2,5);
                pth(2) = 9;
                if pmld(2)>mldval(3,1)
                    pmld(2) = mldval(3,1);
                    pth(2) = 10;
                end
            else
                if mldval(2,2) < mldval(3,1)
                    pmld(2) = mldval(2,2);
                    pth(2) = 11;
                    if mldval(2,3)<pmld(2) 
                        pmld(2) = mldval(2,3);
                        pth(2) = 12;
                    end
                else
                    pmld(2) = mldval(3,1);  
                    pth(2) = 13;
                    if mldval(2,3)<pmld(2)
                        pmld(2) = mldval(2,3);
                        pth(2) = 14;
                    end
                    if pmld(2) == 1 %%%%%%%%%%%%%%%%%should this be 0?
                        pmld(2) = mldval(2,2);
                        pth(2) = 15;
                    end  
                    if mldval(2,2) > mldval(3,1)
                        pmld(2) = mldval(3,1);
                        pth(2) = 16;
                    end
                end
            end
        end

        % Density MLD algorithm

        if ~dwinter
            pmld(3) = mldval(3,3);    
            pth(3) = 1;
            if pmld(3) > mldval(3,1)
                pmld(3) = mldval(3,1);
                pth(3) = 2;
            end  

            aa = [abs(pmld(2)-pmld(1)) abs(mldval(3,3)-pmld(1)) abs(pmld(2)-mldval(3,3))];
            if sum(aa<Opt.range)>1
                pmld(3) = mldval(3,3);
                pth(3) = 3;                
            end
            if abs(pmld(2) - mldval(3,1)) < Opt.range && pmld(2)~=mldval(3,1)
                if mldval(3,1) < pmld(2)
                    pmld(3) = mldval(3,1);
                    pth(3) = 4;            
                else
                    pmld(3) = pmld(2);
                    pth(3) = 5;
                end
                if mldval(3,3) == mldval(3,1)
                    pmld(3) =  mldval(3,3);
                    pth(3) = 6;
                end
            end 
            if pmld(3)>mldval(3,2) && abs(mldval(3,2)-pmld(1))<abs(pmld(3)-pmld(1))
                pmld(3) = mldval(3,2);
                pth(3) = 7;
            end
        else
            pmld(3) = mldval(3,1);
            pth(3) = 8;
            if mldval(1,1)<pmld(3)
                pmld(3) = mldval(1,1);
                pth(3) = 9;
            end
            if mldval(3,3)<mldval(3,1) && mldval(3,3)>Opt.range
                pmld(3) =  mldval(3,3);
                pth(3) = 10;
            end
            if mldval(1,5) > Opt.range && mldval(1,5)<mldval(3,1)
                pmld(3) = mldval(1,5);
                pth(3) = 11;
                if abs(mldval(1,4)-mldval(3,3))<abs(mldval(1,5)-mldval(3,3))
                    pmld(3) = mldval(1,4);
                    pth(3) = 12;
                end          
                if abs(pmld(2) - mldval(3,1)) < Opt.range && pmld(2)<mldval(3,1)
                    pmld(3) = min(mldval(3,1),pmld(2));
                    pth(3) = 13;
                end 
            end
            if abs(pmld(1)-pmld(2)) < Opt.range
                if abs(min(pmld(1),pmld(2))-pmld(3)) > Opt.range
                    pmld(3) = min(pmld(1),pmld(2));
                    pth(3) = 14;
                end
            end
            if pmld(3)>mldval(3,2) && abs(mldval(3,2)-pmld(1))<abs(pmld(3)-pmld(1))
                pmld(3) = mldval(3,2);
                pth(3) = 15;
            end
            if mldval(3,3)==mldval(2,3) && abs(mldval(2,3)-mldval(3,1))<Opt.range
                pmld(3) = mldval(3,3);
                pth(3) = 16;
            end
            if pmld(1)==mldval(3,4) 
                pmld(3) = mldval(3,4);
                pth(3) = 17;
            end
        end
    end
else
    pmld = mldval(:,runalg);
    
    if nargout > 2
        pth = NaN;
    end
    
end

if tonly
    pmld = pmld(1);
end

%-----------------------
% Format output
%-----------------------

if nargout > 1 && strcmp(Opt.tblformat, 'table')
    mldtbl = array2table(mldval, 'rownames', vopt, 'variablenames', aopt);
else
    mldtbl = mldval;
end


%-----------------------
% Plot
%-----------------------

if Opt.plot
    h.fig = figure;
    
    % Create axes
    
    if tonly
        h.ax(1) = axes;
    else
        h.ax(1) = subplot(1,3,1);
        xlabel('Temperature');
        h.ax(2) = subplot(1,3,2);
        xlabel('Salinity');
        h.ax(3) = subplot(1,3,3);
        xlabel('Density');
    end
    arrayfun(@(ax) hold(ax, 'on'), h.ax);
    
    % Determine x-limits of each axis
    
    axlim(1,:) = paddedlim(temp);
    if ~tonly
        axlim(2,:) = paddedlim(sal);
        axlim(3,:) = paddedlim(pden);
    end
    
    % Points plotted for each:
    
    tspec = {...
        'T thresh'     's' rgb('green')           mldval(1,1)     
        'dT/dP thresh' '>',rgb('green')           mldval(1,2)
        'T max'        'o',rgb('light blue')      mldval(1,4)
        'dT/dP max'    's',rgb('light blue')      pmaxtgrad
        'dT/dP thresh' 'o',rgb('yellow')          mldval(1,2)
        'T fit'        'o',rgb('orange')          mldval(1,3)};
    if ~tonly
        sspec = {...
            'T thresh'     's',rgb('green')       mldval(1,1)    
            'D thresh'     's',rgb('red')         mldval(3,1)
            'dT/dP thresh' '>',rgb('green')       mldval(1,2)
            'dD/dP thresh' '>',rgb('red')         mldval(3,2)
            'S fit'        'o',rgb('orange')      mldval(2,3)
            'S min'        'o',rgb('light blue')  mldval(2,4)
            '|dS/dP| max'  'o',rgb('yellow')      mldval(2,2)
            'dS/dP min'    's',rgb('light blue')  pminsgrad};
        dspec = {...
            'T thresh'     's',rgb('green')       mldval(1,1)  
            'D thresh'     's',rgb('red')         mldval(3,1)
            'dT/dP thresh' '>',rgb('green')       mldval(1,2)
            'dD/dP thresh' '>',rgb('red')         mldval(3,2)
            'D fit'        'o',rgb('orange')      mldval(3,3)
            'D min'        'o',rgb('light blue')  mldval(3,4)
            'dD/dP thresh' 'o',rgb('yellow')      mldval(3,2)}; 
    end
    
    ypt{1} = cat(1, tspec{:,end});
    xpt{1} = interp1(pres, temp, ypt{1});
    if ~tonly
        ypt{2} = cat(1, sspec{:,end});
        xpt{2} = interp1(pres, sal, ypt{2});
        ypt{3} = cat(1, dspec{:,end});
        xpt{3} = interp1(pres, pden, ypt{3});
    end
    
    % Plot profiles
    
    plot(h.ax(1), temp, pres, '-k.');
    if ~tonly
        plot(h.ax(2), sal,  pres, '-k.');
        plot(h.ax(3), pden, pres, '-k.');
    end
    
    % Plot reference lines and points
    
    yref = linspace(min(pres), max(pres), 3);
    for ii = 1:3
        if ii == 1 || ~tonly
            
            % The best-MLD reference line
            
            xbest = linspace(axlim(ii,1), axlim(ii,2), 3);
            ybest = ones(1,3).*pmld(ii);
            h.lnbest(ii) = plot(h.ax(ii), xbest, ybest, 'k');

            % The fit algorithm best-fit lines
            
            if all(runalg)
                xtop = polyval(ptop(ii,:), yref);
                xslp = polyval(pslp(ii,:), yref);
            else
                xtop = nan(1,3);
                xslp = nan(1,3);
            end
            
            h.lntop(ii) = plot(h.ax(ii), xtop, yref, '--k');
            h.lnslp(ii) = plot(h.ax(ii), xslp, yref, '--k');
            
            % The MLD estimate points
            
            for ip = 1:length(xpt{ii})
                h.pt{ii}(ip) = plot(h.ax(ii), xpt{ii}(ip), ypt{ii}(ip));
            end
            
            % Axis limits
            
            set(h.ax(ii), 'xlim', axlim(ii,:));
            
        end
    end
        
    set(h.pt{1}, {'marker', 'markerfacecolor'}, tspec(:,2:3));
    if ~tonly
        set(h.pt{2}, {'marker', 'markerfacecolor'}, sspec(:,2:3));
        set(h.pt{3}, {'marker', 'markerfacecolor'}, dspec(:,2:3));
    end
       
    set(cat(2, h.pt{:}), 'markersize', 8, 'markeredgecolor', ones(1,3)*0.1, 'linestyle', 'none');
    set(findall(h.fig, 'marker', 'o'), 'markersize', 4);

    set(h.ax, 'ydir', 'reverse', 'ylim', [0 500], 'xaxisloc', 'top', 'box', 'off');
    
    legend(h.pt{1}, tspec(:,1), 'location', 'south');
    if ~tonly
        legend(h.pt{2}, sspec(:,1), 'location', 'south');
        legend(h.pt{3}, dspec(:,1), 'location', 'south');
    end
    
end


%********* SUBFUNCTIONS ***************************************************

% function x0 = smoothedgradientmax(x,y)
% 
% dydx = diff(y)./diff(x);
% yslope = (dydx(1:end-2) + dydx(2:end-1) + dydx(3:end))./3;
% idx = find(abs(yslope) == max(abs(yslope)), 1, 'last') + 1;
% x0 = x(idx);

function x0 = smoothedgradientmax(x,y,mnmx)

dydx = [(y(2)-y(1))./(x(2)-x(1)); ...
        (diff(y(2:end))./diff(x(2:end)) + diff(y(1:end-1))./diff(x(1:end-1)))./2; ...
        (y(end)-y(end-1))./(x(end)-x(end-1))];
yslope = dydx;
% yslope = movmean(dydx, 3, 'endpoints', 'shrink');
% dydx2 = diff(y)./diff(x);
% yslope2 = (dydx2(1:end-2) + dydx2(2:end-1) + dydx2(3:end))./3;
% figure;
% ax = plotyy(x,y, x, dydx); hold(ax(2),'on'); plot(ax(2),x,yslope,x(2:end-2),yslope2);
switch mnmx
    case 'max'
        idx = find(yslope == max(yslope), 1, 'last');
    case 'min'
        idx = find(yslope == min(yslope), 1, 'last');
    case 'extreme'
        idx = find(abs(yslope) == max(abs(yslope)), 1, 'last');
end
x0 = x(idx);


% For all the algorithms below, input is as follows
% x = pressure
% y = temp, salinity, or potential density

%------------------------------
% Algorithm 1: Threshold method
%------------------------------
% Find shallowest point where value is at least 'val' units more or less
% than the surface value.

function x0 = alg1_threshold(x, y, val)
idx = find(abs(y(1)-y) > val, 1);

if isempty(idx)
    x0 = max(x);
else
    y0a = y(1) - val;
    y0b = y(1) + val;
    m = diff(y(idx-1:idx))./diff(x(idx-1:idx));
    x0a = (y0a - y(idx))./m + x(idx);
    x0b = (y0b - y(idx))./m + x(idx);
    if x0a >= x(idx-1) && x0a <= x(idx)
        x0 = x0a;
    else
        x0 = x0b;
    end 
end

%------------------------------
% Algorthm 2: Gradient method
%------------------------------
% Find shallowest point where the gradient exceeds a threshold 'val'.  If
% never exceeded, return the steepest gradient point (returns depth
% corresponding to the bottom point of the chosen line segment).  

function x0 = alg2_gradient(x, y, val) % Unsmoothed version
dydx = diff(y)./diff(x);
if any(abs(dydx) > val)
    idx = find(abs(dydx) > val, 1) + 1;
    x0 = x(idx);
else
    [~,imax] = max(abs(dydx));
    x0 = x(imax+1);
end

%------------------------------
% Algorithm 3: fit method
%------------------------------
% Fit a line to the top, well-mixed part of the profile (vertical-ish), and
% to the transition part of the profile (horizontal-ish), and find the
% depth where these two lines intersect.

function [x0, ydiff, ptop, pslope] = alg3_fit(x, y, tol)

nx = length(x);

% Top fit: find sum squared error for each set of points

err = zeros(nx,1);
for ii = 2:nx
    p = polyfit(x(1:ii), y(1:ii), 1);
    lfit = polyval(p, x(1:ii));
    err(ii) = (y(1:ii) - lfit)' * (y(1:ii) - lfit);
end
err = err ./ sum(err); % normalize

% Choose deepest point that maintains an error under the tolerance

npt = find(err < tol, 1, 'last');
ptop = polyfit(x(1:npt), y(1:npt), 1);

% Find 3-pt-smoothed line with the greatest slope

dydx = diff(y)./diff(x);
yslope = (dydx(1:end-2) + dydx(2:end-1) + dydx(3:end))./3;

[~,imax] = max(abs(yslope));
pslope = polyfit(x(imax:imax+2), y(imax:imax+2), 1);

% Find intersection point

x0 = (ptop(2) - pslope(2))./(pslope(1) - ptop(1));

% plot(x,y, '-r.');
% refline(ptop); refline(pslope);
% gridxy(x0);

% Make sure intersection point is within profile pressure limits.  If not,
% or they don't intersect, set MLD to 0.

if ~(x0 >= x(1) && x0 <= x(end))
    x0 = 0;
end

% What is the difference in values across the transition zone?

imixed = find(x <= x0, 1, 'last');
if isempty(imixed)
    ydiff = 0;
elseif imixed < (nx - 2)
    ydiff = y(imixed) - y(imixed+2);
else
    ydiff = y(imax) - y(imax+2);
end

%------------------------------
% Algorithm 4: extrema method
%------------------------------
% Find the depth where temperature maxima or salinity and density minima
% are found.

function x0 = alg4_extrema(x, y, mnmx)

switch mnmx
    case 'min'
        idx = find(y == min(y), 1, 'last');
    case 'max'
        idx = find(y == max(y), 1, 'last');
end
x0 = x(idx);
    
%------------------------------
% Algorithm 5: co-ocurring value 
% and gradient extrema
%------------------------------
% Check if the steepest gradient is within a specified threshold distance
% of the extreme value.  If so, return the shallower of these two.

function [x0, xslp] = alg5_subsurface(x, y, mnmx, thresh)

% Extreme value

xval = alg4_extrema(x,y,mnmx);

% Max gradient

xslp = smoothedgradientmax(x,y,mnmx);

% Are they close?

if abs(xslp - xval) < thresh
    x0 = min(xslp, xval);
else
    x0 = 0;
end

%------------------------------
% Padded limits
%------------------------------

function xlim = paddedlim(x)

if min(x) == max(x)
    xlim = min(x) + [-1 1];
else
    xlim = [min(x) max(x)] + [-1 1].*0.1*(max(x)-min(x));
end




