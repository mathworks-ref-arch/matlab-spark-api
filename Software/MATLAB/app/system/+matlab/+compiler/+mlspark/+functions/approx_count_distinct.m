function col = approx_count_distinct(col,rsd)
    % approx_count_distinct returns the approximate number of distinct column elements
    %
    % approx_count_distinct(col) returns a column with the approximate number
    % of distinct items in the input column.
    %
    % approx_count_distinct(col,rsd) uses the optional input rsd as the maximal
    % relative standard deviation allowed by the calculation. Default val: 0.05
    %
    % Inputs:
    %     col - a dataset column name or column object
    %     rsd - (optional) maximum relative standard deviation allowed
    %           (default value = 0.05)
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc")
    %     % Get the approximate number of distinct values (max relative STD = 2)
    %     outCol = approx_count_distinct(inCol, 2.0)
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/functions.html#approx_count_distinct-org.apache.spark.sql.Column-

    % Copyright 2021 The MathWorks, Inc.

    try
        try col = col.column; catch, end  % col may be a column name or object
        if nargin < 2
            jcol = org.apache.spark.sql.functions.approx_count_distinct(col);
        else
            jcol = org.apache.spark.sql.functions.approx_count_distinct(col, rsd);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
              'The Spark %s function only supports arguments that are numeric, a string, or a matlab.compiler.mlspark.Column object', ...
              mfilename);
    end
end
