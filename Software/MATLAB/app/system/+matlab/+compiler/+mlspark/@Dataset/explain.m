function output = explain(obj, mode)
    % EXPLAIN Method to display the schema plans.
    %
    % This method will display the scema plans (logical and physical) using a
    % format specified by a given explain mode.
    %
    % explain(obj) displays the physical plan of the schema
    %
    % explain(obj, false) displays the schema physical plan, same as explain(obj)
    %
    % explain(obj, true) displays both the schema physical plan, as well as the
    % logical plans (parsed, analyzed, optimized).
    %
    % explain(obj, mode) specifies the expected display format of plans, based
    % on the value of mode (a string or char array):
    %   "simple"    - display only a physical plan
    %   "extended"  - display both logical and physical plans
    %   "codegen"   - display a physical plan and generated codes (if available)
    %   "cost"      - display a logical plan and statistics (if available)
    %   "formatted" - display two sections: physical plan outline and node details
    %
    % output = explain(_) returns the explain output as a string rather than
    % displaying it in the console.
    %
    % Example:
    %
    %     % Create a dataset
    %     myLocation = '/test/*.parquet');
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %
    %     % Display the dataset's physical and logical explain plans
    %     myDataSet.explain("extended");  %or: myDataSet.explain(true)
    %
    % Reference: 
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#explain-java.lang.String-

    % Copyright 2021 MathWorks, Inc.

    if nargin < 2
        mode = false;
    end
    if islogical(mode) || isa(mode, 'char') || isa(mode, 'string')
        try
            if nargout  % capture explain output into output arg
                output = strtrim(evalc('obj.dataset.explain(mode);'));
            else  % display explain output in console
                obj.dataset.explain(mode);
            end
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    else
        error('SPARK:ERROR', 'Wrong datatype for explain mode: must be a logical (true/false) or string value');
    end
    
end %function
