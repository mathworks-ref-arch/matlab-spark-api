function col = count(inCol)
    % COUNT Aggregate function: returns the number of items in a group.
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     dtc = DS.col("x_loc")
    %     % Convert this to a column with list of duplicate values
    %     mc = count(dtc)

    % Copyright 2021-2022 MathWorks, Inc.

    try
        try inCol = inCol.column; catch, end  % col may be a column name or object
        jcol = org.apache.spark.sql.functions.count(inCol);
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
