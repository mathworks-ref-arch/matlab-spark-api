function col = lt(obj, other)
    % lt Compare less than for a column by another column or a value
    %
    % lt is also the overloaded as an operator (see below)
    %
    % Example:
    %
    %     % C1 is a column
    %     % C2 is a value or another column
    %
    %     % Check which column items are < a value or another column
    %     newCol = C1.lt(0.01);
    %     anotherCol = C1.lt(aDataset.col('numericCol'))
    %
    %     % Overloaded operator version
    %     newCol = C1 < 0.01;
    %     anotherCol = C1 < aDataset.col('numericCol')
    
    % Copyright 2021 MathWorks, Inc.
    
    try
        jcol = [];
        if isa(obj, 'matlab.compiler.mlspark.Column') 
            if isa(other, 'matlab.compiler.mlspark.Column')  % C1 < C2
                jcol = obj.column.lt(other.column);
            elseif isnumeric(other)                          % C1 < 3
                jcol = obj.column.lt(other);
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
