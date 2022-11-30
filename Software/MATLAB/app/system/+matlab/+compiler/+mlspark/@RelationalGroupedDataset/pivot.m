function rgds = pivot(obj, column, varargin)
    % PIVOT Pivots a column of the current `DataFrame` and performs the specified aggregation.
    % 
    % pivot with one argument, will simply pivot around that column. The
    % argument should be the name of that column, e.g.
    %
    %   pivotDS = DS.groupBy("Fruit").pivot("Country").sum("Amount");
    %
    % Pivot can be given additional arguments, to specify exactly what
    % elements of the pivot column should be taken into account, e.g.
    %
    %  pivotDS = DS.groupBy("Fruit").pivot("Country", countries).sum("Amount");
    % 
    % or 
    %
    %  pivotDS = DS.groupBy("Fruit").pivot("Country", "China", "Mexico").sum("Amount");
    %
    % The additional arguments can be either one string array, or several
    % separate strings.

    % Copyright 2022 The MathWorks, Inc.

    if isempty(varargin)
        rgds = matlab.compiler.mlspark.RelationalGroupedDataset(obj.rgDataset.pivot(column));
    else
        try
            if length(varargin) == 1 && isstring(varargin{1})
                strings = varargin{1};
            else
                strings = string(varargin);
            end
            stringList = java.util.Arrays.asList(string2java(strings));
            rgds = matlab.compiler.mlspark.RelationalGroupedDataset(obj.rgDataset.pivot(column, stringList));
        catch ME
            error("SPARKAPI:pivot_function_arguments", ...
                "Bad arguments to pivot function. Please cf. Apache Spark documentation.");
        end
    end
end