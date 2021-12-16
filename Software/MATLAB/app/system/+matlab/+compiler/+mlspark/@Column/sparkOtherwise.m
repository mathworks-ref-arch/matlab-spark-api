function col = sparkOtherwise(obj, resultValue)
    % SPARKOTHERWISE the default condition in a collection of calls to when()
    %
    % The name of this method differs from normal Spark, as otherwise is a
    % reserved word in MATLAB.
    %
    % This function will return a new column.
    %
    % Example:
    %
    %     petCol = testCase.dsNames.col("Pet");
    %        dsN = testCase.dsNames.withColumn(...
    %            "testCol", ...
    %             functions.when(petCol, "Cat", "C")...
    %             .when(petCol, "Giraffe", "G")...
    %             .when(petCol, "Iguana", "I")...
    %            .sparkOtherwise("F"));

    % Copyright 2021 MathWorks, Inc.

    try
        jcol = obj.column.otherwise(resultValue);
        col = matlab.compiler.mlspark.Column(jcol);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end
