function col = between(obj, lowerBound, upperBound)
    % BETWEEN Filter entries in a certain range
    %
    % Example:
    %
    %     % C1 is a column
    %
    %     % Make the sort order descending
    %     newCol = C1.between('2010-01-14', '2011-05-22');

    % Copyright 2020-2021 MathWorks, Inc.

    try
        jcol = obj.column.between(lowerBound, upperBound);
        col = matlab.compiler.mlspark.Column(jcol);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end
