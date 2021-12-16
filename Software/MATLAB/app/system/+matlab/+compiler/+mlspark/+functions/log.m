function col = log(base, col)
    % LOG Create a column based on logarithmic values of the input column
    %
    % log(column) returns a dataset column in which the values are the natural
    % logarithm (ln) values of the corresponding values in the input column.
    %
    % log(base, column) returns a dataset column with the logaritm with the
    % specified base of the corresponding values in the input column.
    %
    % Inputs:
    %     base - a scalar numeric value
    %     col  - a dataset column object/name
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc");
    %     % Convert this to a column with computed values
    %     outCol = log(inCol);      % natural log values: ln(x)
    %     outCol = log(inCol, 10);  % log-10 values

    % Copyright 2021 The MathWorks, Inc.

    try
        if nargin < 2  % natural log values
            try base = base.column; catch, end  % col may be a column name or object
            jcol = org.apache.spark.sql.functions.log(base);
        else
            base = double(base(1));
            try col = col.column; catch, end  % col may be a column name or object
            jcol = org.apache.spark.sql.functions.log(base, col);
        end
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
