function col = monotonically_increasing_id()
    % monotonically_increasing_id Generate a column with increasing ID values.
    %
    % This function will return a new column with integer values starting at 0.
    %
    % Example:
    %
    %     % Add a column with numeric ID values to dataset DS
    %     newDS = DS.withColumn('ID',monotonically_increasing_id())

    % Copyright 2020-2022 MathWorks, Inc.

    try
        jcol = org.apache.spark.sql.functions.monotonically_increasing_id();
    catch err
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
