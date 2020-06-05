function varargout = borders(place,varargin)
% borders plots National or US state boundaries without Matlab's Mapping Toolbox. 
%
% Data are compiled from 2013 US Census Bureau 500k data and thematicmapping.org 
% TM World Borders 0.3 dataset. 
% https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html
% http://thematicmapping.org/downloads/world_borders.php
% 
%% Syntax 
% 
%  borders
%  borders(place)
%  borders(...,LineProperty,LineValue)
%  borders(...,PatchProperty,PatchValue)
%  borders(...,'center',centerLon)
%  h = borders(...)
%  [lat,lon] = borders(place) 
% 
%% Description 
% 
% borders plots national borders. 
% 
% borders(place) plots the borders of a place, which can be any country or US state.  place may also be 
% 'countries' to plot all national borders, 'states' to plot all US state borders, or 'Continental US' to 
% plot only the continental United States (sorry Guam).  Note: to plot the nation of Georgia, use 'Georgia'.
% To plot the US state of Georgia, specify 'Georgia.' with a period. 
%
% borders(...,LineProperty,LineValue) specifies linestyle or markerstyle.
% 
% borders(...,PatchProperty,PatchValue) outlines states or nations as patch objects if any property begins
% with 'face', (e.g., 'facecolor','red'). Note that plotting all countries as patches can be a bit slow.  
%
% borders(...,'center',centerLon) specifies a central longitude. Default is 0. 
% 
% h = borders(...) returns a handle h of plotted object(s). 
%
% [lat,lon] = borders(place) does not plot any borders, but returns arrays of their geographic coordinates.    
% 
%% Examples
% For examples, type 
% 
%  cdt borders
% 
%% Author Info
% The borders and labelborders functions were written by <http://www.chadagreene.com 
% Chad A. Greene> of the University of Texas at Austin's Institute for Geophysics (UTIG).
% April 2015: borders function created and shared on File Exchange. 
% April 2015: updated to allow patch objects without the Mapping Toolbox.
% Oct 2018: Split into two functions: borders for nomappingtoobox, and bordersm for mapping toolox. 
% 
% See also plot, earthimage, and bordersm.

%% Initial error checks

nargoutchk(0,2) 

%% Set defaults 

plotborder = false; 
faceplot = false; 
plotWhat = 'singleplace'; 

%% Parse inputs: 

if nargout<2
    plotborder = true;    
    if any(strncmpi(varargin,'face',4))
        faceplot = true; 
    end
end

if ~exist('place','var')
    place = 'countries'; 
end

if strncmpi(place,'countries',5)
    plotWhat = 'countries';
end

if strncmpi(place,'states',5)
    plotWhat = 'states';
end

if strncmpi(place,'continental us',4)
    plotWhat = 'continental us';
end

if strncmpi(place,'latin america',4)
    plotWhat = 'latin america';
end

tmp = strncmpi(varargin,'center',4); 
if any(tmp)
   centerLon = varargin{find(tmp)+1}; 
   tmp(find(tmp)+1) = true; 
   varargin = varargin(~tmp); 
else
   centerLon = 0; 
end

%% Check license

% Unless the user has the mapping toolbox and the current axes are already map axes: 
if plotborder
   if license('test','map_toolbox')
      assert(ismap(gca)==0,'The current axes use Matlab''s Mapping Toolbox, so you will need to use the bordersm function instead of borders.') 
   end
   ax = axis; % make a note of the axis limits. 
end


%% Load outline data and select which data to include: 

bd = load('borderdata.mat'); 

switch plotWhat
    case 'singleplace'
        ind = strlookup(bd.places,place); 

        if isempty(ind)
            return
        end
        lat = bd.lat{ind}; 
        lon = bd.lon{ind}; 
    
    case 'countries'
        lat = bd.lat(1:246); 
        lon = bd.lon(1:246); 
    
    case 'states'
        lat = bd.lat(247:302); 
        lon = bd.lon(247:302);         
        
    case 'continental us'
        lat = bd.lat([247:273 276 277 279:282 284:285 287:299 302]); 
        lon = bd.lon([247:273 276 277 279:282 284:285 287:299 302]);  
        
    case 'latin america'
        lat = bd.lat([8 17 21 33 38 39 41 48 49 55 75 78 79 120 159 161 162 165 211 214]); 
        lon = bd.lon([8 17 21 33 38 39 41 48 49 55 75 78 79 120 159 161 162 165 211 214]); 
end

% Double everything if center lon isn't zero: 
if centerLon ~= 0
   if iscell(lon)
       lat = [lat;lat];
       lon = [lon;cellfun(@(x) x+360,lon,'un',0)]; 
   else
       lat = [lat lat];
       lon = [lon lon+360]; 
   end
end

%% 

if plotborder
    if strcmpi(plotWhat,'singleplace')
        
         if faceplot
             nanz = find(isnan(lat));
             nanz = [0,nanz];
             hold on

             for k = 1:length(nanz)-1
                 h(k) = patch(lon(nanz(k)+1:nanz(k+1)-1),lat(nanz(k)+1:nanz(k+1)-1),.5*[1 1 1],varargin{:}); 
             end
%                 h = patch(lon,lat,.5*[1 1 1],varargin{:}); % does not work well
         else
             h = plot(lon,lat,varargin{:}); 
         end
        
    else

         if faceplot

             for k = 1:length(lat)
                 latk = lat{k}; 
                 lonk = lon{k}; 

                 nanz = find(isnan(latk));
                 nanz = [0,nanz];
                 hold on

                 for kk = 1:length(nanz)-1
                     h(kk) = patch(lonk(nanz(kk)+1:nanz(kk+1)-1),latk(nanz(kk)+1:nanz(kk+1)-1),.5*[1 1 1],varargin{:}); 
                 end

             end
         else
             hold on
             h = plot(cell2nancat(lon),cell2nancat(lat),varargin{:}); 
         end
        
    end
end

if plotborder
   if ~isequal(ax,[0 1 0 1])
      axis(ax) 
   else
      if centerLon~=0
         axis([centerLon-180 centerLon+180 -90 90])
      end
   end
end

switch nargout 
    case 0 
         % do nothing
    case 1
        varargout{1} = h; 
    case 2
        varargout{1} = lat; 
        varargout{2} = lon; 
    otherwise
        error('Too many outputs.') 
end

end


function [ind,CloseNames] = strlookup(string,list,varargin)
% STRLOOKUP uses strcmp or strcmpi to return indices of a list of strings 
% matching an input string. If no matches are found, close matches are
% suggested.
% 
%% Syntax 
% 
% ind = strlookup('string',list)
% ind = strlookup(...,'CaseSensitive')
% ind = strlookup(...,'threshold',ThresholdValue)   
% [ind,CloseNames] = strlookup(...) 
% 
% 
%% Description 
% 
% ind = strlookup('string',list) returns indices ind corresponding to
% cell entries in list matching 'string'. 
% 
% ind = strlookup(...,'CaseSensitive') performs a case-sensitive
% strlookup. 
% 
% ind = strlookup(...,'threshold',ThresholdValue) declares a threshold
% value for close matches. You will rarely (if ever) need to use this.
% The ThresholdValue is a metric of how closely matches should be when
% offering suggestions. Low threshold values limit suggested matches to a
% shorter list whereas high thresholds expand the list size. By default,
% the threshold starts at 1.5, then increases or decreases depending on how
% many close matches are returned.  If fewer than 3 close matches are
% returned, the threshold is increased and it looks for more matches. If
% more than 10 close matches are found, the threshold is tightened
% (reduced) until fewer than 10 matches are found. 
% 
% [ind,CloseNames] = strlookup(...) suppresses command window output if
% no exact match is found, and instead returns an empty matrix ind and a
% cell array of close matches in names. If exact match(es) is/are found, 
% ind will be populated and CloseNames will be empty. 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% at Austin Institute for Geophysics (UTIG), August 2014. 
% 
% Updated January 2015 to include close alphabetical matches and fixed
% an input check based on FEX user Bryan's suggestion. Thanks Bryan. 
% 
% See also strcmp, strcmpi, strfind, regexp, strrep. 

%% Input checks: 

assert(isnumeric(string)==0&&isnumeric(list)==0,'Inputs must be strings.') 

% If user accidentally switches order string and list inputs, fix the order: 
if ischar(list) && iscell(string) 
    tmplist = list; 
    list = string; 
    string = tmplist; 
end

if strcmpi(string,'recursion')
    disp('Did you mean recursion?') 
    return
end

% Allow user to declare match threshold with a name-value pair: 
threshold = []; 
tmp = strncmpi(varargin,'thresh',6); 
if any(tmp)
    threshold = varargin{find(tmp)+1}; 
    assert(isscalar(threshold)==1,'Threshold value must be a scalar.')
    assert(threshold>=0,'Threshold value cannot be negative.')
end

%% Find matches:

% Find case-insensitive matches unless 'CaseSensitive' is requested by user:
if nargin>2 && any(strncmpi(varargin,'case',4))
    TF = strcmp(list,string); 
else
    TF = strcmpi(list,string); 
end


%% Look for close matches if no exact matches are found: 

CloseNames = []; 

if sum(TF)==0
    % Thanks to Cedric Wannaz for writing this bit of code. He came up with a
    % quite clever solution wherein the spectrum of an input string is compared to  
    % spectra of available options in the input list. 
    
    % Define spectrum function: 
    spec = @(name) accumarray(upper(name.')-31, ones(size(name)), [60 1]);
    
    % Get spectrum of input string:
    spec_str = spec(string); 
    
    % Compare spec_str to spectra of all strings available in the list:
    spec_dist = cellfun(@(name) norm(spec(name)-spec_str), list);
    
    % Sort by best matches: 
    [sds,idx] = sort(spec_dist) ;

    % Find list items that closely match input string by spectrum: 
    % If the user has not declared a hard threshold, start with a threshold
    % of 1.5 and then adjust threshold dynamically if there are too many or
    % too few matches:
    if isempty(threshold)
        threshold = 1.5; 
        closeSpectralInd = idx(sds<=threshold);
        
        % If there are more than 10 close matches, try a smaller threshold:
        while length(closeSpectralInd)>10
            threshold = 0.9*threshold;
            closeSpectralInd = idx(sds<=threshold); 
            if threshold<.05
                break
            end
        end
        
        % If there are fewer than 3 close matches, try relaxing the threshold: 
        while length(closeSpectralInd)<3
            threshold = 1.1*threshold;
            closeSpectralInd = idx(sds<=threshold); 
            if threshold>10
                break
            end
        end
        
    else
        % If user declared a hard threshold, stick with it:
        closeSpectralInd = idx(sds<=threshold);
    end
    
    % Check for matches alphabetically by seeing how many first-letter
    % matches there are. If there are more than 4 first-letter matches, 
    % see how many first-two-letter matches there are, and so on:
    for n = 1:length(string)
        closeAlphaInd = find(strncmpi(list,string,n));
        if length(closeAlphaInd)<5
            break
        end
    end
    
    
    % Names of close matches: 
    CloseNames = list(unique([closeSpectralInd;closeAlphaInd]));
    ind = []; 
    
    if isempty(CloseNames)
        disp(['String ''',string,''' not found and I can''t even find a close match. Make like Santa and check your list twice.'])
    else
        if nargout<2
            disp(['String ''',string,''' not found. Did you mean...'])
            disp(CloseNames); 
        end
        if nargout==0
            clear ind
        end
    end
    
else
    ind = find(TF); 
end

end


function B = cell2nancat(A) 
%cell2nancat concatenates elements of a cell into a NaN-separated vector. 
% 
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics (UTIG), January 2016. 
% http://www.chadagreene.com 
% 
% See also: cell2mat, nan, and cat. 

%% Input checks:

narginchk(1,1) 
assert(iscell(A),'Input error: Input must be a cell array.')

%% Perform mathematics and whatnot: 

% Append a NaN to each array inside A: 
Anan = cellfun(@(x) [x(:);NaN],A,'un',0);

% Columnate: 
B = cell2mat(Anan(:));

end
