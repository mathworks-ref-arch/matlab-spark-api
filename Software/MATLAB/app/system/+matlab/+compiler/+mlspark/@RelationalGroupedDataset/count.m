function ds = count(obj)
    % COUNT Count the elements in the different groups in the dataset
    
    % Copyright 2020 The MathWorks, Inc.
    
    ds = matlab.compiler.mlspark.Dataset(obj.rgDataset.count());
end