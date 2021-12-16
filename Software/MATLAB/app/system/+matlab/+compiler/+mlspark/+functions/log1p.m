function col = log1p(col)
    % LOG1P Create a column based on natural log values of the input column +1
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc");
    %     % Convert this to a column with computed values
    %     outCol = log1p(inCol);

    % Copyright 2021 The MathWorks, Inc.

    try
        try col = col.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.log1p(col);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
              'The Spark %s function is only supported for arguments that are a matlab.compiler.mlspark.Column object or column name or a numeric value', ...
              mfilename);
    end
end
