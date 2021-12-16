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
    %         .option("overwrite") ...
    %         .save(outputLocation);
    
    %                 Copyright 2019 MathWorks, Inc.
    
    obj.dataFrameWriter.option(varargin{:});
    
end %function
