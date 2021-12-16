function col = when(theColumn, testValue, resultValue)
    % WHEN Creates a condition for multiple value expressions
    %
    %
    % theColumn - the column whose values are used for the conditions
    % testValue - the condition to test against (equals to)
    % resultValue - the valu
    % This function will return a new column
    % Example:
    %
    %     petCol = testCase.dsNames.col("Pet");
    %        dsN = testCase.dsNames.withColumn(...
    %            "testCol", ...
    %             functions.when(petCol, "Cat", "C")...
    %             .when(petCol, "Giraffe", "G")...
    %             .when(petCol, "Iguana", "I")...
    %            .sparkOtherwise("F"));
    
    %                 Copyright 2021 MathWorks, Inc.
    
    jCol = theColumn.column;
    resCol = org.apache.spark.sql.functions.when(...
        equalTo(jCol, testValue), ...
        resultValue);
    col = matlab.compiler.mlspark.Column(resCol);
end %function
