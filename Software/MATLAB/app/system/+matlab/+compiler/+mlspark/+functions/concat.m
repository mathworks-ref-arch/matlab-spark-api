function col = concat(varargin)
    % CONCAT Concatenate several columns to one new column
    %
    % Example:
    %
    % DS = spark.read.format("delta").load("/data/airlinedelay_delta_all");
    %
    % import matlab.compiler.mlspark.functions.concat
    % import matlab.compiler.mlspark.functions.lit
    % import matlab.compiler.mlspark.functions.to_timestamp
    % DS2 = DS.withColumn("ts",  ...
    %     concat(DS.col("Year").cast("string"), lit("-"), DS.col("Month"), lit("-"), DS.col("DayofMonth")));
    % DS = DS2 ...
    %     .withColumn("TS", to_timestamp(DS2.col("TS"))) ...
    %     .select("Year", "Month", "DayofMonth", "TS", "ArrDelay", "DepDelay") ...
    %     ;
    
    % Copyright 2022 MathWorks, Inc.

    try
        N = length(varargin);
        javaArgs = javaArray('org.apache.spark.sql.Column', N);
        for k=1:N
            javaArgs(k) = convertInput(varargin{k});
        end
        jcol = org.apache.spark.sql.functions.concat(javaArgs);
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

function arg = convertInput(inArg)
    if isjava(inArg)
        arg = inArg;
    else
        switch(class(inArg))
            case 'matlab.compiler.mlspark.Column'
                arg = inArg.column;
            otherwise
                error('SPARK:ERROR', ...
                    'Unsupported type, %s', class(inArg));
        end
    end
end