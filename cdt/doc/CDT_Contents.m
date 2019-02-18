%% CDT Contents 
% 
% <<CDT_reduced.jpg>>
% 
% This page lists the contents of Climate Data Tools for Matlab. For help 
% getting started with CDT, see <CDT_Getting_Started.html CDT Getting Started>.
% 
%% Descriptive Statistics
% 
% * <scatstat1_documentation.html *|scatstat1|*> returns statistical values of all points within a given 
% 1D radius of each value. This is similar to taking a moving mean, but points do not have to be equally 
% spaced, nor do x values need to be monotonically increasing. 
% * <scatstat2_documentation.html *|scatstat2|*> returns statistical values of all points within a given 
% radius of each value. This is similar to taking a two-dimensional moving mean, but 
% points do not need to be equally spaced.
% * <wmean_documentation.html *|wmean|*> computes the weighted average or weighted mean value. 
% * <standardize_documentation.html *|standardize|*> removes the mean of a variable and scales it such that its
% standard deviation is 1.
% * <ensemble2bnd_documentation.html *|ensemble2bnd|*> calculates and plots percentile bounds for ensemble data.
% * <trend_documentation.html *|trend|*> calculates the linear trend of a data series by least squares. 
% * <detrend3_documentation.html *|detrend3|*> performs linear least squares detrending along the third dimension
% of a matrix.
% * <monthly_documentation.html *|monthly|*> calculates statistics of a variable for specified months of the year. 
% * <season_documentation.html *|season|*> estimates anomalies associated with the annual cycle or of a time series. 
% * <deseason_documentation.html *|deseason|*> removes the seasonal (aka annual) component of variability from a time series.
% * <climatology_documentation.html *|climatology|*> gives typical values of a variable as it varies throughout the year. 
% * <sinefit_documentation.html *|sinefit|*> fits a least-squares estimate of a sinusoid to time series data
% that have a periodicity of 1 year. 
% * <sineval_documentation.html *|sineval|*> produces a sinusoid of specified amplitude and phase with
% a frequency of 1/yr.
%
%% Matrix Manipulation
%
% * <cube2rect_documentation.html *|cube2rect|*> reshapes a 3D matrix for use with standard Matlab functions.
% * <rect2cube_documentation.html *|rect2cube|*> is the complement of |cube2rect|. It reshapes and permutes
% a 2D matrix into a 3D cube. 
% * <mask3_documentation.html *|mask3|*> applies a mask to all levels of 3D matrix corresponding to a 2D mask.
% * <expand3_documentation.html *|expand3|*> creates a 3D matrix from the product of a 2D grid and a 1D
% vector.
% * <local_documentation.html *|local|*> returns a 1D array of values calculated 
% from a region of interest in a 3D matrix. For example, if you have a big global 
% 3D sea surface temperature dataset, this function makes it easy to obtain a time 
% series of the average sst within a region of interest.
% * <near1_documentation.html *|near1|*> finds the linear index of the point in an array closest to a 
% specified coordinate. 
% * <near2_documentation.html *|near2|*> finds the subscript indices of the point in a grid closest to a 
% specified location. 
% * <cell2nancat_documentation.html *|cell2nancat|*> concatenates elements of a cell into a NaN-separated vector. 
% * <xyz2grid_documentation.html *|xyz2grid|*> converts regularly-spaced columnated x,y,z data into gridded data. 
% * <C2xyz_documentation.html *|C2xyz|*> converts a contour matrix (as returned by the |contour| function) into
% x, y, and corresponding z coordinates.
% * <xyzread_documentation.html *|xyzread|*> simply imports the x,y,z columns of a .xyz file. 

%% Georeferenced Grids
%
% * <recenter_documentation.html *|recenter|*> rewraps a gridded dataset to 
% be centered on a specified longitude.
% * <cdtgrid_documentation.html *|cdtgrid|*> uses |meshgrid| to easily create 
% a global grid of latitudes and longitudes.
% * <cdtdim_documentation.html *|cdtdim|*> gives the approximate dimensions 
% of each cell in a lat,lon grid assuming a spherical Earth of radius 6371000 meters.
% * <cdtarea_documentation.html *|cdtarea|*> gives the approximate area of each
% cell in a lat,lon grid assuming a spherical Earth of radius 6371000 meters.
% This function was designed to enable easy area-averaged weighting of large 
% gridded climate datasets.
% * <cdtgradient_documentation.html *|cdtgradient|*> calculates the spatial gradient of gridded data equally spaced in geographic
% coordinates. 
% * <cdtdivergence_documentation.html *|cdtdivergence|*> calculates the divergence of gridded vectors on the ellipsoidal
% Earth's surface. 
% * <cdtcurl_documentation.html *|cdtcurl|*> calculates the z component of curl for gridded vectors on an ellipsoidal Earth.
% * <geomask_documentation.html *|geomask|*> determines whether geographic 
% locations are within a given geographic region.
% * <island_documentation.html *|island|*> determines whether geographic 
% locations correspond to land or water.
% * <binind2latlon_documentation.html *|binind2latlon|*> converts binned index values of a sinusoidal grid to geocoordinates. 

%% Spatial Patterns
%
% * <filt2_documentation.html *|filt2|*> performs a highpass, lowpass, bandpass, or bandstop 2D gaussian filter on gridded data. 
% * <scatstat2_documentation.html *|scatstat2|*> returns statistical values of all points within a given 
% radius of each value. This is similar to taking a two-dimensional moving mean, but points do not need to be equally spaced.
% * <eof_documentation.html *|eof|*> gives eigenmode maps of variability and corresponding principal component
% time series for spatiotemporal data analysis.
% * <reof_documentation.html *|reof|*> reof reconstructs a time series of eof anomalies from specified EOF modes. 
% * <corr3_documentation.html *|corr3|*> computes linear or rank correlation for a time series and a 3D dataset. 
% * <xcorr3_documentation.html *|xcorr3|*> gives a map of correlation coefficients between grid cells of a 3D spatiotemporal dataset and a reference time series.
% * <xcov3_documentation.html *|xcov3|*> gives a map of covariance between grid cells of a 3D spatiotemporal dataset and a reference time series.

%% Time Series
%
% * <filt1_documentation.html *|filt1|*> applies a zero-phase butterworth filter to a time series.
% * <scatstat1_documentation.html *|scatstat1|*> returns statistical values of all points within a given 
% 1D radius of each value. This is similar to taking a moving mean, but points do not have to be equally 
% spaced, nor do x values need to be monotonically increasing. 
% * <doy_documentation.html *|doy|*> returns the day of year. 
%% Uncertainty Quantification
%
% * <mann_kendall_documentation.html *|mann_kendall|*> performs a standard simple Mann-Kendall test to 
% determine the presence of a significant trend.
% * <ts_normstrap_documentation.html *|ts_normstrap|*> performs a bootstrap uncertainty analysis on a
% time series given an uncertainty value at each step assuming a normal probability distribution.
% * <sinefit_bootstrap_documentation.html *|sinefit_bootstrap|*> performs a bootstrap
% analysis on the parameters estimated by <sinefit_documentation.html |sinefit|>. 

%% Climate Indices
%
% * <enso_documentation.html *|enso|*> computes the El Nino Southern Oscillation index. 
% * <sam_documentation.html *|sam|*> calculates the Southern Annular Mode index from sea-level
% pressures.
% * <nam_documentation.html *|nam|*> calculates the Northern Annular Mode.

%% Oceans & Atmospheres
%
% * <bottom_documentation.html *|bottom|*> finds the lowermost finite values of a 3D matrix such as to determine seafloor temperature from a 3D gridded dataset.
% * <windstress_documentation.html *|windstress|*> estimates wind stress on the ocean from wind speed.
% * <ekman_documentation.html *|ekman|*> estimates the classical <https://en.wikipedia.org/wiki/Ekman_transport Ekman 
% transport> and upwelling/downwelling from 10 m winds. 
% * <coriolisf_documentation.html *|coriolisf|*> returns the Coriolis frequency (also known as the Coriolis parameter or the Coriolis coefficient) for any given latitude(s).
% * <rossby_radius_documentation.html *|rossby_radius|*> gives the Rossby radius of deformation for a barotropic ocean. 
% * <mld_documentation.html *|mld|*> calculate mixed layer depth following Holte and Talley, 2009.
% * <binind2latlon_documentation.html *|binind2latlon|*> converts binned index values of a sinusoidal grid to geocoordinates. 
% * <transect_documentation.html *|transect|*>  produces a color-scaled transect diagram of oceanographic data 
% from CTD profiles collected at different locations and/or times. 
% * <transectc_documentation.html *|transectc|*> produces a contoured transect diagram of oceanographic data 
% from CTD profiles collected at different locations and/or times. 

%% Geophysical Attributes
%
% * <earth_radius_documentation.html *|earth_radius|*> gives the nominal or latitude-dependent radius of Earth. 
% * <air_pressure_documentation.html *|air_pressure|*> computes pressure from the baromometric forumula for a US Standard Atmosphere. 
% * <air_density_documentation.html *|air_density|*> computes density the baromometric forumula for a US Standard Atmosphere. 
% * <sun_angle_documentation.html *|sun_angle|*> gives the solar azimuth and elevation for any time at any location on Earth.
% * <daily_insolation_documentation.html *|daily_insolation|*> computes daily average insolation as a function of day and latitude at
% any point during the past 5 million years.
% * <topo_interp_documentation.html *|topo_interp|*> interpolates elevations at any geographic locations from ETOPO5.
% * <island_documentation.html *|island|*> determines whether geographic locations correspond to land or water.
% * <dist2coast_documentation.html *|dist2coast|*> determines the distance from any geolocation to the nearest coastline.

%% Graphics
%
% * <rgb_documentation.html *|rgb|*> provides RGB values of common and uncommon colors by name.
% * <cmocean_documentation.html *|cmocean|*> provides perceptually-uniform colormaps by
% <http://dx.doi.org/10.5670/oceanog.2016.66 Thyng et al., 2016>.
% * <newcolorbar_documentation.html *|newcolorbar|*> allows multiple colormaps and colorbars in the same axes. 
% * <cbarrow_documentation.html *|cbarrow|*> places triangle-shaped endmembers on colorbars to
% indicate that data values exist beyond the extents of the values shown in the colorbar.
% * <cbdate_documentation.html *|cbdate|*> formats colorbar ticks as dates strings. 
% * <hline_documentation.html *|hline|*> creates horizontal lines on a plot. 
% * <vline_documentation.html *|vline|*> creates vertical lines on a plot. 
% * <hfill_documentation.html *|hfill|*> creates horizontal filled regions on a plot.
% * <vfill_documentation.html *|vfill|*> creates vertical filled regions on a plot.
% * <ntitle_documentation.html *|ntitle|*> places a title within a plot instead of on top. 
% * <gif_documentation.html *|gif|*> easily creates .gif animations. 

%% Line Plots
%
% * <anomaly_documentation.html *|anomaly|*> plots line data with different 
% colors of shading filling the area between the curve and a reference value.
% This is a common way of displaying anomaly time series such as sea surface 
% temperatures or climate indices.
% * <boundedline_documentation.html *|boundedline|*> plots lines with shaded error/confidence bounds.
% * <subsubplot_documentation.html *|subsubplot|*> creates sub-axes in tiled positions.
% * <spiralplot_documentation.html *|spiralplot|*> plots an Ed Hawkins style 
% spiral plot of a time series.
% * <plotpsd_documentation.html *|plotpsd|*> plots a power spectral density of a time series using
% Matlab's inbuilt periodogram function. 
% * <polyplot_documentation.html *|polyplot|*> plots a polynomial fit to scattered x,y data.

%% Maps
%
% * <earthimage_documentation.html *|earthimage|*> plots an unprojected image base map of Earth. 
% * <imagescn_documentation.html *|imagescn|*> is faster than |pcolor|, plots _all_ the data you give 
% it (whereas |pcolor| deletes data near edges and |NaN| values), makes |NaN| values transparent
% (whereas |imagesc| assigns the same color as the lowest value in the color axis), and is slightly
% easier to use than |imagesc|. 
% * <borders_documentation.html *|borders|*> plots National or US state boundaries without Matlab's Mapping Toolbox. 
% * <bordersm_documentation.html *|bordersm|*> plots National or US state boundaries on maps generated with Matlab's Mapping Toolbox.  
% * <labelborders_documentation.html *|labelborders|*> labels borders of nations or US states.
% * <labelbordersm_documentation.html *|labelbordersm|*> labels National or US state boundaries on maps generated with Matlab's 
% Mapping Toolbox.
% * <stipple_documentation.html *|stipple|*> creates a hatch filling or stippling within a grid.
% * <stipplem_documentation.html *|stipplem|*> creates a hatch filling or stippling within a grid, for use on maps created
% with Matlab's Mapping Toolbox. 
% * <quiversc_documentation.html *|quiversc|*> scales a dense grid of quiver arrows to comfortably fit in axes
% before plotting them.
% * <patchsc_documentation.html *|patchsc|*> plots patch objects with face colors scaled by numeric values. 

%% Globes
%
% * <globeimage_documentation.html *|globeimage|*> creates a "Blue Marble" 3D globe image.
% * <globeplot_documentation.html *|globeplot|*> function plots georeferenced data on a globe.
% * <globepcolor_documentation.html *|globepcolor|*> georeferenced data on a globe where color is scaled
% by the data value.
% * <globesurf_documentation.html *|globesurf|*> plots georeferenced data on a globe where values in matrix Z
% are plotted as heights above the globe.
% * <globecontour_documentation.html *|globecontour|*> plots contour lines on a globe from gridded data. 
% * <globescatter_documentation.html *|globescatter|*> plots georeferenced data as color-scaled markers on a globe. 
% * <globeborders_documentation.html *|globeborders|*> plots political boundaries borders on a globe. 
% * <globequiver_documentation.html *|globequiver|*> plots georeferenced vectors with components (u,v) on a globe.
% * <globestipple_documentation.html *|globestipple|*> creates a hatch filling or stippling over a region of a globe.
% * <globegraticule_documentation.html *|globegraticule|*> plots a graticule globe. Optional inputs control the
% appearance and behavior of the graticule.
% * <globefill_documentation.html *|globefill|*> plots a filled globe.

%% NetCDF and HDF5
% Check out the <tutorial_netcdf.html NetCDF tutorial> for help getting started with 
% NetCDF data. 
% 
% * <ncstruct_documentation.html *|ncstruct|*> reads several variables from netcdf file(s).
% * <ncdateread_documentation.html *|ncdateread|*> reads datetimes from a netcdf time variable.
% * <ncdatelim_documentation.html *|ncdatelim|*> reads first and last date from a netcdf file.
% * <h5struct_documentation.html *|h5struct|*> loads HDF5 data into a Matlab stucture with the same
% hierarchy as the original file.

%% Tutorials 
% CDT includes a handful of tutorials that address some common issues
% that we run into when analyzing climate data in Matlab. 
% 
% * <tutorial_netcdf.html *NetCDF data*> describes how to load and analyze NetCDF data. 
% * <tutorial_dates_and_times.html *Dates and times*> describes various Matlab date formats, and how to use
% them with Earth science data. 
% * <tutorial_trends.html *Linear trends*> explains how to apply least-squares
% regression to climate time series. 
% * <tutorial_mapping.html *Mapmaking*> describes several different ways to make maps of climate data in Matlab. 

%% Sample Datasets
% CDT comes with several datasets which can be used to test scripts
% or create examples. They are as follows: 
% 
% * *|altimetry_example.h5|*: Surface elevations from NASA's Airborne Topographic Mapper, used as 
% an example dataset in the documentation for <h5struct_documentation.html |h5struct|. 
% * *|bluemarble.png|*: True-color image of Earth from <https://svs.gsfc.nasa.gov/2915 NASA>. This 
% image is plotted by <earthimage_documentation.html |earthimage|>. 
% * *|borderdata.mat|*: National and US state boundaries plotted by <borders_documentation.html |borders|>, 
% <bordersm_documentation.html |bordersm|>, <labelborders_documentation.html |labelborders|>, 
% <labelbordersm_documentation.html |labelbordersm|>, and <globeborders_documentation.html |globeborders|>. 
% * *|BROKE_cruise_odv.txt|*: contains ocean temperature, salinity, and oxygen from CTD casts taken off the coast of Antarctica.
% * *|Curie_Depth.xyz|*: Gridded Antarctic Curie Depth from <https://doi.org/10.1002/2017GL075609 Martos, 2017>.
% * *|distance2coast.mat|*: A global grid of distances to coastlines calculated using great circle distances on the |land_mask.mat| dataset. Called by <dist2coast_documentation.html |dist2coast|>.
% * *|ERA_interim_2017.nc|*: <https://apps.ecmwf.int/datasets/data/interim-full-mnth/levtype=sfc/ ECMWF> 
% Synoptic Monthly Means of temperature, wind, surface pressure, and precipitation. See the <tutorial_netcdf.html 
% NetCDF Tutorial> for a description of how to load and plot this dataset. 
% * *|example_ctd.mat|*: Example oceanographic profile data used in the <transect_documentation.html |transect|> documentation. 
% * *|global_sst.mat|*: An 0.75 degree global grid of sea surface temperatures. 
% * *|global_topography.mat|*: A 5-minute (1/12 degree) global grid of topography 
% from the <https://www.eea.europa.eu/data-and-maps/data/world-digital-elevation-model-etopo5 World digital elevation model (ETOPO5)> 
% called by <topo_interp_documentation.html |topo_interp|>. 
% * *|land_mask.mat|*: A 1/8 degree binary mask indicating areas of land or ocean. This
% dataset is called by the <island_documentation.html |island|> function. 
% * *|mlo_daily_C02.mat|*: Atmospheric Carbon Dioxide Dry Air Mole Fractions from quasi-continuous measurements at Mauna Loa, Hawaii. From <http://dx.doi.org/10.7289/V54X55RG NOAA>.
% * *|orbit91.txt|*: Earth's orbital parameters from <https://doi.org/10.1016/0277-3791(91)90033-Q Berger A. and Loutre M.F., 1991> used as an example for <daily_insolation_documentation.html |daily_insolation|>. 
% * *|orbital_parameter_data.mat|*: used by the <daily_insolation_documentation.html |daily_insolation|> function written
% by Ian Eisenman and Peter Huybers, Harvard University, August 2006. 
% * *|pacific_sst.mat|*: A 67 year time series of gridded monthly sea surface temperatures
% covering part of the Pacific Ocean. This dataset is analyzed as part of the <eof_documentation.html |eof|>
% function documentation. 
% * *|pacific_wind.mat|*: A 1/8 degree grid of sea surface temperatures and wind
% covering part of the Pacific Ocean. This dataset is analyzed as part of the <ekman_documentation.html |ekman|>
% function documentation. 
% * *|sam_slp_data.mat|* zonal mean surface pressure averaged from 12 stations by 
% <https://legacy.bas.ac.uk/met/gjma/sam.html G. Marshall>, used as example
% data in the documentation for the <sam_documentation.html |sam|> function. 
% * *|seaice_extent.mat|*: A 38 year daily time series of sea ice extent for the northern
% and southern hemispheres from the <http://www.nsidc.org NSIDC>. This dataset is plotted as part of the <spiralplot_documentation.html |spiralplot|>
% and function documentation. 
% * *|sodb_example.mat|*: A 3D grid of potential temperatures from the Southern Ocean Database. The dataset is described at the end of the <bottom_documentation.html |bottom|> documentation.
% * *|xkcd_rgb_data.mat|*: The names and RGB values of 950 colors as they appear on 
% computer screens. This data results from an <http://blog.xkcd.com/2010/05/03/color-survey-results
% impressively thorough survey> conducted by XKCD's Randall Munroe and is called
% by the CDT function <rgb_documentation.html |rgb|>.
% 
%% Author Info
% The Climate Data Toolbox for Matlab is a collaboration led by Chad A.
% Greene, Kaustubh Thirumalai, and Kelly A. Kearney. A mansucript describing CDT is currently in preparation, 
% so please check the internet for complete citation information. 
