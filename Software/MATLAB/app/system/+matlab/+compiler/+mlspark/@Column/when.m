function col = when(obj, origCol, testValue, resultValue)
    % WHEN Creates a condition for multiple value expressions
    %
    % origCol     - column used for the original call to when (functions.when)
    % testValue   - condition to test against (equals to)
    % resultValue - value the returned column will have if the condition is met
    %
    % This function will return a new column
    %
    % Example:
    %
    %     petCol = testCase.dsNames.col("Pet");
    %     dsN = testCase.dsNames.withColumn(...
    %         "testCol", ...
    %         functions.when(petCol, "Cat", "C")...
    %         .when(petCol, "Giraffe", "G")...
    %         .when(petCol, "Iguana", "I")...
    %         .sparkOtherwise("F"));
    %
    % Copyright 2021 MathWorks, Inc.

    try
        jcol = equalTo(origCol.column, testValue);
        jcol = obj.column.when(jcol, resultValue);
        col = matlab.compiler.mlspark.Column(jcol);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end
