function col = tanh(inCol)
    % TANH Create a hyperbolic tangent column from a column of values
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get column
    %     dtc = DS.col("vals")
    %     % Convert this to a hyperbolic tangent column
    %     mc = tanh(dtc)
    
    % Copyright 2021 MathWorks, Inc.
    
    try
        try inCol = inCol.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.tanh(inCol);
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

