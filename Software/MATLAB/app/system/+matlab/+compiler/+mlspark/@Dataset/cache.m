function ds = cache(obj, varargin)
    % CACHE Persist this Dataset with the default storage level
    % This dataset is persisted with the default storage level
    % (MEMORY_AND_DISK).

    % Copyright 2020-2021 MathWorks, Inc.

    try
        ds = matlab.compiler.mlspark.Dataset(obj.dataset.cache());
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
