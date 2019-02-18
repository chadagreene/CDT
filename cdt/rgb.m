function RGB = rgb(ColorNames,varargin)
% RGB returns the RGB triple of the 949 most common names for colors,
% according to the results of the XKCD survey described here: 
% http://blog.xkcd.com/2010/05/03/color-survey-results/ 
% 
% To see a chart of color options, check out this internet website: 
% http://xkcd.com/color/rgb/
% 
%% Syntax
% 
%  RGB = rgb('Color Name') 
%  RGB = rgb('Color Name 1','Color Name 2',...,'Color Name N') 
%  RGB = rgb({'Color Name 1','Color Name 2',...,'Color Name N'}) 
% 
%% Description
% 
% RGB = rgb('Color Name') returns the rgb triple of the color described by the
% string 'Color Name'. Try any color name you can think of, it'll probably
% work. 
% 
% RGB = rgb('Color Name 1','Color Name 2',...,'Color Name N') returns an
% N by 3 matrix containing RGB triplets for each color name. 
% 
% RGB = rgb({'Color Name 1','Color Name 2',...,'Color Name N'}) accepts
% list of color names as a character array. 
% 
%% Examples: 
% For examples, type:  
% 
%   cdt rgb
% 
%% Author info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics.  I do not claim credit for the data
% from the color survey. http://www.chadagreene.com. 
% 
% See also ColorSpec and cmocean.

%% Make sure the function can find the data: 

if exist('xkcd_rgb_data.mat','file')~=2
    disp 'Cannot find xkcd_rgb_data.mat. I will try to install it from rgb.txt now.'
    rgb_install
    disp 'Installation complete.'
end
%% Check inputs: 


if iscellstr(ColorNames)==0 && iscellstr({ColorNames})==1
    ColorNames = {ColorNames}; 
end

if ~isempty(varargin)
    ColorNames = [{ColorNames} varargin];
end

assert(isnumeric(ColorNames)==0,'Input must be color name(s) as string(s).')


%% Search for color, return rgb value: 

% Load data created by rgb_install.m:
load xkcd_rgb_data.mat

% Number of input color names: 
numcolors = length(ColorNames);

% Preallocate a matrix to fill with RGB triplets: 
RGB = NaN(numcolors,3);

% Find rgb triplet for each input color string: 
for k = 1:numcolors
    ColorName = ColorNames{k}; 
    ColorName = strrep(ColorName,'gray','grey'); % because many users spell it 'gray'. 

    % If a color name is not found in the database, display error message
    % and look for near matches: 
    if sum(strcmpi(colorlist,ColorName))==0
        disp(['Color ''',ColorName,''' not found. Consider one of these options:'])
        
        % Special thanks to Cedric Wannaz for writing this bit of code. He came up with a
        % quite clever solution wherein the spectrum of the input color
        % name is compared to the spectra of available options.  So cool. 
        spec = @(name) accumarray(upper(name.')-31, ones(size(name)), [60 1]) ;
        spec_mycol = spec(ColorName); % spectrum of input color name 
        spec_dist = cellfun(@(name) norm(spec(name)-spec_mycol), colorlist);
        [sds,idx]   = sort(spec_dist) ;
        nearbyNames = colorlist(idx(sds<=1.5));
        if isempty(nearbyNames)
            nearbyNames = colorlist(idx(1:3));
        end
        disp(nearbyNames); 
        
        clear RGB
        return % gives up and makes the user try again. 
    end

    RGB(k,:) = rgblist(strcmpi(colorlist,ColorName),:);
end

end
