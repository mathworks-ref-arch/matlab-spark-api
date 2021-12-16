function col = desc(obj)
    % DESC Set the sort order to descending for a column
    %
    % Example:
    %
    %     % C1 is a column
    %
    %     % Make the sort order descending
    %     newCol = C1.desc();

    % Copyright 2020-2021 MathWorks, Inc.

    try
        jcol = obj.column.desc();
        col = matlab.compiler.mlspark.Column(jcol);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end
