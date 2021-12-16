function col = asinh(inCol)
    % ASINH Create a hyperbolic arc sine column from a column
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get column
    %     dtc = DS.col("sinh_vals")
    %     % Convert this to an asinh column
    %     mc = asinh(dtc)
    %
    % Note: this function is only supported by Spark version 3.1 or newer

    % Copyright 2021 MathWorks, Inc.

    try
        try inCol = inCol.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.asinh(inCol);
    catch err
        % This function is only available since Spark version 3.1
        if strcmpi(err.identifier,'MATLAB:UndefinedFunction')
            ver = matlab.sparkutils.Config.getInMemoryConfig.CurrentVersion;
            error('SPARK:ERROR', 'Spark error: %s is only supported since Spark version 3.1 (your version: %s)', mfilename, ver);
        end
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'The Spark %s function only supports an argument that is a matlab.compiler.mlspark.Column object or a column name', ...
            mfilename);
    end
end

