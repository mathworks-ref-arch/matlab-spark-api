function ds = table2dataframe( T, spark )
    % table2dataframe Function to create Spark dataset from MATLAB table
    %
    % This should be used for tests, not for large tables.
    
    % Copyright 2021 MathWorks, Inc.
    
    S = table2struct(T);
    [schema,values] = createStructValueSchema(S, true);
        
    rowList = java.util.Arrays.asList(values);
    
    
    sqlCtx=spark.sparkSession.sqlContext;
    
    jds = sqlCtx.createDataFrame(rowList, schema);
    
    ds = matlab.compiler.mlspark.Dataset(jds);
    
end

function [schema, value] = createValueSchema(S)
    switch class(S)
        case {'string', 'char'}
            JT = 'java.lang.String';
            schema = org.apache.spark.sql.types.DataTypes.StringType;
            value = createJavaValue(string(S), JT);
        case 'double'
            JT = 'java.lang.Double';
            schema = org.apache.spark.sql.types.DataTypes.DoubleType;
            value = createJavaValue(S, JT);
        case 'single'
            JT = 'java.lang.Float';
            schema = org.apache.spark.sql.types.DataTypes.FloatType;
            value = createJavaValue(S, JT);
        case 'int8'
            JT = 'java.lang.Byte';
            schema = org.apache.spark.sql.types.DataTypes.ByteType;
            value = createJavaValue(S, JT);
        case 'int16'
            JT = 'java.lang.Short';
            schema = org.apache.spark.sql.types.DataTypes.ShortType;
            value = createJavaValue(S, JT);
        case 'int32'
            JT = 'java.lang.Integer';
            schema = org.apache.spark.sql.types.DataTypes.IntegerType;
            value = createJavaValue(S, JT);
        case 'int64'
            JT = 'java.lang.Long';
            schema = org.apache.spark.sql.types.DataTypes.LongType;
            value = createJavaValue(S, JT);
        case 'logical'
            JT = 'java.lang.Boolean';
            schema = org.apache.spark.sql.types.DataTypes.BooleanType;
            value = createJavaValue(S, JT);
        case 'datetime'
            JT = 'java.sql.Timestamp';
            schema = org.apache.spark.sql.types.DataTypes.TimestampType;
            value = createJavaValue(S, JT);
        case 'struct'
            [schema, value] = createStructValueSchema(S, false);
        otherwise
            error('SPARK:ERROR', 'Datatype not supported for Java conversion. "%s"', class(S));
    end       
end

function [schema, value] = createStructValueSchema(S, isTopLevel)
    fieldNames = fieldnames(S);
    numFields = numel(fieldNames);
    numElems = numel(S);
    value = cell(numElems, numFields);
    arr = javaArray('org.apache.spark.sql.types.StructField', numFields);    
    for fieldIdx=1:numFields
        fieldName = fieldNames{fieldIdx};
        isArray = isArrayType({S.(fieldName)});

        for arrIdx = 1:numElems
            [schemaField, valueField] = createValueSchema(S(arrIdx).(fieldName));
            value{arrIdx, fieldIdx} = valueField;
        end
        if isArray
            arraySchema = org.apache.spark.sql.types.DataTypes.createArrayType(schemaField);
            arr(fieldIdx) =  org.apache.spark.sql.types.DataTypes.createStructField( ...
                fieldName, arraySchema, false);
        else
            arr(fieldIdx) =  org.apache.spark.sql.types.DataTypes.createStructField( ...
                fieldName, schemaField, false);
        end        
    end
    schema = org.apache.spark.sql.types.DataTypes.createStructType(arr);
    
    rows = createGenericRows(schema, value, isTopLevel);
    
    if ~isTopLevel
        schema = rows(1).schema;
        if numel(rows) == 1
            rows = rows(1);
        end
    end
    value = rows;

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
            V = V{1};
        end
        JA = javaArray(javaType, numel(V));
        for el=1:numel(V)
            JA(el) = javaObject(javaType, V(el));
        end
        javaValue = JA;
    else
        javaValue = javaObject(javaType, V);
    end
end

function rows = createGenericRows(schema, values, isTopLevel)
    [numRows, numFields] = size(values);
    if isTopLevel
        rows = javaArray('org.apache.spark.sql.catalyst.expressions.GenericRow', numRows);
    else
        rows = javaArray('org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema', numRows);
    end
    for rowIdx = 1:numRows
        arr = javaArray('java.lang.Object', numFields);
        for fieldIdx = 1:numFields
            arr(fieldIdx) = values{rowIdx, fieldIdx};
        end
        
        if isTopLevel
            rows(rowIdx) = org.apache.spark.sql.RowFactory.create(arr);
        else
            rows(rowIdx) = javaObject('org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema', arr, schema);
        end
    end
    
end

function rows = createRows(T, TInfo)
    H = TInfo.NumRows;
    rows = javaArray('org.apache.spark.sql.catalyst.expressions.GenericRow', H);
    for rowIdx = 1:H
        rows(rowIdx) = createRow(T, rowIdx, TInfo);
    end
    
end
function row = createRow(T, rowIdx, TInfo)
    N = TInfo.NumCols;
    arr=javaArray('java.lang.Object', N);
    for colIdx = 1:N
        JT = TInfo.Fields(colIdx).JavaType;
        V = T{rowIdx,colIdx};
        switch JT
            case 'java.sql.Timestamp'
                V = posixtime(V) * 1000;  % Timestamp expects millisecs; posixtime returns secs
            otherwise
        end
        if numel(V) > 1 || iscell(V)
            if iscell(V)
                V = V{1};
            end
            JA = javaArray(JT, numel(V));
            for el=1:numel(V)
                JA(el) = javaObject(JT, V(el));
            end
            arr(colIdx) = JA;
        else
            arr(colIdx) = javaObject(JT, V);
        end
    end
    row = org.apache.spark.sql.RowFactory.create(arr);
    
end


function TInfo = collectTableInfo(T)
    % collectTableInfo Collect all type and size info needed for conversion
    
    TInfo.NumCols = width(T);
    TInfo.NumRows = height(T);
    TInfo.FieldNames = T.Properties.VariableNames;
    
    for k=1:TInfo.NumCols
        
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
        
        [javaType, sparkType] = getJavaType(mlType, T, k);
        isArray = isArrayType(T, k);
        if isArray
            sparkArrayType = org.apache.spark.sql.types.DataTypes.createArrayType(sparkType);
        else
            sparkArrayType = [];
        end
        TInfo.Fields(k) = struct(...
            'Name', TInfo.FieldNames{k}, ...
            'MATLABType', mlType, ...
            'JavaType', javaType, ...
            'SparkType', sparkType, ...
            'IsArray', isArray, ...
            'SparkArrayType', sparkArrayType);
    end
end

function IA = isArrayType(V)
    if iscell(V)
        IA = any(cellfun(@getArrayLength, V)>1);
    else
        IA = false;
        for k=1:size(V, 1)
            if length(V(k, :)) > 1
                IA = true;
                break;
            end
        end
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

function [JT, ST] = getJavaType(mlType, T, k)
    
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
            ST = getSparkStructType(T{:,k});
        otherwise
            error('SPARK:ERROR', 'Datatype not supported for Java conversion. "%s"', mlType);
    end
end

function ST = getSparkStructType(V)
      
end
