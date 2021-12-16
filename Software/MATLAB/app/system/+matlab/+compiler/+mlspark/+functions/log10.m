function col = log10(col)
    % LOG10 Create a column based on log base-10 values of the input column
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc");
    %     % Convert this to a column with computed values
    %     outCol = log10(inCol);

    % Copyright 2021 The MathWorks, Inc.

    try
        try col = col.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.log10(col);
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
