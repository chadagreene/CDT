function h = labelbordersm(place,varargin)
% labelbordersm labels National or US state boundaries on maps generated with Matlab's 
% Mapping Toolbox. If you don't have Matlab's Mapping Toolbox, or you just prefer to plots lon and lat
% as x and y, use the borders function instead. 
% 
% Data from: Census Bureau 500k data and thematicmapping.org TM World Borders 0.3 dataset. 
% https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html
% http://thematicmapping.org/downloads/world_borders.php
% 
%% Syntax 
% 
%  labelbordersm(place)
%  labelbordersm(...,TextProperty,TextValue)
%  h = labelbordersm(...)
% 
%% Description 
% 
% labelbordersm(place) labels the borders of a place, which can be any country or US state.  place may also be 
% 'countries' to plot all national borders, 'states' to label all US state borders, or 'Continental US' to 
% plot only the continental United States (sorry Guam).  Note: to plot the nation of Georgia, use 'Georgia'.
% To plot the US state of Georgia, specify 'Georgia.' with a period. 
%
% labelbordersm(...,TextProperty,TextValue) specifies text formatting.
%
% h = labelbordersm(...) returns a handle h of plotted text object(s).  
% 
%% Examples 
% For examples, type 
% 
%  cdt labelbordersm
% 
%% Author Info
% The borders and labelbordersm functions were written by <http://www.chadagreene.com 
% Chad A. Greene> of the University of Texas at Austin's Institute for Geophysics (UTIG),
% April 2015. 
% 
% See also labelborders and bordersm. 

%% Set defaults 

plotWhat = 'singleplace'; 

%% Parse inputs: 

    
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

%% Load data

bd = load('borderdata.mat','places','clat','clon'); 

switch plotWhat
    case 'singleplace'
        ind = strlookup(bd.places,place); 

        if isempty(ind)
            return
        end
        lat = bd.clat{ind}; 
        lon = bd.clon{ind}; 
    
    case 'countries'
        lat = cell2mat(bd.clat(1:246)); 
        lon = cell2mat(bd.clon(1:246)); 
        place = bd.places(1:246); 
    
    case 'states'
        lat = cell2mat(bd.clat(247:302)); 
        lon = cell2mat(bd.clon(247:302));
        place = bd.places(247:302);          
        
    case 'continental us'
        lat = cell2mat(bd.clat([247:273 276 277 279:299 302])); 
        lon = cell2mat(bd.clon([247:273 276 277 279:299 302]));  
        place = bd.places([247:273 276 277 279:299 302]);       
end

%% Make map: 

if ~ismap(gca) 
   switch plotWhat
      case 'countries'
         worldmap('world'); 

      case 'states' 
         worldmap('United states of america') 

      case 'continental us'
         worldmap([23 53],[-129 -65])

      case 'singleplace'
         worldmap([lat-10 lat+10],[lon-15 lon+15])

   end
end
 
h = textm(lat,lon,place,'vert','middle','horiz','center',varargin{:});

%% Clean up: 

if nargout==0
    clear h
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
