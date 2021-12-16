function col = cast(obj, castType)
    % COL Cast the type of a column
    %
    % Example:
    %
    %     % C1 is a column with a number but in string form
    %
    %     % Cast it to an integer
    %     newCol = C1.cast('int');

    % Copyright 2020-2021 MathWorks, Inc.

    try
        jcol = obj.column.cast(castType);
        col = matlab.compiler.mlspark.Column(jcol);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end
