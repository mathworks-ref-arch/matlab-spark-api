function col = geq(obj, other)
    % ge Compare greater than or equal for a column by another column or a value
    %
    % ge is the overloaded operator for this in MATLAB, and is also implemented
    % (see below)
    %
    % Example:
    %
    %     % C1 is a column
    %     % C2 is a value or another column
    %
    %     % Check which column items are >= a value or another column
    %     newCol = C1.geq(0.01);
    %     anotherCol = C1.geq(aDataset.col('numericCol'))
    %
    %     % Overloaded operator version
    %     newCol = C1 >= 0.01;
    %     anotherCol = C1 >= aDataset.col('numericCol')

    % Copyright 2021 MathWorks, Inc.

    try
        jcol = [];
        if isa(obj, 'matlab.compiler.mlspark.Column')
            if isa(other, 'matlab.compiler.mlspark.Column')  % C1 >= C2
                jcol = obj.column.geq(other.column);
            elseif isnumeric(other)                          % C1 >= 3
                jcol = obj.column.geq(other);
            end
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'This function is only supported for arguments that are numeric or of the type matlab.compiler.mlspark.Column');
    end

end
