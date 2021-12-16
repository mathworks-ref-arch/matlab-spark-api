function sumDS = sum(obj, varargin)
    % SUM Sum the elements in a RelationalGroupDataset
    
    % Copyright 2021 The MathWorks, Inc.
    
    jArray = string2java(varargin{:});
    tmpDS = obj.rgDataset.sum(jArray);
    sumDS = matlab.compiler.mlspark.Dataset(tmpDS);
end
