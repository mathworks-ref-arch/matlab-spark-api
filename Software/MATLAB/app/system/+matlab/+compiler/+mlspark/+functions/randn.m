function col = randn(seed)
    % RAND Generate a random column with independent random values between 0-1.
    %
    % randn() will return a new column with independent and identically
    % distributed (i.i.d.) samples using the standard normal distribution.
    %
    % randn(seed) will return values using the specified input SEED (long int).
    %
    % Example:
    %
    %     % Add a column with random numeric values to dataset DS
    %     newDS = DS.withColumn('Random_Value',randn())
    
    % Copyright 2020-2022 MathWorks, Inc.    
    
    try
        if nargin < 1
            jcol = org.apache.spark.sql.functions.randn();
        else
            jcol = org.apache.spark.sql.functions.randn(seed);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'The Spark %s function only supports an argument that is a matlab.compiler.mlspark.Column object or a column name', ...
            mfilename);
    end
end
