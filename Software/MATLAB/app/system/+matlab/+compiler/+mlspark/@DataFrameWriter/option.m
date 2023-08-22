function obj = option(obj, varargin)
    % OPTION Method to specify options for writer
    %
    % Built-in options include:  
    % "mode": append | overwrite | ignore | error or errorifexists
    % "mode": SaveMode.Overwrite | SaveMode.Append | SaveMode.Ignore | SaveMode.ErrorIfExists
    % "path": "path_to_write_to"
    % For example:
    %
    %     myDataSet.write.format('parquet')...
    %         .option("mode", "overwrite") ...
    %         .save(outputLocation);
    %
    % Please note: If using the saveAsTable method, please use the mode
    % method on the DataFrameWriter object, as saveAsTable doesn't use
    % options.
    %
    % See also mode

    %  Copyright 2019-2023 MathWorks, Inc.
    
    obj.dataFrameWriter.option(varargin{:});
    
end %function
