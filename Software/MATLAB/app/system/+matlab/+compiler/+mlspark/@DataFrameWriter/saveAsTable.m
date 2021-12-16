function saveAsTable(obj, tableName)
    % SAVEASTABLE Method to save the dataset as a table
    % Use this method to save the object to storage in the specified format.
    %
    % For example:
    %
    %   outputLocation = '/delta/sampletable';
    %   DS.write.format("delta")...
    %               .option("path", outputLocation)...
    %               .saveAsTable("testTableName");
    %


    % Copyright 2021 MathWorks, Inc.

    obj.dataFrameWriter.saveAsTable(tableName);

end %function
