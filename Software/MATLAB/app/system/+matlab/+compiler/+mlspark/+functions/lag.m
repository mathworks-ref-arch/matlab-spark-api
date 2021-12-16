function col = lag(col, offset, defaultValue, ignoreNulls)
    % LAG Create a column based on offset values in the input column
    %
    % lag(col,offset,defaultValue,ignoreNulls) returns a dataset column with
    % the values that are at a given offset to the values in the input col,
    % with an optional defaultValue for offset values outside the column (with-
    % out a defaultValue, null is used for values outside the column boundary).
    % ignoreNulls determines whether null values of row are included in or 
    % eliminated from the calculation.
    %
    % This is equivalent to the LAG function in SQL.
    %
    % Inputs:
    %     col    - a dataset column object that is to be processed
    %     offset - (optional) offset of values to return. For example, 1
    %              means the values in the previous row, for all column rows.
    %              Default value = 1.
    %     defaultValue - (optional) the value to use for offset values outside
    %              the column boundary. This value will be used for the first
    %               <offset> values in the output column.
    %     ignoreNulls - (optional) a logical flag indicating whether or not to
    %              include null values in the lag calculations.
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc");
    %     % Convert this to a column with a lag of 2 elements
    %     outCol = lag(inCol, 2);
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/functions.html#lag-org.apache.spark.sql.Column-int-

    % Copyright 2021 The MathWorks, Inc.

    % Process the input offset argument
    if nargin < 2, offset = 1; end
    assert(isnumeric(offset) && isscalar(offset), 'The lag function expects a scalar integer offset');
    offset = int16(offset);  % convert from double => int

    % Process the SQL function on the data column values
    try
        try col = col.column; catch, end
        if nargin < 3
            jcol = org.apache.spark.sql.functions.lag(col, offset);
        elseif nargin < 4
            jcol = org.apache.spark.sql.functions.lag(col, offset, defaultValue);
        else
            ignoreNulls = logical(ignoreNulls);
            jcol = org.apache.spark.sql.functions.lag(col, offset, defaultValue, ignoreNulls);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
              'The Spark %s function expects input arguments that are a matlab.compiler.mlspark.Column object, integer offset, optional defaultValue, and optional ignoreNull', ...
              mfilename);
    end
end
