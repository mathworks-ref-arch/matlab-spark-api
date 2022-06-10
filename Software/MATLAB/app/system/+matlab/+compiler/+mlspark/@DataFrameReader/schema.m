function obj = schema(obj, schemaInfo)
    % SCHEMA Specify the schema to be used when loading data.
    %
    % For example, to indicate that the input CSV has a header lines and is
    % clean enough to infer the schema:
    %
    %     myDataSet = spark...
    %         .read.format('json')...
    %         .schema("`time` TIMESTAMP, `action` STRING") ...
    %         .load(inputLocation);

    % Copyright 2022 MathWorks, Inc.

    obj.dataFrameReader.schema(schemaInfo);

end %function
