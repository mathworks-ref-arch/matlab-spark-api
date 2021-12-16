function col = divide(obj, other)
    % divide a column by another column or a value
    %
    % rdivide (element-wise) is also overloaded as an operator (see below)
    %
    % Example:
    %
    %     % DS is a dataset
    %     % C1 is a column 
    %     % C2 is a value or another column
    %
    %     % Divide by a constant value and by another column
    %     C1 = DS.col("columnName");
    %     C2 = DS.col("anotherColumnName");
    %     DS2 = DS.withColumn("columnNameToAddOrReplace", C1.divide(10));
    %     DS3 = DS.withColumn("columnNameToAddOrReplace", C1.divide(C2));
    %
    %     % with operator overloading
    %     DS2 = DS.withColumn("columnNameToAddOrReplace", C1 / 10);
    %     DS3 = DS.withColumn("columnNameToAddOrReplace", C1 ./ C2);
    
    % Copyright 2021 MathWorks, Inc.
    
    try
        jcol = [];
        if isa(obj, 'matlab.compiler.mlspark.Column') 
            if isa(other, 'matlab.compiler.mlspark.Column')  % C1 / C2
                jcol = obj.column.divide(other.column);
            elseif isnumeric(other)                          % C1 / 3
                jcol = obj.column.divide(other);
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
