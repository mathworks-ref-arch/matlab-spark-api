function col = slice(col, start, length)
    % SLICE Create a column based on a slice of values in the input column
    %
    % slice(col,start,length) returns a dataset column in which the values are
    % all the elements in the input column col (which should be an Array type)
    % from the start index in each array (or starting from the end if start is
    % negative), with the specified length.
    %
    % For example, slice(col,3,4) is analogous to the Matlab syntax data(:,3:6)
    %
    % Inputs:
    %     col    - a dataset column object to be sliced. Must be an Array type.
    %     start  - index of first element (or backward from end, if negative).
    %              1 means the first element in each array; -1 means the last.
    %     length - number of elements in the requested slice of each array.
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc");
    %     % Convert this to a column with the 4 elements starting at index 3
    %     outCol = slice(inCol, 3, 4);  % get elements 3 to 6 in each inCol item
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/functions.html#slice-org.apache.spark.sql.Column-int-int-

    % Copyright 2021 The MathWorks, Inc.

    try
        % Any of the input args may be a Column object
        try col    = col.column;    catch, end
        try start  = start.column;  catch, end
        try length = length.column; catch, end
        jcol = org.apache.spark.sql.functions.slice(col, start, length);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
              'The Spark %s function expects input arguments that are a matlab.compiler.mlspark.Column object, and 2 numeric values', ...
              mfilename);
    end
end
