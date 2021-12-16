function col = plus(obj, other)
    % COL add a column to another column or a value
    %
    % plus is also overloaded as an operator (see below)
    %
    % Example:
    %     % DS is a dataset
    %     % C1 is a column 
    %     % C2 is a value or another column
    %
    %     % 
    %     C1 = DS.col("columnName");
    %     C2 = DS.col("anotherColumnName");
    %     DS2 = DS.withColumn("columnNameToAddOrReplace", C1.plus(10));
    %     DS3 = DS.withColumn("columnNameToAddOrReplace", C1.plus(C2));
    %
    %     % with operator overloading
    %     DS2 = DS.withColumn("columnNameToAddOrReplace", C1 + 10);
    %     DS3 = DS.withColumn("columnNameToAddOrReplace", C1 + C2);
    
    % Copyright 2021 MathWorks, Inc.

    try
        jcol = [];
        if isa(obj, 'matlab.compiler.mlspark.Column')
            if isa(other, 'matlab.compiler.mlspark.Column')  % C1 + C2
                jcol = obj.column.plus(other.column);
            elseif isnumeric(other)                          % C1 + 3
                jcol = obj.column.plus(other);
            end
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'This function is only supported for arguments that are numeric or of type matlab.compiler.mlspark.Column');
    end
end
