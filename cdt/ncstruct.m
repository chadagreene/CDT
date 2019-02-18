function Data = ncstruct(files, varargin)
%NCSTRUCT Read variables from a netcdf file or files
%
% Data = ncstruct(files, var1, var2, ...)
% Data = ncstruct(files, Scs, var1, var2, ...)
%
% This function reads multiple variables from a netCDF file or files into a
% structure array.  It also provides a useful wrapper to multiple ncread
% calls, as well as a shorthand to subset specific hyperslabs along
% dimensions.   
%
% Input variables:
%
%   file:   name of netcdf file(s). Can be either a character array
%           pointing to a single file path (local or OPENDAP), or a cell
%           array of character arrays pointing to multiple files that
%           include the same variables and dimensions and can be
%           concatenated along a shared unlimited record dimension.
%
%   var:    name of variable to read in, which must correspond exactly to a
%           variable in the file.  If no variable names are listed, all
%           variables are read.  Can also include the string 'dimensions'
%           to return variables whose name and size match one of the
%           dimensions of the file.
%
%   Scs:    1 x 1 structur; field names
%           should match names of dimension variables in the file, and each
%           field hold a 1 x 3 array of of [start count stride] values.  If 
%           provided, any variable with that dimension will be subset as
%           described.
%         
% Output variables:
%
%   Data:   1 x 1 structure, with fieldnames corresponding to requested
%           variables, each holding the data value for that variable

% Copyright 2015-2019 Kelly Kearney

% Parse input

if ischar(files)
    files = {files};
end
nfile = length(files);
cellfun(@checkncexists, files);

isscs = cellfun(@isstruct, varargin);
if any(isscs)
    Scs = varargin{isscs};
    varnames = varargin(~isscs);
else
    Scs = struct;
    varnames = varargin;
end

if nfile > 1
    [unlimdim, Info] = verifyfiles(files);
else
    Info = ncinfo(files{1});
end

if isempty(varnames)
    varnames = {Info.Variables.Name};
end

if ~iscellstr(varnames)
    error('Variables name inputs must be passed as strings or character arrays');
end

scsfld = fieldnames(Scs);

% Find the unlimited dimension

% if ismember(unlimdim, scsfld)
%     warning('Cannot subset along unlimited dimension %s', unlimdim);
%     Scs = rmfield(Scs, unlimdim);
%     scsfld = fieldnames(Scs);
% end

[tf,loc] = ismember(scsfld, {Info.Dimensions.Name});
if ~all(tf)
    str = sprintf('%s,', scsfld{~tf});
    error('Field in Scs input (%s) did not match file dimension names', str(1:end-1));
end

% Set up start-stride-count for all dimensions

nd = length(Info.Dimensions);

start = ones(1,nd);
count = ones(1,nd)*Inf;
stride = ones(1,nd);

if ~isempty(loc)
    scs = struct2cell(Scs);
    scs = cat(1, scs{:});
    start(loc)  = scs(:,1);
    count(loc)  = scs(:,2);
    stride(loc) = scs(:,3);
end

% If subsetting the unlimited dimension across multiple files, some
% additional logic is needed.

if nfile > 1
    [~,udim] = ismember(unlimdim, {Info.Dimensions.Name});
end
subsetunlim = nfile > 1 && ~isequal([1 Inf 1], [start(udim) count(udim) stride(udim)]);

if subsetunlim
    dlen = dimlength(files, unlimdim);
    dmax = sum(dlen);
    if isinf(count(udim))
        count(udim) = dmax;
    end
    flag = false(dmax,1);
    flag(start(udim):stride(udim):dmax) = true;
    n = cumsum(flag);
    flag(n > count(udim)) = false;
    flag = mat2cell(flag, dlen);
    
    readfile = cellfun(@any, flag);
    unlimscs = cell(nfile,1);
    
    unlimscs(readfile) = cellfun(@(x) [find(x,1) sum(x) stride(udim)], ...
        flag(readfile), 'uni', 0);
    
end

% If 'dimensions' is passed as variable name, look for variables that share
% name and size with a dimension

isdimshortcut = strcmp(varnames, 'dimensions');
if any(isdimshortcut)
    varnames = varnames(~isdimshortcut);
    if ~exist('Info', 'var')
        Info = ncinfo(file);
    end
    filevars = {Info.Variables.Name};
    if any(strcmp('dimensions', filevars))
        warning('''dimensions'' refers to a variable in this file; option disabled');
    else
        dims = {Info.Dimensions.Name};
        isvar = ismember(dims, filevars);
        dimvars = dims(isvar);
        varnames = [dimvars varnames];
        varnames = unique(varnames);
    end
end

% Locate and check variable names

nvar = length(varnames);

[vfound, vloc] = ismember(varnames, {Info.Variables.Name});
if ~all(vfound)
    str = sprintf('%s,', varnames{~vfound});
    error('Variable names (%s) not found in file', str(1:end-1));
end

% Read data

for iv = 1:nvar
    
    % Does an unlimited dimension need special handling for this variable?
    
    nodim = isempty(Info.Variables(vloc(iv)).Dimensions);
    hasdim = ~nodim && nfile > 1 && ismember(unlimdim, {Info.Variables(vloc(iv)).Dimensions.Name});
    
    if hasdim
        nfl = nfile;
    else
        nfl = 1;
    end
    
    % Read data from all files (or just one for non-unlimited-dim variables)
    
    for ifl = nfl:-1:1
        if isempty(Info.Variables(vloc(iv)).Dimensions)
            Data.(varnames{iv}){ifl} = ncread(files{ifl}, varnames{iv});
        else
            [~,dloc] = ismember({Info.Variables(vloc(iv)).Dimensions.Name}, {Info.Dimensions.Name});
            if subsetunlim && ismember(udim, dloc)
                if readfile(ifl)
                    start2 = start;
                    count2 = count;
                    start2(udim) = unlimscs{ifl}(1);
                    count2(udim) = unlimscs{ifl}(2);
                    Data.(varnames{iv}){ifl} = ncread(files{ifl}, varnames{iv}, start2(dloc), count2(dloc), stride(dloc));
                end
            else
                Data.(varnames{iv}){ifl} = ncread(files{ifl}, varnames{iv}, start(dloc), count(dloc), stride(dloc));
            end
        end
    end
    
    % Concatenate if necessary
    
    if hasdim
        [~,uloc] = ismember(unlimdim, {Info.Variables(vloc(iv)).Dimensions.Name});
        Data.(varnames{iv}) = cat(uloc, Data.(varnames{iv}){:});
    else
        Data.(varnames{iv}) = Data.(varnames{iv}){1};
    end
        
end

function checkncexists(file)
% exist will find local files, open/close will find OPeNDAP ones
if ~exist(file, 'file')
    try
        ncid = netcdf.open(file);
        netcdf.close(ncid);
    catch
        error('File %s does not exist locally and could not be reached to open; check filename for typos', file);
    end
end

function [unlimdim, I] = verifyfiles(files)
% If multiple files passed, make sure they have a single unlimited
% dimensions and otherwise matching variables and dimensions.  
% TODO: At some point I should probably check all the dimensions and make
% sure they're all the same size (except the unlimited one); right now I'm
% relying on concatenation to throw errors.

I = ncinfo(files{1});

isunlim = [I.Dimensions.Unlimited];

if ~any(isunlim)
    error('No unlimited dimension found in these files; files can only be read together if they have an unlimited dimension');
end
if sum(isunlim) > 1
    error('Multiple unlimited dimensions found in these files');
end
    
unlimdim = I.Dimensions(isunlim).Name;

function dlength = dimlength(files, dname)
% Length of dimension in all files
dlength = nan(size(files));
for ii = 1:length(files)
    ncid = netcdf.open(files{ii});
    did = netcdf.inqDimID(ncid,dname);
    [~,dlength(ii)] = netcdf.inqDim(ncid,did);
    netcdf.close(ncid);
end
    
