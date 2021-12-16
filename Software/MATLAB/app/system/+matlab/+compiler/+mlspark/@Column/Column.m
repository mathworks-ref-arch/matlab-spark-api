classdef Column < handle
    % Column MATLAB class wrapper for Spark Java Column objects

    % Copyright 2020-2021 The MathWorks, Inc.

    properties (Hidden=true)
        column
    end
    properties (SetAccess=private)
        Description
    end

    methods
        function obj = Column(col)
            if isa(col, 'org.apache.spark.sql.Column')
                obj.column = col;
                obj.Description = string(obj.column);
            else
                error('SPARK:ERROR', 'The argument must be a java object of type org.apache.spark.sql.Column');
            end
        end

        %% Overloaded operators
        % Some overloaded operators have the same names as their Spark
        % counterparts, and therefore exist as methods in separate files.
        % These are: minus, plus, lt, gt
        function col = times(obj, other)
            col = multiply(obj, other);
        end
        function col = mtimes(obj, other)
            col = multiply(obj, other);
        end

        function col = rdivide(obj, other)
            col = divide(obj, other);
        end
        function col = mrdivide(obj, other)
            col = divide(obj, other);
        end

        function col = uminus(obj)
            try
                jcol = javaMethod('unary_$minus',obj.column);
            catch err
                error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
            end
            col = matlab.compiler.mlspark.Column(jcol);
        end

        function col = not(obj)
            try
                jcol = javaMethod('unary_$bang',obj.column);
            catch err
                error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
            end
            col = matlab.compiler.mlspark.Column(jcol);
        end

        function col = as(obj, aliasName)
            try
                jcol = obj.column.as(aliasName);
            catch err
                error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
            end
            col = matlab.compiler.mlspark.Column(jcol);
        end

        function col = ge(obj, other)
            col = geq(obj, other);
        end

        function col = le(obj, other)
            col = leq(obj, other);
        end

        function col = eq(obj, other)
            col = equalTo(obj, other);
        end

        function col = ne(obj, other)
            col = notEqual(obj, other);
        end

        %% Useful wrapper methods
        function str = char(obj)
            str = char(obj.column);
        end
        function str = string(obj)
            str = string(obj.column);
        end
    end
end
