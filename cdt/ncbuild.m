function ncbuild(file, var, varargin)
%NCBUILD Build a netCDF file around a Matlab variable
%
% This function simplifies the process of creating, extending, and writing
% to netCDF files from Matlab.  It supplies a wrapper around Matlab's
% lower-level netCDF writing utilities while allowing for reasonable
% defaults for things like dimensions, variable names, etc. It will be most
% useful when exporting a limited number of variables without too many
% complicating factors (data size reasonable, no partial hyperslab writes,
% no ambiguous dimension sizes, etc.)
%
% ncbuild(file, var)
% ncbuild(file, var, param1, val1, ...)
%
% Input variables:
%
%   file:       name of netCDF file, will be created if it doesn't already
%               exist
%
%   var:        variable data to be written to the file
%
% Optional input variables (passed as parameter/value pairs):
%
%   name:       character array or scalar string, name of variable.  If not
%               included, the name of the input variable (var) will be
%               used; if the variable input data does not have a variable
%               name, 'variableX' will be used, where X is the counter
%               number of variables in the file once variableX is added. 
%
%   dimnames:   string array or cell array of strings/char, dimension names
%               corresponding to the dimensions of the variable data.  If
%               not included, dimensions of unique length will be labeled
%               'i', 'j', 'k', etc.
%
%   format:     file format (see nccreate 'Format' option for details).
%               Default: 'classic'
%
%   fileatts:   cell array of name/value global file attribute pairs (see
%               attribstruct input description for details)
%
%   unlimited:  string array or cell array of strings/char matching the
%               names of dimensions that should be unlimited.  Note that
%               for classic files, and many netCDF conventions, only one
%               dimension can be unlimited.  Default: none
%
%   varatts:    cell array of name/value variable attribute pairs (see
%               attribstruct input description for details)
%
%   type:       variable type (see nccreate 'Datatype' input for details).
%               If not included, type will be inferred from the input
%               variable data.
%   
%
% Note: If you rely on this function to figure out dimensions information,
% rather than explicitly passing dimension names, then it makes certain
% assumptions:
% 1: All vectors should be column vectors (i.e. leading singleton
%    dimensions are dropped) 
% 2: If a variable dimension size matches the length of an existing
%    dimension, that one is assigned rather than adding a new dimension to
%    the file 
% 3: If there's any ambiguity, the function will error and request explicit
%    dimension name input.


%----------------------
% Parse and check input
%----------------------

p = inputParser;
p.addParameter('name', {}, @(x) validateattributes(x, {'char','string'}, {'scalartext'}));
p.addParameter('dimnames', {}, @(x) validateattributes(x, {'string','cell'},{}));
p.addParameter('format', 'classic', @(x) validateattributes(x, {'char','string'}, {'scalartext'}));
p.addParameter('fileatts', {});
p.addParameter('unlimited', {}, @(x) validateattributes(x, {'string','cell'},{}));
p.addParameter('varatts', {});
p.addParameter('type', '', @(x) validateattributes(x, {'char','string'}, {'scalartext'}));

p.parse(varargin{:});
Opt = p.Results;

if isempty(Opt.name)
    Opt.name = inputname(2);
    if isempty(Opt.name)
        if exist(file, 'file')
            ncid = netcdf.open(file,'NOWRITE');
            vids = netcdf.inqVarIDs(ncid);
            netcdf.close(ncid);
            Opt.name = sprintf('variable%d', length(vids)+1);
        else
            Opt.name = 'variable1';
        end
    end 
end

if isempty(Opt.type)
    Opt.type = class(var);
end

cellfun(@(x) validateattributes(x, {'char','string'}, {'scalartext'}), Opt.dimnames);
cellfun(@(x) validateattributes(x, {'char','string'}, {'scalartext'}), Opt.unlimited);

validateattributes(var, {'numeric','char','string'}, {}, 'ncbuild', 'var');

%----------------------
% Build (or add to) 
% file
%----------------------


if ~exist(file, 'file') % Build file from scratch
    
    % Initialize
    
    Nc = ncschema_init(Opt.format); 
    
    % File attributes
    
    if ~isempty(Opt.fileatts)
        Nc = ncschema_addatts(Nc, Opt.fileatts{:});
    end
    
    % Dimensions
    
    if isempty(Opt.dimnames)
        if isvector(var)
            var = var(:);
        end
        sz = size(var);
        sz = sz(1:find(sz>1, 1,'last')); % remove trailing singleton
        nd = length(sz);
        if nd > 18
            % Probably rare... defaults are more trouble than it's worth at
            % this point :-)
            error('For more than 18 dimensions, dimension names must be supplied');
        else
            Opt.dimnames = cellstr(char(105+(0:nd-1))');
        end
    end
    Opt.dimnames = reshape(Opt.dimnames, 1, []);

    if ~isempty(Opt.unlimited)
        validatestring(Opt.unlimited, Opt.dimnames);
    end

    sz = size(var);
    ndname = length(Opt.dimnames);
    if ndname > length(sz) % Assume user wants trailing singleton dimensions
        sz = [sz ones(1,ndname-length(sz))];
    elseif ndname < length(sz)
        if all(sz(ndname+1:end) == 1)
            sz = sz(1:ndname);
        else
            if isvector(var) && ndname == 1
                var = var(:);
                sz = numel(var);
            else
                error('Dimension name list does not match size of variable');
            end
        end
    end
        
    unlim = ismember(Opt.dimnames, Opt.unlimited);
    
    dinfo = [Opt.dimnames; num2cell(sz); num2cell(unlim)];
    Nc = ncschema_adddims(Nc, dinfo{:});
    
    % Variable
        
    Nc = ncschema_addvars(Nc, Opt.name, Opt.dimnames, Opt.varatts, Opt.type);

    % Create file
    
    ncwriteschema(file, Nc);
        
else
    
    % Add any new file attributes
    
    natt = length(Opt.fileatts);
    if mod(natt, 2)
        error('File attributes must be passed as name/value pairs');
    end
    Opt.fileatts = reshape(Opt.fileatts, 2, []);
    for iatt = 1:(natt/2)
        % TODO: append if existing?
        ncwriteatt(file, '/', Opt.fileatts{1,iatt}, Opt.fileatts{2,iatt});
    end
    
    % Figure out dimensions
    
    if isempty(Opt.dimnames)
        I  = ncinfo(file);
        dname = {I.Dimensions.Name};
        dlen = [I.Dimensions.Length];
        if isvector(var)
            var = var(:);
        end
        sz = size(var);
        sz = sz(1:find(sz>1, 1,'last')); % remove trailing singleton
        for ii = 1:length(sz)
            ismatch = sz(ii) == dlen;
            if nnz(ismatch) > 1
                error('Ambiguous dimension match; explicit dimension name list must be included for this variable');
            end
            if any(ismatch)
                Opt.dimnames{ii} = dname{ismatch};
            else
                Opt.dimnames{ii} = char(105+length(dlen));
            end
        end
        if length(unique(Opt.dimnames)) < length(Opt.dimnames) % Multiple matches to a single dimension
            error('Ambiguous dimension match; explicit dimension name list must be included for this variable');
        end
    end
    sz = size(var);
    ndname = length(Opt.dimnames);
    if ndname > length(sz) % Assume user wants trailing singleton dimensions
        sz = [sz ones(1,ndname-length(sz))];
    elseif ndname < length(sz)
        if all(sz(ndname+1:end) == 1)
            sz = sz(1:ndname);
        else
            if isvector(var) && ndname == 1
                var = var(:);
                sz = numel(var);
            else
                error('Dimension name list does not match size of variable');
            end
        end
    end
    sz(ismember(Opt.dimnames, Opt.unlimited)) = Inf;
    dinfo = [Opt.dimnames; num2cell(sz)];
    
    % Create variable
    
    nccreate(file, Opt.name, 'Dimensions', dinfo(:), 'Datatype', Opt.type);
    
    % Add variable attributes
    
    if ~isempty(Opt.varatts)
        natt = length(Opt.varatts);
        if mod(natt, 2)
            error('Variable attributes must be passed as name/value pairs');
        end
        Opt.varatts = reshape(Opt.varatts, 2, []);
        for iatt = 1:(natt/2)
            ncwriteatt(file, Opt.name, Opt.varatts{1,iatt}, Opt.varatts{2,iatt});
        end
    end    
end

% Add variable data to file

ncwrite(file, Opt.name, var);