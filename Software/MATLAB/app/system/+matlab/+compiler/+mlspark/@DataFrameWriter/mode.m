function obj = mode(obj, saveMode)
    % MODE Specify save mode for writer
    %
    % It may be necessary to use this method instead of
    %   .option("mode", "some-mode"),
    % as saveAsTable will look at the mode, but not at options.
    %
    % Built-in options include:  
    % append | overwrite | ignore | error or errorifexists
    % 
    % For example:
    %
    %     myDataSet.write ...
    %         .mode("overwrite") ...
    %         .saveAsTable(outputLocation);
    
    %  Copyright 2023 MathWorks, Inc.
    
    if ~ischar(saveMode) && ~isStringScalar(saveMode)
        error('SPARKAPI:dataframewriter_mode', ...
            'The argument must be a string or a char array.')
    end

    obj.dataFrameWriter.mode(saveMode);
    
end %function
