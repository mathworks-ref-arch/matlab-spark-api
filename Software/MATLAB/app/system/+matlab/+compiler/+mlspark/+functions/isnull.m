function col = isnull(inCol)
    % ISNULL Create a column of logicals indicating whether column values are null
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get column
    %     dtc = DS.col("vals")
    %     % Convert this to a column of logical values
    %     mc = isnull(dtc)
    
    % Copyright 2021 MathWorks, Inc.
    
    try
        try inCol = inCol.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.isnull(inCol);
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

