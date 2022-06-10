function col = isin(obj, varargin)
    % ISIN Evaluates isin for a column
    %
    % Example: Reduce list of flights to the ones originating in SYR or
    % BWI.
    % airlines = spark.read.format("delta").load("/data/airlinedelay_delta_all")
    % airlines_part = airlines.filter(airlines.col("Origin").isin("SYR", "BWI"))
    %
    % The argument can also be a string array
    % airlines_part = airlines.filter(airlines.col("Origin").isin(["SYR", "BWI"]))

    % Copyright 2022 MathWorks, Inc.

    try
        N = numel(varargin);
        if N == 1 && isa(varargin{1}, "string")
            % In the case there is only one argument, and it's a string,
            % it's assumed this is a string array. This allows for an
            % argument like ["SYR", "BWI"]
            strArray = varargin{1};
            N = length(strArray);
            args = javaArray('java.lang.Object', N);
            for k=1:N
                args(k) = getJavaValue(strArray(k));
            end
        else
            args = javaArray('java.lang.Object', N);
            for k=1:N
                args(k) = getJavaValue(varargin{k});
            end
        end
        jcol = obj.column.isin(args);
        col = matlab.compiler.mlspark.Column(jcol);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end

function jVal = getJavaValue(val)
    switch class(val)
        case 'logical'
            jVal = java.lang.Boolean(val);
        case 'double'
            jVal = java.lang.Double(val);
        case 'single'
            jVal = java.lang.Float(val);
        case 'int16'
            jVal = java.lang.Short(val);
        case 'int32'
            jVal = java.lang.Integer(val);
        case 'int64'
            jVal = java.lang.Long(val);
        case 'string'
            jVal = java.lang.String(val);
        otherwise
            error("SPARK:ERROR", "Unsupported Datatype, %s", class(val));
    end

end
