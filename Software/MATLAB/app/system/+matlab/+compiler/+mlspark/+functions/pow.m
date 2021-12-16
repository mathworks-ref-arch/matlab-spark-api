function col = pow(baseValues, powerValues)
    % POW Create a column based on values of the bases raised to a certain power
    %
    % pow(baseValues, powerValues) returns a dataset column in which the values
    % are the corresponding baseValues (a scalar or column) raised to the 
    % corresponding values in powerValues (a scalar or column).
    %
    % Inputs:
    %     baseValues  - a dataset column object/name or a scalar numeric value
    %     powerValues - a dataset column object/name or a scalar numeric value
    %
    %     At least one of baseValues, powerValues must be a column object/name
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc");
    %     % Convert this to a column with computed values
    %     outCol = pow(inCol, 2.0);  % squared values (power of 2.0)
    %     outCol = pow(inCol, 0.5);  % square-root values (power of 0.5)
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/functions.html#pow-org.apache.spark.sql.Column-org.apache.spark.sql.Column-

    % Copyright 2021 The MathWorks, Inc.

    try
        bases  = getValues(baseValues);
        powers = getValues(powerValues);
        jcol = org.apache.spark.sql.functions.pow(bases, powers);
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

function values = getValues(object)
    if isa(object, 'matlab.compiler.mlspark.Column')
        values = object.column;
    elseif isnumeric(object)
        values = double(object);
    else  % presumably char/string - keep as-is
        values = object;
    end
end
