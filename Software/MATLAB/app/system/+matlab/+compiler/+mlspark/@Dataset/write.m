function dfWriter = write(obj, varargin)
    % WRITE Obtain a DataFrameWriter from the Dataset

    % Copyright 2020-2021 MathWorks, Inc.

    try
        jdfWriter = obj.dataset.write();
        dfWriter = matlab.compiler.mlspark.DataFrameWriter(jdfWriter);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
