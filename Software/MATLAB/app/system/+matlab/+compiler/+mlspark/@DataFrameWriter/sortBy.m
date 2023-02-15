function obj = sortBy(obj, varargin)
    % SORTBY Specify sort order for saving
    %
    % DS.write.bucketBy(15, "Name").sortBy("id").mode("overwrite").saveAsTable("default.sorting_1");
    %
    % DS.write.bucketBy(33, "Name").sortBy("Other").mode("overwrite").saveAsTable("default.sorting_2");

    %  Copyright 2023 MathWorks, Inc.

    if length(varargin)==1  % a single cellstr or string array
        cols = string(varargin{1});
    else  % multiple char array or string input args
        cols = string(varargin);
    end
    % Spark's sortBy() API for strings requires 2 inputs: String,String[]
    if length(cols) > 1  % multiple sort columns
        sortCols = {cols(1), cols(2:end)};
    else  % a single sort column
        sortCols = {cols, javaArray('java.lang.String',0)};
    end

    obj.dataFrameWriter.sortBy(sortCols{:});

end %function
