function col = acos(inCol)
    % ACOS Create an arc cosine column from a column
    %
    % The computed values are in radians
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get column
    %     dtc = DS.col("cos_vals")
    %     % Convert this to an arc cosine column
    %     mc = acos(dtc)
    
    % Copyright 2020-2021 MathWorks, Inc.

    try
        try inCol = inCol.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.acos(inCol);
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
