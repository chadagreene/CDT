%% Dates and times 
% <CDT_Contents.html Back to Climate Data Tools Contents>
% 
% There are several different ways to work with dates and times in
% Matlab. This tutorial reviews the different date formats and discusses
% the relative strengths and weaknesses associated with each in the context
% of Earth science data. 

%% Intro and Overview 
% As an example, we'll consider the way time is packaged in <tutorial_netcdf.html NetCDF>
% format. Of course, the simplest way to load times from NetCDF files is to
% use the CDT function <ncdateread_documentation.html |ncdateread|>, but
% this tutorial concerns what's going on behind the scenes of |ncdateread|,
% so we'll start with the raw time format as it's packaged in the example
% .nc file. 
% 
% Begin by reading the time array: 

t = ncread('ERA_Interim_2017.nc','time')

%% 
% At this point, you may feel somewhat bewildered. What are all those
% numbers? Use |ncdisp| to get some insight: 

ncdisp('ERA_Interim_2017.nc','time')

%%  
% That tells us the units of |time| are 
% 
%  units = 'hours since 1900-01-01 00:00:00.0'
% 
% Sometimes the units might be days since 1971 or years since the Big Bang
% or seconds since I was born, so always be sure to check the units. 
% 
% Time in units of hours since the year 1900 is not very intuitive to 
% understand, so I recommend developing a habit of using either the <https://www.mathworks.com/help/matlab/ref/datenum.html
% |datenum|> or <https://www.mathworks.com/help/matlab/ref/datetime.html |datetime|> 
% format consistently. Matlab makes it pretty easy to switch between
% |datenum| and |datetime| formats, but they each have their strengths and 
% weaknesses. Here's a breakdown: 
% 
% * |datenum|: The units are simply the number of days since January 1 of the year 0 AD, 
% and this was the standard date format in Matlab for decades. 
% If you type |now| into your command window it will say something like |ans = 7.3740e+5|
% because it's been over 737,000 days since Jesus was born. Use 
% <https://www.mathworks.com/help/matlab/ref/datestr.html |datestr|>, 
% <https://www.mathworks.com/help/matlab/ref/datevec.html |datevec|>, or 
% |datetime| to convert |datenum| to calendar dates. 
% * |datetime|: This format was introduced in Matlab 2014b. Because |datetime| is an 
% object, it is able to be 'smart' in many ways because Matlab always knows it represents
% time (as opposed to |datenum| which is just a number to Matlab). But because 
% |datetime| is 'smart' it sometimes has unexpected behavior or incompatibilities, 
% in which case |datenum| might just be a better choice. 
% 
% For our example file, remember that |t| represents the number of hours since
% the strike of midnight on New Years Day, 1900. That's what all those
% numbers in |t| are. 
%% |datenum|
% To convert those hours to |datenum| format, use 1900,1,1 as the date and 
% put |t| in the hours place. 
% 
% Also, the |time| variable in the NetCDF file was in int32 format, which 
% |datenum| does not accept. So convert |t| to double when calling |datenum|: 

t = datenum(1900,1,1,double(t),0,0)

%% |datestr|
% Those are date numbers, and they don't make much sense to us humans. But 
% already we can see something interesting: The datenums are not integers - 
% they each end in |.5|, meaning the times correspond to noon on each day. 
% To understand what these datenums mean, simply put them into the |datestr| 
% function: 

datestr(t) 

%% 
% That tells us exactly what we expected: This monthly data corresponds to 
% noon on the first day of each month in 2017. 

%% |datevec|
% Another useful format is called |datevec|. Date vectors can be very helpful, especially when you want to analyze 
% only the data, say, associated with the month of September. Date vectors
% give you the year, month, and day (and hour, minute, and second, if you
% wish) associated with any given times |t|. Here's how to get date vectors
% from a datnum array: 

[year, month, day] = datevec(t); 

%% 
% With that, we now know the year, month, and day of each time |t|. Here
% they are, displayed all together: 

[year month day]

%% 
% The reason this is useful, is it's now very easy to get all the indices
% of dates corresponding to a given month. For example, here are all the
% indices corresponding to any September data: 

ind = month==9

%% |datetime|
% If you'd like to convert datenum to datetime format, simply put |t| into
% the |datetime| function, and tell it you want to convert from datenum: 

t = datetime(t,'ConvertFrom','datenum')

%% 
% Converting back to datenum is this easy: 

t = datenum(t) 

%% Author Info 
% This tutorial was written by Chad A. Greene for the Climate Data Toolbox 
% for Matlab, February 2019. 
