function col = or(obj, other)
    % or Boolean or for a column by another column or a value
    %
    % or is also overloaded as an operator (see below)
    %
    % Example:
    %
    %     % C1 is a column
    %     % C2 is a value or another column
    %
    %     % "Or" by another column
    %     anotherCol = C1.or(aDataset.col('numericCol'))
    %
    %     % Overloaded operator version
    %     anotherCol = C1 | aDataset.col('numericCol')

    % Copyright 2021 MathWorks, Inc.

    try
        jcol = [];
        if isa(obj,   'matlab.compiler.mlspark.Column') && ...
                isa(other, 'matlab.compiler.mlspark.Column')
            jcol = obj.column.or(other.column);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'This function is only supported for arguments that are of type matlab.compiler.mlspark.Column');
    end
end
