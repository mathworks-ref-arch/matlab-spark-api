function col = rand(seed)
    % RAND Generate a random column with independent random values between 0-1.
    %
    % rand() will return a new column with independent and identically
    % distributed (i.i.d.) samples uniformly distributed in [0.0, 1.0).
    %
    % rand(seed) will return values using the specified input SEED (long int).
    %
    % Example:
    %
    %     % Add a column with random numeric values to dataset DS
    %     newDS = DS.withColumn('Random_Value',rand())
    
    % Copyright 2020-2022 MathWorks, Inc.    
    
    try
        if nargin < 1
            jcol = org.apache.spark.sql.functions.rand();
        else
            jcol = org.apache.spark.sql.functions.rand(seed);
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
