function meanDS = mean(obj, varargin)
    % MEAN Calculates the mean of the columns given as arguments
    
    % Copyright 2020 The MathWorks, Inc.
    
    jArray = string2java(varargin{:});
    tmpDS = obj.rgDataset.mean(jArray);
    meanDS = matlab.compiler.mlspark.Dataset(tmpDS);
end