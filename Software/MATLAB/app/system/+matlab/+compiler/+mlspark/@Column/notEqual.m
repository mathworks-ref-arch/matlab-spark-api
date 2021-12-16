function col = notEqual(obj, other)
    % notEqual Compare column with another column or value for inequality
    %
    % ne is the overloaded operator for this in MATLAB, and is also implemented
    % (see below)
    % 
    % Example:
    %
    %     % C1 is a column
    %     % C2 is a numeric value, logical value, or another column
    %
    %     % Compare column with a value or another column for inequality
    %     newCol = C1.notEqual(0.01);
    %     anotherCol = C1.notEqual(aDataset.col('numericCol'))
    %
    %     % Overloaded operator version
    %     newCol = C1 ~= 0.01;
    %     anotherCol = C1 ~= aDataset.col('numericCol')
    
    % Copyright 2021 MathWorks, Inc.

    try
        jcol = [];
        if isa(obj, 'matlab.compiler.mlspark.Column') 
            if isa(other, 'matlab.compiler.mlspark.Column')  % C1 ~= C2
                jcol = obj.column.notEqual(other.column);
            elseif (isnumeric(other) || islogical(other))    % C1 ~= 3
                jcol = obj.column.notEqual(other);
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
