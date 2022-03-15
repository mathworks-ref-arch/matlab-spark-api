function col = trim(inCol, trimChars)
    % TRIM  Trim both ends for the specified string column.
    %
    % trim(inCol) trims spaces from both ends of the input column string values.
    %
    % trim(inCol,chars) trims the specified CHARS from both ends of the string
    % values in the input column. CHARS can be a char array, string or cellstr.
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     dtc = DS.col("x_loc")
    %     % Trim spaces from both ends of the input strings
    %     mc = trim(dtc)
    %     % Trim the characters 'A','T' and/or 'x' from both ends of the strings
    %     mc = trim(dtc,'ATx')

    % Copyright 2021-2022 MathWorks, Inc.

    try
        try inCol = inCol.column; catch, end  % col may be a column name or object
        if nargin < 2
            jcol = org.apache.spark.sql.functions.trim(inCol);
        else
            try trimChars = [trimChars{:}]; catch, end  % cellstr => char array
            jcol = org.apache.spark.sql.functions.trim(inCol,trimChars);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
            'The Spark %s function only supports an argument that is a matlab.compiler.mlspark.Column object or a column name', ...
            mfilename);
    end
end
