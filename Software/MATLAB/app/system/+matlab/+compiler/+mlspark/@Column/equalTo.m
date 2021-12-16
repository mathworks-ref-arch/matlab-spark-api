function col = equalTo(obj, other)
    % equalTo Compare column with another column or value for equality
    %
    % eq is the overloaded operator for this in MATLAB, and is also implemented
    % (see below)
    %
    % Example:
    %
    %     % C1 is a column
    %     % C2 is a numeric value, logical value, or another column
    %
    %     % Compare column with a constant value and another column
    %     newCol = C1.equalTo(0.01);
    %     anotherCol = C1.equalTo(aDataset.col('numericCol'))
    %
    %     % Overloaded operator version
    %     newCol = C1 == 0.01;
    %     anotherCol = C1 == aDataset.col('numericCol')

    % Copyright 2021 MathWorks, Inc.

    try
        jcol = [];
        if isa(obj, 'matlab.compiler.mlspark.Column')
            if isa(other, 'matlab.compiler.mlspark.Column')  % C1 == C2
                jcol = obj.column.equalTo(other.column);
            elseif (isnumeric(other) || islogical(other))    % C1 == 3
                jcol = obj.column.equalTo(other);
            end
        elseif (isnumeric(obj) || islogical(obj)) && isa(other, 'matlab.compiler.mlspark.Column') % 3==C1
            % We cannot directly compare #==col, so we do this: col==#
            jcol = other.column.equalTo(obj);
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
