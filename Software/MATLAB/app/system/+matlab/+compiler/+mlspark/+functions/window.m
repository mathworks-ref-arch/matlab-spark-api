function col = window(timeColumn, windowDuration, slideDuration, startTime)
    % WINDOW Bucket rows into columns
    %
    % General form
    % winCol = window(timeColumn, windowDuration, slideDuration, startTimeCol)
    %
    
    %                 Copyright 2020 MathWorks, Inc.
    
    if nargin < 4
        startTime = "0 seconds";
        if nargin < 3
            slideDuration = windowDuration;
        end
    end
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.window(...
        timeColumn.column, windowDuration, slideDuration, startTime) ...
        );
end %function
