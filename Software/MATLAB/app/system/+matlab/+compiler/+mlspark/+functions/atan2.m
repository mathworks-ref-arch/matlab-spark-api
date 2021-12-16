function col = atan2(yValues, xValues)
    % ATAN2 Create a column based on the atan2 values of the input arguments
    %
    % Inputs:
    %     yValues - a dataset column object/name or a scalar numeric value
    %     xValues - a dataset column object/name or a scalar numeric value
    %
    %     At least one of xValues, yValues must be a column object/name
    %
    % The computed values are in radians
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get 2 value columns (x,y)
    %     xCol = DS.col("x_loc");
    %     yCol = DS.col("y_loc");
    %     % Convert this to a column with arctan values of x,y
    %     outCol = pow(yCol, xCol);

    % Copyright 2021 The MathWorks, Inc.

    try
        ys = getValues(yValues);
        xs = getValues(xValues);
        jcol = org.apache.spark.sql.functions.atan2(ys, xs);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'The Spark %s function only supports arguments that are a matlab.compiler.mlspark.Column object, a column name, or a numeric scalar', ...
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
