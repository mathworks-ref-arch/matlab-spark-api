function rgds = groupBy(obj, varargin)
    % GROUPBY Group dataset by certain columns
    %
    % This will return a new RelationalGroupDataset
    %
    % Example: Group Origins and weekdays, to see which airport has the
    % most (and fewest) departures.
    %
    %     % Create a dataset of flight data
    %     flights = spark.read.format("csv") ...
    %         .option("header", "true") ...
    %         .option("inferSchema", "true") ...
    %         .load(['file://', which('airlinesmall.csv')]);
    %
    %     DS = flights.groupBy("Origin", "DayOfWeek").count();
    %
    %     % Show ascending sort
    %     DS.sort("count").show(10);
    %
    %     % Show descending sort
    %     DS.sort(DS.col("count").desc()).show(10);

    % Copyright 2020-2021 MathWorks, Inc.

    try
        if isa(varargin{1}, 'matlab.compiler.mlspark.Column')
            assertUniformClass('matlab.compiler.mlspark.Column', varargin);
            mCols = [varargin{:}];
            groupByResults = obj.dataset.groupBy(makeJavaArray([mCols.column]));
        else
            cols = string(varargin);
            if length(cols) > 1
                groupByResults = obj.dataset.groupBy(cols(1), cols(2:end));
            else
                groupByResults = obj.dataset.groupBy(cols, javaArray('java.lang.String',0));
            end
        end
        rgds = matlab.compiler.mlspark.RelationalGroupedDataset(groupByResults);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end %function
