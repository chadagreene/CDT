function [A, h] = ensemble2bnd(x,y,varargin)
%ENSEMBLE2BND Calculates (and plots) percentile bounds for ensemble data.
%
% ensemble2bnd(x,y)
% ensemble2bnd(x,y, p1, v1, ...)
% [A,h] = ensemble2bnd(...)
%
% This function calculates the upper and lower bounds associated with
% percentiles calculated across an ensemble of data points.  It also
% provides the ability to plot these percentiles via several common
% error/confidence bounds-style plot options.
%
% Input variables:
%
%   x:      vector of x values associated with data
%
%   y:      nx x ny x nens array, where nx corresponds to the number of
%           x-dimension points (i.e. length of x input), ny corresponds to
%           the number of different datasets, and nens is the number of
%           ensemble members in each dataset. (See 'dims' parameter to
%           permute these dimensions) 
%
% Optional input variables (passed as parameter/value pairs) [default]
%
%   dims:   character array or string holding the letters 'x', 'y', and
%           'e', specifying the order of dimensions in your y input array.
%           By default 'xye' is expected, but this provides an easy way to
%           switch that up (e.g. x = 1x10 vector, y = 10x100 vector
%           representing one dataset with 100 ensemble members, rather than
%           100 datasets with 1 ensemble member each, so 'dims' = 'xey').
%           ['xye']
%
%   center: value to use for center point, either 'mean' or 'median'
%           ['mean']
%
%   prc:    percentile values corresponding to each lower and upper bound.
%           Should come in symmetric pairs, e.g. [0 25 75 100] will
%           calculate the 0-100 bounds and 25-75 bounds.
%           [0 100]
%
%   plot:   type of plot to generate
%           'none':        no plot, only bounds arrays returned
%           'boundedline': plots lines with shaded error region using 
%                          boundeline
%           'errorbar':    plots points with errorbars
%           'bar':         plots bars with errorbars; datasets will be
%                          staggered around the x-coordinates as in an
%                          unstacked bar plot.
%           'boxplot':     plots boxplots.  Note that this option overrides
%                          the 'prc' and 'center' options; the returned
%                          bounds corresponds to the quantiles and
%                          whisker-ends, and center values will be medians.
%                          Datasets will be staggered around the
%                          x-coordinates in the same manner as an unstacked
%                          bar plot.  This option requires the Statistics
%                          Toolbox.
%           ['none']
%
%   alpha:  logical scalar, plot = boundedline only, true to use
%           transparency rather than opaque patches
%           [false]
%
%   tlim:   1 x 2 vector, values indicating saturation color limits for
%           plotted bounds.  By default, the center lines/bars/points are
%           drawn with the indicated color (saturation = 1), and colors of
%           bounds objects (patch, errorbars, etc) use lighter versions of
%           the color, getting lighter as bounds expand.
%           [0.1 0.5]
%
%   cmap:   ny x 3 colormap array, indicating colors to use for each
%           plotted dataset.
%
%   axis:   scalar axis handle, parent axis for new plots
%
%   whisker:scalar, plot = boxplot only, whisker length factor used to
%           calculate outliers for boxplot (see boxplot whisker
%           documentation for more details)  
%           [1.5]
%
% Output variables:
%
%   A:      structure with the following fields:
%           
%           cent:   nx x ny, center value of each dataset
%
%           bndlo:  nx x ny x nprc/2: lower bound (actual value) of each
%                   percentile range
%
%           bndhi:  nx x ny x nprc/2: upper bound (actual value) of each
%                   percentile range
%
%           errlo:  nx x ny x nprc/2: lower bound offset (i.e. distance
%                   from center value)
%
%           errhi:  nx x ny x nprc/2: upper bound offset (i.e. distance
%                   from center value)
%
%   h:      structure holding graphics handles related to each plotted
%           object.  Contents varies based on type of plot called.

% Copyright 2019 Kelly Kearney

%--------------------
% Parse input
%--------------------

p = inputParser;
p.addParameter('dims',   'xye',   @(x) validateattributes(x,{'char','string'},{'scalartext'}));
p.addParameter('center', 'mean',  @(x) validateattributes(x,{'char','string'},{'scalartext'}));
p.addParameter('prc',    [0 100], @(x) validateattributes(x, {'numeric'}, {'vector'}));
p.addParameter('plot', 'none', @(x) validateattributes(x,{'char','string'},{'scalartext'}));
p.addParameter('alpha', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.addParameter('cmap', get(0, 'defaultaxescolororder'), ...
    @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3, 'nonnegative', '<=', 1}));
p.addParameter('axis', NaN, @(x) validateattributes(x, {'numeric','matlab.graphics.axis.Axes'}, {'scalar'}));
p.addParameter('tlim', [0.1 0.5], @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2, '>=', 0, '<=' ,1}));
p.addParameter('whisker', 1.5, @(x) validateattributes(x, {'numeric'}, {'scalar'}));

p.parse(varargin{:});
Opt = p.Results;

validateattributes(x, {'numeric', 'datetime'}, {'vector'},'ensemble2bnd','x',1);
validateattributes(y, {'numeric'}, {'3d'},'ensemble2bnd','y',2);

validatestring(Opt.plot, {'none', 'boundedline', 'boxplot', 'bar', 'errorbar'}, 'ensemble2bnd','plot');
validatestring(Opt.center, {'mean','median'}, 'ensemble2bnd','center');

if ~strcmp(Opt.plot, 'none') && isnumeric(Opt.axis) && isnan(Opt.axis)
    Opt.axis = gca;
end

% Permute y matrix, if necessary

[tf,loc] = ismember('xye', Opt.dims);
if ~all(tf)
    error('dims string should be composed of letters x, y, and e');
end
y = permute(y, loc);

% Check dimensions

[nx, ny, nens] = size(y);
if nx ~= length(x)
    error('x dimension of y does not match length x; check size of y and ''dims'' input');
end
x = x(:);

% Adapt for boxplot

if strcmp(Opt.plot, 'boxplot')
    if isempty(ver('stats'))
        error('The boxplot options requires the Statistics Toolbox');
    end
    Opt.center = 'median';
end

%--------------------
% Calculate center 
% and bounds
%--------------------

switch Opt.center
    case 'mean'
        A.cent = nanmean(y, 3);
    case 'median'
        A.cent = nanmedian(y,3);
end

prc = sort(Opt.prc);
nprc = length(prc);
if mod(nprc,2)
    error('Must include even number of percentiles');
end

prclo = prc(1:(nprc/2));
prchi = prc(end:-1:(nprc/2)+1);

A.bndlo = prctile(y, prclo, 3);
A.bndhi = prctile(y, prchi, 3);

A.errlo = bsxfun(@minus, A.cent, A.bndlo);
A.errhi = bsxfun(@minus, A.bndhi, A.cent);

%--------------------
% Plots
%--------------------

if ~strcmp(Opt.plot, 'none')
    
    hold(Opt.axis, 'on');
    trans = linspace(Opt.tlim(1), Opt.tlim(2), nprc/2);


    switch Opt.plot
        
        case 'bar'
        
            h.bar = bar(Opt.axis, x, A.cent);
            drawnow;
            for ib = 1:length(h.bar)
                xb(:,ib) = h.bar(ib).XData + h.bar(ib).XOffset;
            end
            for ii = 1:(nprc/2)
                h.errbar(ii,:) = errorbar(Opt.axis, xb, A.cent, A.errlo(:,:,ii), A.errhi(:,:,ii), 'linestyle', 'none');
            end
            for iy = 1:ny
                col = interp1([0 1], [1 1 1;Opt.cmap(iy,:)], trans);
                set(h.errbar(:,iy), {'color'}, num2cell(col,2));
            end

        case 'boundedline'

            axes(Opt.axis);
            trans = linspace(Opt.tlim(1), Opt.tlim(2), nprc/2);
            for ii = 1:(nprc/2)

                b = cat(3, A.errlo(:,:,ii), A.errhi(:,:,ii));
                b = permute(b, [1 3 2]);

                if Opt.alpha
                    [h.ln(ii,:),h.patch(ii,:)] = boundedline(x, A.cent, b, 'transparency', trans(ii), 'cmap', Opt.cmap, 'alpha');
                else
                    [h.ln(ii,:),h.patch(ii,:)] = boundedline(x, A.cent, b, 'transparency', trans(ii), 'cmap', Opt.cmap);
                end
            end


        case 'errorbar'

            h.ln = plot(Opt.axis, x, A.cent, '.');

            xtmp = repmat(x(:), 1, size(A.cent,2));
            for ii = 1:(nprc/2)
                h.errbar(ii,:) = errorbar(Opt.axis, xtmp, A.cent, A.errlo(:,:,ii), A.errhi(:,:,ii), 'linestyle', 'none');
            end   
            for iy = 1:ny
                col = interp1([0 1], [1 1 1;Opt.cmap(iy,:)], trans);
                set(h.errbar(:,iy), {'color'}, num2cell(col,2));
            end

        case 'boxplot'

            axprops = get(Opt.axis, {'xticklabelmode', 'xtickmode'});
            hb = bar(Opt.axis, x, A.cent);
            drawnow;
            for ib = 1:length(hb)
                xb(:,ib) = hb(ib).XData + hb(ib).XOffset; % Unfortunately values don't update unless visible and rendered
            end
            
            xb = xb(:);
            ybox = reshape(y, [], nens)';
            [ix,iy,ie] = ndgrid(1:nx, 1:ny, 1:nens);
            cg = reshape(iy, [], nens);

            delete(hb);

            h.box = boxplot(ybox, 'positions', xb, ...
                          'colorgroup', cg(:,1), ...
                          'colors', Opt.cmap, ...
                          'outliersize', 5, ...
                          'symbol', '.', ...
                          'whisker', Opt.whisker);
            h.box = reshape(h.box, size(h.box,1), ny, nx);
            
            % Assuming axis wasn't manual before, undo boxplot's
            % unnecessary hardcoding of ticks and tick labels
            
            set(Opt.axis, 'xticklabelmode', 'auto');
            if all(ismember(axprops(1:2), 'auto'))
                set(Opt.axis, 'xticklabelmode', 'auto', 'xtickmode', 'auto');
            end
            
            % Calculate actual bounds used for quartile boxes and whiskers
            
            A.bndhi = nan(nx,ny,2);
            A.bndlo = nan(nx,ny,2);
            
            for iy = 1:ny
                for ix = 1:nx
                    A.bndhi(ix,iy,:) = get(h.box(1,iy,ix), 'ydata');
                    A.bndlo(ix,iy,:) = get(h.box(2,iy,ix), 'ydata');
                end
            end
            
            A.errlo = bsxfun(@minus, A.cent, A.bndlo);
            A.errhi = bsxfun(@minus, A.bndhi, A.cent);            

    end
end
    

