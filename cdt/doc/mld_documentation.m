%% |mld| documentation
% The |mld| function calculates the mixed layer depth of a water column
% based on profiles of temperature, salinity, and/or potential density.
%
% The oceanic mixed layer refers to the well-mixed upper layer of the
% ocean that is turbulently mixed and characterized by constant temperature
% and salinity values.  While the concept of a mixed layer is relatively
% straightforward, a concensus quantitative definition for how to
% specifically define it is lacking. Numerous algorithms exist, ranging
% from simple threshold algorithms to complex shape-fitting tools, and
% there is a large body of literature debating the relative merits of each.  
%
% For this particular toolbox function, we chose to adapt the algorithms of
% <https://doi.org/10.1175/2009JTECHO543.1 Holte and Talley, 2009>.  This
% paper details a multi-algorithm approach to 
% calculating the mixed layer for oceanic Argo profiles.  Those algorithms
% encompass the most commonly-used metrics, and therefore 
% serves as a nice starting point for this function that also strives to offer multiple
% approaches to mixed layer depth.  The examples below detail some of the
% most common approaches to this calculation.  Always keep in mind that
% mixed layer depth calculation is not a one-size-fits-all calculation, and
% you may need to experiment with many different options to determine which
% one is most applicable to your data.
%
% Note that this function currently includes some quirks (for example,
% salinity profiles are treated differently than temperature and density
% profiles under certain algorithms) that are specific to the Holte &
% Talley paper and are tailored to open ocean, float-measured profiles.
% These may or may not be appropriate to all 
% datasets.  We preserve them here, along with default parameter choices,
% for consistency with the original Holte & Talley code on which this
% function is based.    
%
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
%
%  pmld = mld(pres, temp)
%  pmld = mld(pres, temp, salt)
%  pmld = mld(..., Name, Value, ...)
%  [pmld, mldtbl, pth, h] = mld(...)

%% Description
%
% |pmld = mld(pres, temp)| calculates pressure corresonding to the mixed
% layer depth of a water column defined by pressure vector |pres| (in db)
% and temperature vector |temp| (in deg C).  In the temperature-only
% calculations, the pressure values are used only as a vertical axis, and
% therefore depth values (in m) can be substituted. 
%
% |pmld = mld(pres, temp)| calculates the mixed layer depth pressure of a
% water column defined by pressure vector |pres| (in db), temperature
% vector |temp| (in deg C), and salinity vector |salt|.  Note that in this 
% instance pressure values will be used to calculate potential density, and
% therefore users should be cautious about substituting depth values (in m)
% in place of pressure.
%
% |pmld = mld(..., Name, Value, ...)| allows users to modify algorithm
% parameters via the Name-Value parameters listed in the next section.
%
% |[pmld, mldtbl, pth, h] = mld(...)| returns additional information about
% the internal algorithms used.  The |mldtbl| table holds all mixed layer
% depth pressure candidate values used if the "best" algorithm is
% specified.  The |pth| value returns the algorithm pathway used if the
% "best" algorithm is used; this is primarily for debugging purposes and
% was designed to match the analysis_t, analysis_s, and analysis_d
% variables in the original Holte&Talley 2009 supplementary online code
% (note that this code is not identical to that online supplement, but
% reproduces the same pathways in most instances).  Finally, if the plot
% input option is specified, graphics handles will be returned in the
% handle structure |h|.

%% Name-Value pair arguments
%
% *metric*
% |'threshold'|, |'gradient'|, |'fit'|, |'extrema'|, |'subsurface'|, |'best'| (default)
% 
% This function allows for 6 different methods of defining the
% mixed layer depth:
%
% * |threshold|: The mixed layer depth is the first depth, measured from the
% reference depth downward, where profile value differs from the reference
% depth value by more than a threshold amount. Applicable to temperature
% and density profiles only.  
% * |gradient|: first depth, measured from reference depth downward, where
% profile gradient exceeds an indicated threshold amount. If the gradient
% never exceeds the threshold, the depth of highest absolute gradient is
% used. For salinity profiles, simply looks for maximum gradient.   
% * |fit|: A line is fit to the top, vertical-ish part of the profile and to
% the highest-gradient, horizontal-ish part of the profile.  The mixed
% layer depth is set to the pressure where these lines intersect, or 0 if
% they don't intersect.
% * |extrema|: pressure of the extreme values.  For temperature, the maximum
% value is found, and for salinity and  density, the minimum. Note that
% while these values may be applicable to most oceanic profiles, there are
% circumstances (for example, temperature inversions in salinity-dominated
% under-ice environments) where this simple metric will definitely fail.
% * |subsurface|: This method attempts to find subsurface anomalies at the
% base of the mixed layer that are the result of surface cooling and mixing
% events.  The profiles are characterized by a temperature gradient maximum
% in close proximity to the temperature maximum (or minima, for salinity).
% If found, the mld value reflects the shallower of the two values; if not
% found, it is set to 0. Applicable to temperature and salinity profiles
% only.
% * |'best'|: All applicable potential mld values are calculated from the
% above options, and the Holte & Talley 2009 algorithm is used to choose
% which is the best estimate for a given profile. 
%
% *refpres* 
% numeric scalar, default = 10
% 
% reference pressure (db).  Calculations are based on this point of the
% profile downward; points above are ignored, with the intent to eliminate
% any diurnal heating artifacts at the surface.
%
% *tthresh*
% numeric scalar, default = 0.2
%
% threshold value used for temperature threshold calculation (deg C)
%
% *tgradthresh*
% numeric scalar, default = 0.005
%
% threshold value used for temperature gradient calculation (deg C m^-1) 
%
% *dthresh*
% numeric scalar, default = 0.03
%
% threshold value used for density threshold calculation (kg m^-3)
%  
% *dgradthresh*
% numeric scalar, default = 0.0005
%
% threshold value used for density gradient calculation (kg m^-4)
%  
% *errortol*
% numeric scalar, default = 1e-10
%
% error tolerance used to choose which points to include in the
% surface-verticalish-line in the fit algorithm. Cutoff is set to the
% deepest point where the normalized sum squared error of the fit is less
% than this tolerance.  
%
% *range*
% numeric scalar, default = 25
%
% range parameter used to identify clusters of mld values during the
% choose-the-best algorithm, i.e. r in Holte & Talley, 2009, section 3b.
% (db)  
%  
% *deltad*
% numeric scalar, default = 100
% 
% maximum distance allowed between maximim[minimum] value and gradient in
% temperature[salinity] subsurface calculation. (db) 
%  
% *tcutoffu*
% numeric scalar, default = 0.5
%
% upper value of temperature change cutoff when classifying a temperature
% profile as winter-like during the choose-the-best algorithm. (deg C) 
%  
% *tcutoffl*
% numeric scalar, default = -0.25
%
% lower value of temperature change cutoff when classifying a temperature
% profile as winter-like during the choose-the-best algorithm. (deg C) 
%  
% *dcutoff*       
% numeric scalar, default = -0.06
%
% potential density change cutoff above which a profile is classified as
% winter-like during the choose-the-best algorithm. (kg m^-3) 
%
%  
% *plot*
% logical scalar, default = False
%
% true to create a figure with the profiles, mixed layer depth points, and
% some reference detail.
%  
% *tblformat*
% |'table'| (default), |'array'|
%
% The |mldtbl| output consists of a 3 x 5 array, with rows corresponding to
% the 5 algorithms (excluding best), and columns corresponding to
% temperature, salinity, and density, respectively.  The default table
% format is more self-describing, since the columns and rows are clearly
% labeled, but the creation of a table array can add significant time to
% the function execution; array output is recommended if calling this
% function many times. (Note that if this function is called with only one
% output, this becomes irrelevant).

%% Example 1: The threshold approach
%
% The threshold definition is by far the most commonly-used mixed layer depth
% metric, and underlies several global mixed layer depth products, such as
% ﻿Monterey and Levitus (1997) and de Boyer Montegut et al. (2004).
%
% To replicate this type of calculation, we start with example data from an
% Argo float. We visualize this data using the <transect_documentation.html |transect|> function to
% turn the 34 profiles into a transect plot and set colormaps with
% <cmocean_documentation.html |cmocean|>. 

A = load('example_argo.mat');
nprof = length(A.date);
ax(1) = subplot(3,1,1);
transect(A.date, A.PRES, A.TEMP,'markersize',2);
hold on;
cb(1) = colorbar('eastoutside');
ylabel(cb(1), 'Temperature');
datetick;
cmocean('thermal');

ax(2) = subplot(3,1,2);
transect(A.date, A.PRES, A.PSAL,'markersize',2);
hold on;
cb(2) = colorbar('eastoutside');
ylabel(cb(2), 'Salinity');
datetick;
cmocean('haline');

ax(3) = subplot(3,1,3);
transect(A.date, A.PRES, A.pden,'markersize',2);
hold on;
cb(3) = colorbar('eastoutside');
ylabel(cb(3), 'Density');
datetick;
cmocean('dense');

set(ax, 'YLim', [0 500]);
set(ax(3), 'clim', [25 30]);

%%
% ﻿Monterey and Levitus (1997) use a temperature threshold of 0.5 deg C
% and a density threshold of 0.125 kg/m^3.  This is a typical default choice
% for MLD calculations.

pmld = zeros(nprof,3);
for ix = 1:nprof
    pmld(ix,:) = mld(A.PRES{ix}, A.TEMP{ix}, A.PSAL{ix}, 'metric', 'threshold', ...
        'tthresh', 0.05, 'dthresh', 0.125);
end

plot(ax(1), A.date, pmld(:,1), 'b');
plot(ax(3), A.date, pmld(:,3), 'r');

%%
% de Boyer Montegut et al. (2004) argue that the ﻿Monterey and Levitus
% (1997) thresholds work for gridded and averaged profiles, but are less
% suitable to direct profile measurements.  They instead use temperature
% and density thresholds of 0.2 deg C and 0.03 kg/m^3, respectively.  Let's
% see how this compares to the previous estimates for this set of profiles:

pmld = zeros(nprof,3);
for ix = 1:nprof
    pmld(ix,:) = mld(A.PRES{ix}, A.TEMP{ix}, A.PSAL{ix}, 'metric', 'threshold', ...
        'tthresh', 0.02, 'dthresh', 0.03);
end

plot(ax(1), A.date, pmld(:,1), '--b');
plot(ax(3), A.date, pmld(:,3), '--r');

%% Example 2: The fit approach
%
% Holte & Talley, 2009's fit approach is often a bit more robust at
% identifying deep winter mixed layer depths, and can be applied to
% all three profile types.  This function works by fitting two lines to the
% profile, one near-vertical one representing the mixed part of the
% profile, and a diagonal one representing the transition part at the
% bottom of the mixed layer.  Note that this is the most time-consuming
% option of the five metrics.

pmld = zeros(nprof,3);
for ix = 1:nprof
    pmld(ix,:) = mld(A.PRES{ix}, A.TEMP{ix}, A.PSAL{ix}, 'metric', 'fit');
end

plot(ax(1), A.date, pmld(:,1), ':b');
plot(ax(2), A.date, pmld(:,2), ':r');
plot(ax(3), A.date, pmld(:,3), ':r');


%% Example 3: Alternate methods
%
% The remaining methods of MLD calculation presented in this function are
% less common, and have for the most part been developed to deal with
% situations where a simple threshold calculation fails to identify the
% desired MLD value.  We refer you to the full Holte & Talley, 2009 paper
% for a detailed description of these algorithms, and the motivation behind
% their development.
%
% The automatic plotting included with this function provides a quick
% summary of the possibilities. In this figure, T = temperature, S =
% salinity, D = density (sigma-theta), and P = pressure.  The dashed lines
% correspond to the fit-method best-fit lines, and the solid line is the
% final "best" MLD. All those individual candidate MLD values can be found
% in the |mldtbl| output:

[pmld, mldtbl, pth, h] = mld(A.PRES{22}, A.TEMP{22}, A.PSAL{22}, 'plot', true);

%%


mldtbl

%%
% The most appropriate algorithm varies based on the properties of a given
% water mass.  Keep in mind that the "best" method was specifically
% designed for Argo float profiles (and predominately tested on Southern
% Ocean profiles); we provide it as the default simply due to the history
% of this function (designed to mimic the Holte & Talley, 2009
% supplementary code but with more flexibility).


%% References
%
% de ﻿Boyer Montégut C, Madec G, Fischer AS, Lazar A, Iudicone D (2004)
% Mixed layer depth over the global ocean: An examination of profile data
% and a profile-based climatology. J Geophys Res C Ocean 109:1–20  
%
% Holte J, Talley L (2009) A new algorithm for finding mixed layer depths
% with applications to argo data and subantarctic mode water formation. J
% Atmos Ocean Technol 26:1920–1939 <https://doi.org/10.1175/2009JTECHO543.1
% doi:10.1175/2009JTECHO543.1>
%
% Monterey, G. and Levitus, S., 1997: Seasonal Variability of Mixed Layer
% Depth for the World Ocean. NOAA Atlas NESDIS 14, U.S. Gov. Printing
% Office, Wash., D.C., 96 pp.

%% Author Info
% This function and supporting documentation were written by
% <http://kellyakearney.net Kelly A. Kearney> for the Climate Data Toolbox for Matlab, 2019.
