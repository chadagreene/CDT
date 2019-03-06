%% |nao| documentation 
% |nao| calculates the North Atlantic Oscillation index from sea-level
% pressures based on the definition proposed by <http://science.sciencemag.org/content/269/5224/676 Hurrell, 1995>. For all
% practical purposes the NAO index is equivalent to the Arctic Oscillation
% as well as the North Annular Mode. For more information see <http://www.atmos.colostate.edu/~davet/ao/introduction.html this introduction 
% to Annular Modes by David Thompson at NCAR>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax 
% 
%  idx = nao(slpA,slpB,t) 
% 
%% Description 
% 
% |idx = nao(slp40,slp65,t)| calculates the North Atlantic Oscillation index 
% from two time series of sea-level pressures at two stations (A and B) 
% and their corresponding times |t|. Here, Station A (either Azores or
% Lisbon or Gibraltar) is usually south of Station B (Iceland).
% 
%% Example
% Here, we'll recreate Figure 4 from Jones et al.'s classic 1997 paper, 
% Extension to the North Atlantic Oscillation using early instrumental pressure observations from Gibraltar and South-west Iceland
% (<https://rmets.onlinelibrary.wiley.com/doi/abs/10.1002/%28SICI%291097-0088%2819971115%2917%3A13%3C1433%3A%3AAID-JOC203%3E3.0.CO%3B2-P Jones et al., 1997>),
% which depicts the monthly NAO index. This dataset builds on Hurrell's
% 1995 paper and station data can be found <here
% https://crudata.uea.ac.uk/cru/data/nao/index.htm>. The dataset we utilize
% here goes from January, 1865 to December, 2017.

%% Load Data 
% We can load data containing zonal-mean SLP at 40S and 65S calculated
% from observations from 1957 January to 2018 December.

load nao_slp_data.mat

%% Plot pressure data
% The |nao_slp_data.mat| file contains monthly mean SLP data from 1865
% to 2018 for Gibraltar (A) and Iceland (B). See above to find where 
% you can obtain this dataset. 
% Here is the pressure data we'll use to calculate the NAO:

figure
plot(t,slpA); 
hold on
plot(t,slpB)
axis tight
legend('SLP at Gibraltar','SLP at SW Iceland') 

%% Calculate NAO index
% The |nao| function normalizes each time series relative to the full
% baseline dataset and differences the two pressure anomaly time series to
% yield the NAO index. We'll calculate NAO, then smooth it with a 12 month 
% moving average (see the note below on filtering): 

% Calculate NAO index: 
nao_idx = nao(slpA,slpB,t);

% Apply a moving-mean filter: 
nao_idx_f = movmean(nao_idx,12);

figure
plot(t,nao_idx_f,'k','linewidth',1)

ylim([-3 3])                                  % sets vertical limits
hline(0,'k-')                                 % draws horizontal line 
set(gca,'xaxislocation','top')                % to match Jones 1997

%% 
% Above, the built-in Matlab function |movmean| was used to calculate the
% 12 month moving mean, and a horizontal dashed line was drawn with
% <hline_documentation.html |hline|> to match Marshall's Figure 7. 

%% A note on filtering
% The caption to Figure 4 in Jones et al., 1997 indicates that a 12-month Gaussian
% filter was used to smooth the time series before plotting. A Gaussian filter
% is a type of moving-average filter, and it's weighted such that values near the
% edges of the moving window don't contribute much to the average. The weighting
% of a Gaussian filter window takes the shape of a Gaussian curve, in contrast
% to an ordinary moving-average filter whose weighting window is effectively a 
% rectangle wherein all values contribute equally to the average. 
% 
% Unfortunately, the Jones et al. description of a "12-month Gaussian filter" is 
% somewhat ambiguous, because it's unclear whether that means the total width of the
% Gaussian window, or the 1-sigma width, or twice the 1-sigma width, or something 
% else entirely. How exactly do you define the width of something that should trail
% that takes an infinite distance to gradually trail off to zero? Sometimes people 
% talk about Gaussian filters in terms of 2*pi*sigma, 
% because that's the distance at which the weighting factor is equal to exp(-0.5), 
% but it's unclear if that's what Jones et al. intended. 
% 
% We don't really have a clear answer on the exact width of the Gaussian window, 
% or its exact shape; however, in this particular case, the details of the 
% filter design probably do not matter very much. We used a plain moving-average
% above, and still got a plot that looks pretty much the same as Figure 4 of 
% Jones et al. That tells us that while it would be nice if we could replicate 
% the methods of Jones et al. exactly, their methods and explanations were enough
% to replicate their results generally. 
%
%% References
% 
% Hurrell, J.W., 1995: Decadal Trends in the North Atlantic Oscillation: 
% Regional Temperatures and Precipitation. _Science_ Vol. 269, pp.676-679
% <http://science.sciencemag.org/content/269/5224/676 doi:10.1126/science.269.5224.676>
% 
% Jones, P. D. et al., 1997: Extension to the North Atlantic oscillation 
% using early instrumental pressure observations from Gibraltar and 
% south-west Iceland. Int. _J. Climatol._, 17: 1433-1450.
% <https://doi.org/10.1002/(SICI)1097-0088(19971115)17:13%3C1433::AID-JOC203%3E3.0.CO;2-P>

%% Author Info
% The |nao| function and supporting documentation were written by <http://www.kaustubh.info Kaustubh Thirumalai> 
% for the Climate Data Toolbox for Matlab, 2019. 