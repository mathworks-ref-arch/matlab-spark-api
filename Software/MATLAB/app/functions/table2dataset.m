function ds = table2dataset( T, spark, schema )
    % TABLE2DATASET Function to create Spark dataset from MATLAB table
    %
    % This is a helper function for compiler.matlab.mlspark.Dataset/table.
    % It takes as arguments a MATLAB table, the spark session reference, and
    % an optional schema object, and converts the table into a Dataset object.
    %
    % This function should be used for tests, not for large tables.
    %
    % To use it, at least a table and a spark session are needed:
    %
    %   dataset = table2dataset(matlabTable, sparkSession);
    %
    % When the optional third input argument (schema) is not provided, the
    % Column data types are automatically mapped as follows (also see the 
    % createSparkSchemaFromMatlabType in the functions folder):
    %
    %   MATLAB            Spark     Notes
    %   ======            ======    =====
    %   char              String    converting back to MATLAB results in string, not char
    %   string            String    <missing> value interpreted as the String \0
    %   double            Double
    %   single            Float
    %   int8              Byte
    %   int16             Short
    %   int32             Integer
    %   int64             Long
    %   logical           Boolean
    %   struct            Struct
    %   table             Struct    converting back to MATLAB results in struct, not table
    %   containers.Map    Map
    %   cell              WrappedArray
    %   datetime          Timestamp
    %   duration          CalendarInterval
    %   (any other type)  *** NOT SUPPORTED ***
    %
    % An optional third argument (schema) can also be specified. This is useful
    % when a schema object is already available, for example the schema of a
    % pre-existing Spark dataset.
    %
    %   dataset = spark.read.format("parquet").load("/my/files")
    %   T = dataset2table(dataset);
    %   T = runAlgorithm(T);
    %   schema = dataset.schema;
    %   dataset = table2dataset(matlabTable, sparkSession, schema);
    %
    % The optional schema argument can also be specified as a cell-array of
    % chars or a string array, representing case-insensitive column data types.
    % Only the following basic data types are supported:
    %
    %   string or char, double, single or float, int8 or byte, int16 or short,
    %   int32 or int or integer, int64 or long, logical or boolean, duration,
    %   datetime or timestamp.
    %
    % Note: this list does not include complex data types such as struct, map,
    % or table. If your data contains such data types, either use the 2-inputs
    % variant of this function in order to auto-generate the schema, or use a
    % schema-object from a pre-existing dataset object.
    %
    % See also: dataset2table, table2dataframe

    % TODO: implement & use MATLAB schema wrapper class

    % Copyright 2020-2021 MathWorks, Inc.

    if nargin < 2
        jSparkSession = org.apache.spark.sql.SparkSession.getActiveSession.get;
    else
        jSparkSession = spark.sparkSession;
    end
    if nargin < 3
        schema = createSparkSchemaFromMatlabType(T);
    elseif ~isjava(schema)
        schema = interpretSchema(schema);
    end

    % Convert the MATLAB table values into Java items, based on the schema
    % (this has separate exception handling, so not part of the try-catch below)
    values = createTableValue(T, schema);
    % values = createStructValueSchema(S, true);

    try
        % Create a new Spark dataset object
        rowList = java.util.Arrays.asList(values);
        sqlCtx = jSparkSession.sqlContext;
        jds = sqlCtx.createDataFrame(rowList, schema);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

    % Wrap the Spark dataset object in a MATLAB wrapper class
    ds = matlab.compiler.mlspark.Dataset(jds);
end

function value = createTableValue(T, schema)
    % TODO: We don't need to go past the struct to do this
    %TInfo = collectTableInfo(T);
    %N = width(T);
    %H = height(T);
    
    S = table2struct(T);
    value = createStructValue(S, schema, true);
end

function value = createValue(S, schema)
    if nargin < 2  % schema was not specified, so create it from the data value
         schema = createSparkSchemaFromMatlabType(S);
    end
    typeName = char(schema.typeName);
    
    if strcmp(typeName,'array')
        if iscell(S)
            %value = createGenericRows(S, schema.elementType, false);
            value = createWrappedRows(S);
        else
            value = createValue(S, schema.elementType);
        end
    else
        javaType = regexprep(typeName, '\(.*', '');
        javaType = regexprep(javaType, '.*\.', '');
        switch lower(javaType)
            case 'string'
                JT = 'java.lang.String';
                % schema = org.apache.spark.sql.types.DataTypes.StringType;
                value = createJavaValue(string(S), JT);
            case 'double'
                JT = 'java.lang.Double';
                % schema = org.apache.spark.sql.types.DataTypes.DoubleType;
                value = createJavaValue(S, JT);
            case 'float'
                JT = 'java.lang.Float';
                % schema = org.apache.spark.sql.types.DataTypes.FloatType;
                value = createJavaValue(S, JT);
            case 'byte'
                JT = 'java.lang.Byte';
                % schema = org.apache.spark.sql.types.DataTypes.ByteType;
                value = createJavaValue(S, JT);
            case 'short'
                JT = 'java.lang.Short';
                % schema = org.apache.spark.sql.types.DataTypes.ShortType;
                value = createJavaValue(S, JT);
            case 'integer'
                JT = 'java.lang.Integer';
                % schema = org.apache.spark.sql.types.DataTypes.IntegerType;
                value = createJavaValue(S, JT);
            case 'long'
                JT = 'java.lang.Long';
                % schema = org.apache.spark.sql.types.DataTypes.LongType;
                value = createJavaValue(S, JT);
            case 'boolean'
                JT = 'java.lang.Boolean';
                % schema = org.apache.spark.sql.types.DataTypes.BooleanType;
                value = createJavaValue(S, JT);
            case 'timestamp'
                JT = 'java.sql.Timestamp';
                % schema = org.apache.spark.sql.types.DataTypes.TimestampType;
                value = createJavaValue(S, JT);
            case 'struct'
                value = createStructValue(S, schema, false);
            case 'map'
                value = createMapValue(S, schema);
            % case 'binary'
                % value = createBinaryValue(S);
            case {'interval','calendarinterval'}
                % schema = org.apache.spark.sql.types.DataTypes.CalendarIntervalType
                % TODO: support calanderDuration
                try
                    secs = seconds(S);
                    if isa(secs,'duration'), secs = seconds(secs); end
                catch
                    error('SPARK:ERROR', 'Input data of type "%s" is not a MATLAB duration value', class(S))
                end
                usecs = 1e6 * secs;  % CalendarInterval expects microsecs input
                value = org.apache.spark.unsafe.types.CalendarInterval(0,0,usecs);
            case 'decimal'
                value = org.apache.spark.sql.types.Decimal.apply(S);
            case 'null'
                value = NaN;
            otherwise
                error('SPARK:ERROR', 'MATLAB datatype "%s" cannot be converted into a Java "%s"', class(S), javaType);
        end
    end
end

function value = createStructValue(S, schema, isTopLevel)
    if iscell(S)
        rows = createRows(S);
    else
        numElems = size(S,1);
        fieldNames = fieldnames(S);
        if isa(S,'table')
            fieldNames = S.Properties.VariableNames;
            numElems = 1;
        end
        numFields = numel(fieldNames);
        value = cell(numElems, numFields);
        try
            schemaFields = schema.fields;
        catch  % schema is not a Java object but rather an emulation struct
            if isa(S,'table')
                T = S;
            else
                T = struct2table(S);
            end
            TInfo = collectTableInfo(T);
            schemaFields = TInfo.Fields;
        end
        numSchemaFields = length(schemaFields);
        if numFields > numSchemaFields
            error('SPARK:ERROR', 'Data table has %d fields but only %d field(s) are defined in the schema', numFields, numSchemaFields);
        end

        % arr = javaArray('org.apache.spark.sql.types.StructField', numFields);
        for fieldIdx = 1 : numFields
            fieldName = fieldNames{fieldIdx};
            try
                %isArray = isArrayType({S.(fieldName)});
                schemaField = schemaFields(fieldIdx);
                schemaDataType = schemaField.dataType;
                for arrIdx = 1 : numElems
                    if numElems == 1
                        thisItem = S;  % required since table indexing is not supported
                    else
                        thisItem = S(arrIdx);
                    end
                    matlabData = thisItem.(fieldName);
                    value{arrIdx, fieldIdx} = matlabData;
                end
                %{
                %         if isArray
                %             arraySchema = org.apache.spark.sql.types.DataTypes.createArrayType(schemaField);
                %             arr(fieldIdx) =  org.apache.spark.sql.types.DataTypes.createStructField( ...
                %                 fieldName, arraySchema, false);
                %         else
                %             arr(fieldIdx) =  org.apache.spark.sql.types.DataTypes.createStructField( ...
                %                 fieldName, schemaField, false);
                %         end
                %}
            catch err
                error('SPARK:ERROR', ...
                      'Cannot create Java values with schema data type "%s" from data field #%d ("%s", data type %s): %s', ...
                      string(schemaDataType), fieldIdx, fieldName, class(matlabData), ...
                      stripJavaError(err.message));
            end
        end
        %schema = org.apache.spark.sql.types.DataTypes.createStructType(arr);

        rows = createGenericRows(value, schema, isTopLevel);
    end

    if ~isTopLevel
        if numel(rows) == 1
            rows = rows(1);
        end
    end
    value = rows;
end

function value = createMapValue(S, schema)
    %numEntries = S.Count;
    values = cell2mat(S.values); %values must have the same data-type in Spark!
    
    % It's assumed here that the keys are not structs or maps. This may
    % have to be added at some point.
    javaKeys   = createValue(S.keys, schema.keyType);
    javaValues = createValue(values, schema.valueType);
    
    value = com.mathworks.scala.SparkUtilityHelper.createScalaHashMap(javaKeys, javaValues);
end

function value = createBinaryValue(S)
    numElems = numel(S);
    value = javaArray('java.lang.Byte', numElems);
    for k=1:numElems
        value(k) = java.lang.Byte(S(k));
    end
end

function schema = createSchema(TInfo)
    N = TInfo.NumCols;
    arr = javaArray('org.apache.spark.sql.types.StructField', N);
    for k=1:N
        if TInfo.Fields(k).IsArray
            arr(k) =  org.apache.spark.sql.types.DataTypes.createStructField( ...
                TInfo.Fields(k).Name, TInfo.Fields(k).SparkArrayType, false);
        else
            arr(k) =  org.apache.spark.sql.types.DataTypes.createStructField( ...
                TInfo.Fields(k).Name, TInfo.Fields(k).SparkType, false);
        end
    end
    schema = org.apache.spark.sql.types.DataTypes.createStructType(arr);
end

function javaValue = createJavaValue(V, javaType)
    switch javaType
        case 'java.sql.Timestamp'
            V = posixtime(V) * 1000;  % Timestamp expects millisecs; posixtime returns secs
        otherwise
    end
    if numel(V) > 1 || iscell(V)
        if iscell(V)
            try
                V = [V{:}];
            catch
                V = V{1};
            end
        end
        JA = javaArray(javaType, numel(V));
        for el=1:numel(V)
            JA(el) = javaObject(javaType, V(el));
        end
        javaValue = JA;
    elseif isempty(V)
        % This must be caught later for conversions
        javaValue = [];
    else
        if ismissing(V), V = NaN; end % convert <missing>,<undefined>,NaT => NaN
        javaValue = javaObject(javaType, V);
    end
end

function rows = createWrappedRows(values)
    [numRows, numCols] = size(values); %#ok<ASGLU>
    rows = javaArray('scala.collection.mutable.WrappedArray$ofRef', numRows);
    for rowIdx = 1 : numRows
        rowData = values(rowIdx,:);
        rows(rowIdx) = javaObject('scala.collection.mutable.WrappedArray$ofRef', rowData);
        % the following is only used in case we want to wrap each cell element seperately
        %{
        cols = javaArray('scala.collection.mutable.WrappedArray$ofRef', numCols);
        for colIdx = 1 : numCols
            cols(colIdx) = javaObject('scala.collection.mutable.WrappedArray$ofRef', rowData{colIdx});
        end
        rows(rowIdx) = javaObject('scala.collection.mutable.WrappedArray$ofRef', cols);
        %}
    end
end

function rows = createGenericRows(values, schema, isTopLevel)
    [numRows, numFields] = size(values);
    forceGenericRow = isTopLevel;
    items = cell(numRows,1);
    for rowIdx = 1 : numRows
        try
            arr = javaArray('java.lang.Object', numFields);
            for fieldIdx = 1 : numFields
                mValue = values{rowIdx, fieldIdx};
                try
                    arr(fieldIdx) = mValue;
                catch
                    arr(fieldIdx) = createValue(mValue);
                end
            end
        catch
            %rowData = values(rowIdx,:);
            %arr = createValue(rowData, schema);
            %forceGenericRow = true;
            rows = createRows(values);
            return
        end
        items{rowIdx} = arr;
    end

    if forceGenericRow
        rows = javaArray('org.apache.spark.sql.catalyst.expressions.GenericRow', numRows);
    else
        rows = javaArray('org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema', numRows);
    end
    for rowIdx = 1 : numRows
        arr = items{rowIdx};
        if forceGenericRow
            rows(rowIdx) = org.apache.spark.sql.RowFactory.create(arr);
        else
            rows(rowIdx) = javaObject('org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema', arr, schema);
        end
    end
end

function rows = createRows(T, TInfo)
    if nargin < 2
        if iscell(T), T = cell2table(T); end
        TInfo = collectTableInfo(T);
    end
    H = TInfo.NumRows;
    rows = javaArray('org.apache.spark.sql.catalyst.expressions.GenericRow', H);
    for rowIdx = 1:H
        rows(rowIdx) = createRow(T, rowIdx, TInfo);
    end
end
function row = createRow(T, rowIdx, TInfo)
    N = TInfo.NumCols;
    arr = javaArray('java.lang.Object', N);
    for colIdx = 1:N
        JT = TInfo.Fields(colIdx).JavaType;
        V = T{rowIdx,colIdx};
        switch JT
            case 'java.sql.Timestamp'
                V = posixtime(V) * 1000;  % Timestamp expects millisecs; posixtime returns secs
            otherwise
        end
        if ~istable(V) && (numel(V) > 1 || iscell(V))
            if iscell(V)
                V = V{1};
            end
            numelV = numel(V);
            if iscell(V)
                arr(colIdx) = getJavaValue('array',V);
            elseif ischar(V) || isstring(V)
                arr(colIdx) = getJavaValue('string',V);
            else
                JA = javaArray(JT, numel(V));
                if numelV > 1
                    for el = 1 : numel(V)
                        JA(el) = getJavaValue(JT, V(el));
                    end
                elseif numelV == 1  % ignore the ==0 case
                    JA = getJavaValue(JT, V);
                end
                arr(colIdx) = JA;
            end
        else
            arr(colIdx) = getJavaValue(JT, V);
        end
    end
    row = org.apache.spark.sql.RowFactory.create(arr);
end
function jValue = getJavaValue(javaType, mValue)
    try
        jValue = javaObject(javaType, mValue);
    catch
        jValue = createValue(mValue);
    end
end

function TInfo = collectTableInfo(T)
    % collectTableInfo Collect all type and size info needed for conversion
    
    TInfo.NumCols = width(T);
    TInfo.NumRows = height(T);
    TInfo.FieldNames = T.Properties.VariableNames;
    
    for k = 1 : TInfo.NumCols
        colVal = T{:,k};
        if iscell(colVal)
            innerTypes = cellfun(@(x) class(x), colVal, 'UniformOutput', false);
            if length(unique(innerTypes)) > 1
                error('SPARK:ERROR', 'Non-uniform cell data types in column');
            end
            mlType = class(colVal{1});
        else
            mlType = class(colVal);
        end

        [javaType, sparkType] = getJavaType(colVal, mlType);
        isArray = isArrayType(colVal);
        if isArray
            sparkArrayType = org.apache.spark.sql.types.DataTypes.createArrayType(sparkType);
        else
            sparkArrayType = [];
        end
        TInfo.Fields(k) = struct(...
            'Name',           TInfo.FieldNames{k}, ...
            'MATLABType',     mlType, ...
            'JavaType',       javaType, ...
            'SparkType',      sparkType, ...
            'dataType',       sparkType, ...
            'IsArray',        isArray, ...
            'SparkArrayType', sparkArrayType);
    end
end

function IA = isArrayType(V)
    if iscell(V)
        IA = any(cellfun(@getArrayLength, V)>1);
    else
        IA = size(V,2) > 1;
        %{
        IA = false;
        for k=1:size(V, 1)
            if length(V(k, :)) > 1
                IA = true;
                break;
            end
        end
        %}
    end
end

function len = getArrayLength(V)
    if ischar(V)
        len = size(V,1);
    else
        len = numel(V);
    end
end

function IA = isArrayTypeTable(T,idx)
    V = T{:,idx};
    if iscell(V)
        IA = any(cellfun(@numel, V)>1);
    else
        IA = false;
        for k=1:height(T)
            if length(T{k, idx}) > 1
                IA = true;
                break;
            end
        end
    end
end

function [JT, ST] = getJavaType(T, mlType)
    [ST, JT] = createSparkSchemaFromMatlabType(T);
    %{
    switch mlType
        case {'string', 'char'}
            JT = 'java.lang.String';
            ST = org.apache.spark.sql.types.DataTypes.StringType;
        case 'double'
            JT = 'java.lang.Double';
            ST = org.apache.spark.sql.types.DataTypes.DoubleType;
        case 'single'
            JT = 'java.lang.Float';
            ST = org.apache.spark.sql.types.DataTypes.FloatType;
        case 'int8'
            JT = 'java.lang.Byte';
            ST = org.apache.spark.sql.types.DataTypes.ByteType;
        case 'int16'
            JT = 'java.lang.Short';
            ST = org.apache.spark.sql.types.DataTypes.ShortType;
        case 'int32'
            JT = 'java.lang.Integer';
            ST = org.apache.spark.sql.types.DataTypes.IntegerType;
        case 'int64'
            JT = 'java.lang.Long';
            ST = org.apache.spark.sql.types.DataTypes.LongType;
        case 'logical'
            JT = 'java.lang.Boolean';
            ST = org.apache.spark.sql.types.DataTypes.BooleanType;
        case 'datetime'
            JT = 'java.sql.Timestamp';
            ST = org.apache.spark.sql.types.DataTypes.TimestampType;
        case 'struct'
            JT = 'java.lang.Object';
            ST = createSparkSchemaFromMatlabType(T);
            %             ST = getSparkStructType(T{:,k});
        otherwise
            %error('SPARK:ERROR', 'Datatype not supported for Java conversion. "%s"', mlType);
            JT = 'java.lang.Object';
            ST = createSparkSchemaFromMatlabType(T);
    end
    %}
end

function schema = interpretSchema(schema)
    % TODO: support MATLAB schema wrapper class
    try
        colTypes = string(schema);
    catch
        error('SPARK:ERROR', 'Bad schema input specified: must be a schema object or string array of column data types')
    end
    isNullable = false; % all columns are not nullable in this variant - TODO
    numFields = length(colTypes);
    arr = javaArray('org.apache.spark.sql.types.StructField', numFields);
    dataTypesObj = org.apache.spark.sql.types.DataTypes;
    for fieldIdx = 1 : numFields
        fieldName = "Field" + fieldIdx;
        sparkDataType = getSparkDataTypeFor(colTypes{fieldIdx});
        arr(fieldIdx) = dataTypesObj.createStructField(fieldName, sparkDataType, isNullable);
    end
    schema = org.apache.spark.sql.types.DataTypes.createStructType(arr);
end

function sparkDataType = getSparkDataTypeFor(dataType)
    switch lower(dataType)
        case {"string",   "char"},           sparkType = "String";
        case {"double",   "decimal"},        sparkType = "Double";
        case {"single",   "float"},          sparkType = "Float";
        case {"int8",     "byte"},           sparkType = "Byte";
        case {"int16",    "short"},          sparkType = "Short";
        case {"int32",    "integer", "int"}, sparkType = "Integer";
        case {"int64",    "long"},           sparkType = "Long";
        case {"logical",  "boolean"},        sparkType = "Boolean";
        case {"duration", "interval"},       sparkType = "CalendarInterval";
        case {"datetime", "timestamp", "date", "time"}, sparkType = "Timestamp";
        otherwise
            error('SPARK:ERROR', 'Bad schema data type specified: %s', dataType)
    end
    sparkDataType = org.apache.spark.sql.types.DataTypes.(sparkType + "Type");
end
