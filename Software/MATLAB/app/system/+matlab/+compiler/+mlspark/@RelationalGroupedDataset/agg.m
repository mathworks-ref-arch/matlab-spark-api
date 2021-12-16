function ds = agg(obj, varargin)
    % AGG Aggregate the the elements using columns
    %
    % Example:
    %
    
    % Copyright 2020 The MathWorks, Inc.
       
    if isa(varargin{1}, 'matlab.compiler.mlspark.Column')
        assertUniformClass('matlab.compiler.mlspark.Column', varargin);
        mCols = [varargin{:}];
        cols = [mCols.column];
        if length(cols) > 1
            aggResults = obj.rgDataset.agg(cols(1), cols(2:end));
        else
            aggResults = obj.rgDataset.agg(cols(1), cols(1:0));
        end
    else
        error('SPARK:ERROR', ...
            'This function is only supported for input arguments of type matlab.compiler.mlspark.Column');
    end
    
    ds = matlab.compiler.mlspark.Dataset(aggResults);
    
end