function data = h5struct(h5_file, dataset, fill_with_nan)
% h5struct loads HDF5 data into a Matlab stucture with the same
% hierarchy as the original file.
%
%% Syntax
%
%  data = hfive2struct(filename)
%  data = hfive2struct(filename, dataset)
%  data = hfive2struct(filename, dataset, true)
%  data = hfive2struct(filename, [], true)
%
%% Description
% data = hfive2struct(filename) loads all attibutes, dataset values
% and dataset atributes of the h5 filename into a Matlab stucture with the same
% hierarchy as the original file. [currenlty handles up to 11 group levels]
% 
% data = hfive2struct(filename, dataset) loads only the requested dataset
% and associated attibutes of filename into a Matlab stucture with the same
% hierarchy as the original filename. dataset is the full h5 path to the
% desired dataset. dataset can be specified as either a string or cell
% array of stings e.g. /path/to/dataset or {path/to/dataset1, path/to/dataset2}.
% 
% data = hfive2struct(filename, dataset, fill_with_nan) loads only the requested
% dataset and associated attibutes of filename into a Matlab stucture. If 
% fill_with_nan = true, all single and double datasets having a _FillValue
% will have _FillValue replaced with NaNs.
% 
%% User Input
%
%       h5_file = full path to hdf5 file
%       dataset = full dataset path within hdf5 structure (optional)
%              can be specified as either a string or cell array of stings
%              e.g. '/orbit_info/rgt' or
%               {'/orbit_info/rgt', /ancillary_data/control'};
%
%       fill_with_nan = true or false, if true single and double datasets
%       with a _FillValue will have _FillValue filled with NaNs
%
%
%% Author Info
% This function was written by Alex S. Gardner, JPL-Caltech, Oct 2018.
% 
% See also: h5read. 


%% Set defaults and initialize
narginchk(1,3) 

if exist('fill_with_nan', 'var') ~= 1
    % default behaviour is to fill with nans
    fill_with_nan = false;
elseif ~islogical(fill_with_nan)
    error('fill_with_nan must be logical')
end

data = struct;

%% Extract requested data
% if only a specific dataset is requested
if exist('dataset', 'var') == 1 && ~isempty(dataset)
    if iscell(dataset)
        for l1 = 1:length(dataset)
            
            if ~ischar(dataset{l1})
                error('dataset must be specified as a charater or a cell array of characters')
            end
            
            I = h5info(h5_file, dataset{l1});
            
            field_tree = strsplit(dataset{l1},'/');
            field_tree(cellfun(@isempty, field_tree)) = [];
            
            struct_out = h5read_parse(h5_file, I, dataset{l1}, fill_with_nan);
            data = setfield(data,field_tree{:}, struct_out);
        end
    elseif ischar(dataset)
        I = h5info(h5_file, dataset);
        
        field_tree = strsplit(dataset,'/');
        field_tree(cellfun(@isempty, field_tree)) = [];
        
        struct_out = h5read_parse(h5_file, I, dataset, fill_with_nan);
        data = setfield(data,field_tree{:}, struct_out);
    else
        error('dataset must be specified as a charater or a cell array of characters') 
    end
else
    % return full dataset
    I = h5info(h5_file);
    dataPath = '/';

    % extract datasets - level 0
    if ~isempty(I.Datasets)
        % extract datasets - level 2
        for d = 1:length(I.Datasets)
            datasetA = I.Datasets(d).Name;
            datasetB = datasetA;
            datasetB(datasetB == '-') = '_';
            
            struct_out = h5read_parse(h5_file, I.Datasets(d), [dataPath  datasetA], fill_with_nan);
            data = setfield(data,datasetB,'Value',struct_out.Value);
            data = setfield(data,datasetB,'Attributes', struct_out.Attributes);
        end
    end
    
    if ~isempty(I.Attributes)
        struct_out = h5read_parse(h5_file, I, dataPath, fill_with_nan);
        data = setfield(data,'Attributes', struct_out.Attributes);
    end
    
    dataPath1 = '';
    stuctTree1 = {};
    for l1 = 1:length(I.Groups)
        [data, dataPath2, stuctTree2] = h5_in_stuct(h5_file, data, dataPath1, stuctTree1, I.Groups(l1), fill_with_nan);
        
        for l2 = 1:length(I.Groups(l1).Groups)
            [data, dataPath3, stuctTree3] = h5_in_stuct(h5_file, data, dataPath2, stuctTree2, I.Groups(l1).Groups(l2), fill_with_nan);
            
            for l3 = 1:length(I.Groups(l1).Groups(l2).Groups)
                [data, dataPath4, stuctTree4] = h5_in_stuct(h5_file, data, dataPath3, stuctTree3, I.Groups(l1).Groups(l2).Groups(l3), fill_with_nan);
                
                for l4 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups)
                    [data, dataPath5, stuctTree5] = h5_in_stuct(h5_file, data, dataPath4, stuctTree4, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4), fill_with_nan);
                    
                    for l5 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups)
                        [data, dataPath6, stuctTree6] = h5_in_stuct(h5_file, data, dataPath5, stuctTree5, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5), fill_with_nan);
                        
                        for l6 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups)
                            [data, dataPath7, stuctTree7] = h5_in_stuct(h5_file, data, dataPath6, stuctTree6, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6), fill_with_nan);
                            
                            for l7 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups)
                                [data, dataPath8, stuctTree8] = h5_in_stuct(h5_file, data, dataPath7, stuctTree7, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7), fill_with_nan);
                                
                                for l8 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups)
                                    [data, dataPath9, stuctTree9] = h5_in_stuct(h5_file, data, dataPath8, stuctTree8, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups(l8), fill_with_nan);
                                    
                                    for l9 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups(l8).Groups)
                                        [data, dataPath10, stuctTree10] = h5_in_stuct(h5_file, data, dataPath9, stuctTree9, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups(l8).Groups(l9), fill_with_nan);
                                        
                                        for l10 = 1:length(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups(l8).Groups(l9).Groups)
                                            if ~isempty(I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups(l8).Groups(l9).Groups(l10).Groups)
                                                error('11th group level should needs to added')
                                            else
                                                [data, ~, ~] = h5_in_stuct(h5_file, data, dataPath10, stuctTree10, I.Groups(l1).Groups(l2).Groups(l3).Groups(l4).Groups(l5).Groups(l6).Groups(l7).Groups(l8).Groups(l9).Groups(l10), fill_with_nan);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end

%% struct_out funciton extracts data at bottom of data tree
function struct_out = h5read_parse(h5_file, I, field_name, fill_with_nan)
struct_out = struct;
if isfield(I,'Group') || isfield(I,'Groups')
    if ~isempty(I.Attributes)
        
        % extract attributes - level 4
        for a = 1:length(I.Attributes)
            attrA = I.Attributes(a).Name;
            attrB = attrA;
            attrB(attrB == '-') = '_';
            
            struct_out.Attributes.(attrB) = I.Attributes(a).Value;
        end
    end
else
    struct_out.Value = h5read(h5_file, field_name);
    
    % replace fill value
    fillIdx = strcmp({I.Attributes.Name}, '_FillValue');
    if any(fillIdx)
        FillValue = I.Attributes(fillIdx).Value;
    else
        FillValue = [];
    end
    
    if ~isempty(FillValue) && fill_with_nan && (isa(FillValue, 'single') || isa(FillValue, 'double'))
        struct_out.Value(struct_out.Value == FillValue) = nan;
        I.Attributes(strcmp({I.Attributes.Name}, '_FillValue')).Value = nan;
    end
    
    for a = 1:length(I.Attributes)
        attrA = I.Attributes(a).Name;
        attrB = attrA;
        attrB(attrB == '-') = '_';
        if attrB(1) == '_'
            attrB = attrB(2:end);
        end
        struct_out.Attributes.(attrB) =  I.Attributes(a).Value;
    end
end
end

function [data, dataPath0, stuctTree0] = h5_in_stuct(h5_file, data, dataPath, stuctTree, I0, fill_with_nan)
% This function places the h5 data into the structure
[~,groupA] = fileparts(I0.Name);
groupB = regexprep(groupA, '-', '_');

dataPath0 = [dataPath '/' groupA];

stuctTree0 = {stuctTree{:} groupB};

if ~isempty(I0.Datasets)
    % extract datasets
    for d = 1:length(I0.Datasets)
        datasetA = I0.Datasets(d).Name;
        datasetB = regexprep(datasetA, '-', '_');
        struct_out = h5read_parse(h5_file, I0.Datasets(d), [dataPath0  '/' datasetA], fill_with_nan);
        data = setfield(data,stuctTree0{:},datasetB,struct_out);
    end
end

if ~isempty(I0.Attributes)
    struct_out = h5read_parse(h5_file, I0, dataPath0, fill_with_nan);
    data = setfield(data,stuctTree0{:},'Attributes', struct_out.Attributes);
end
end
