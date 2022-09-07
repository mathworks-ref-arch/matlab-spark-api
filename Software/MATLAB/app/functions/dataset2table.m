function T = dataset2table( ds )
    % dataset2table Convert a Spark Dataset to a MATLAB Table
    %
    % Converts a Spark Dataset to a MATLAB Table
    %
    % This is a helper function for compiler.matlab.mlspark.Dataset/table.
    % It takes an argument of type org.apache.spark.sql.Dataset and
    % converts this to a MATLAB table.
    %
    % This function should be used for tests, not for large tables.
    %
    % Column data types are automatically mapped as follows:
    %
    %   Spark             MATLAB     Notes
    %   =====             ======     =====
    %   String            string
    %   Char              string     converted into a MATLAB string, not char
    %   Varchar           string     converted into a MATLAB string, not char
    %   Double            double
    %   Decimal           double     possible precision loss
    %   Float             single
    %   Byte              int8
    %   Binary            int8 array
    %   Short             int16
    %   Integer           int32
    %   Long              int64
    %   Boolean           logical
    %   Struct            struct
    %   Map               containers.Map
    %   WrappedArray      cell array
    %   Timestamp         datetime
    %   CalendarInterval  duration
    %   (any other type)  *** NOT SUPPORTED ***
    %
    % null values are set to either missing or NaN, depending on the data type.
    % 
    % This function can be used directly, but it is recommended to use the
    % table method of the Dataset object, e.g.
    %
    %   % spark is a spark session
    %   outages = spark.read.format('csv')...
    %        .option('header','true')...
    %        .option('inferSchema','true')...
    %        .load(addFileProtocol(which('outages.csv')));
    %
    %   T = table(outages.limit(10));
    %
    % See also: table2dataset, table2dataframe

    % Copyright 2020-2021 MathWorks, Inc.

    try
        try
            % Try to use the faster mechanism first
            T = getMatlabTableFromDataset2(ds);
        catch ex
           % Revert to the original (slower) mechanism
            T = getMatlabTableFromDataset(ds);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
end

function T = getMatlabTableFromDataset(ds)  % Original MW implementation
    if isa(ds, 'matlab.compiler.mlspark.Dataset')
        JD = com.mathworks.scala.SparkUtilityHelper.convertDatasetToData(ensureDatasetIsDataframe(ds.dataset));
    elseif isjava(ds) && isa(ds, 'org.apache.spark.sql.Dataset')
        JD = com.mathworks.scala.SparkUtilityHelper.convertDatasetToData(ensureDatasetIsDataframe(ds));
    else
        error('SPARK:ERROR', 'This function can only be called with a Spark Dataset, or the MATLAB wrapper thereof');
    end

    MD.typeNames = string(JD.typeNames);
    MD.fieldNames = string(JD.fieldNames);
    MD.numRows = JD.numRows;
    MD.numCols = numel(MD.fieldNames);
    c = getTableColumns(JD, MD);

    T = cell2table( c, 'VariableNames', MD.fieldNames);
end

function T = getMatlabTableFromDataset2(ds)  % New (optimized) implementation
    jDS = ds;
    try jDS = ds.dataset; catch, end
    colNames = cell(jDS.columns);
    dsRows = jDS.toDF.collect;
    numRows = length(dsRows);
    numCols = length(colNames);
    dsRowsData = arrayfun(@values,dsRows,'UniformOutput',0);
    dsCells  = reshape(cell([dsRowsData{:}]),numCols,numRows)';
    %{
    % this is a bit slower than the reshape() method above
    dsCells = cell(cell2mat(dsRowsData));
    % ..and this is even slower...
    dsCells = cell(numRows, numCols);
    for rowIdx = numRows : -1 : 1
        dsCells(rowIdx,:) = cell(dsRows(rowIdx).values)';
    end
    %}

    % Modify the cell elements based on the various Java data types
    if ~isempty(dsCells)
        dsFields = dsRows(1).schema.fields;
        for colIdx = 1 : numCols
            colData = dsCells(:,colIdx);
            %colName = colNames{colIdx};
            emptyIdx = cellfun('isempty',colData);
            colType = dsFields(colIdx).dataType;
            colTypeName = char(colType.typeName);
            switch lower(regexprep(colTypeName,'\(.*',''))
                % see https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/types/package-frame.html
                case {'string','char','varchar'}
                    try
                        colData = num2cell(string(colData));
                    catch
                        colData = cellfun(@string,colData,'uniform',0);
                    end
                    % Missing Java strings are sometimes represented by null
                    % and sometimes by \0, so we need to capture both cases
                    emptyIdx = cellfun(@(s)isempty(s)||s==string(char(0)), colData);
                case 'double'
                    % Do nothing - double/boolean/binary data is auto-converted correctly
                    %if ~any(emptyIdx), continue, end
                case {'single','float'}
                    colData = cellfun(@single, colData, 'uniform',0);
                case {'integer','long','short','byte'}
                    colTypeSize = colType.defaultSize;
                    switch colTypeSize
                        case 8, func = @int64;  % long
                        case 4, func = @int32;  % int
                        case 2, func = @int16;  % short
                        case 1, func = @int8;   % byte
                        otherwise, func = [];
                    end
                    if ~isempty(func)
                        colData = cellfun(func, colData, 'uniform',0);
                    end
                case {'date','timestamp','interval','calendarinterval','decimal'}
                    %colData= cellfun(@(d)datetime(char(d)),colData,'uniform',0);
                    colData = cellfun(@javaItemToMatlabItem,colData,'uniform',0);
                case 'array'
                    try
                        % Try sorting this out with normal MATLAB
                        % conversions. Default to other method if needed.
                        elemType = string(colType.elementType);
                        elemMapping = matlab.sparkutils.datatypeMapper('spark', elemType);
                        elemMATLABType = elemMapping.MATLABType;
                        convFun = str2func(elemMATLABType);
                        colData = cellfun(@(x) convFun(x.array), colData, 'UniformOutput',false);
                    catch
                        colData = cellfun(@javaArrayToMatlabArray2,colData,'uniform',0);
                    end
                case 'vector'
                    colData = cellfun(@(x) x.toArray,colData,'uniform',0);
                case 'struct'
                    colData = cellfun(@javaStructToMatlabStruct2,colData,'uniform',0);
                case {'binary','boolean'}
                    % Do nothing: these are auto-converted from Java -> MATLAB
                case 'map'
                    colData = cellfun(@javaMapToMatlabMap2,colData,'uniform',0);
                otherwise  % null,object
                    % Do nothing: keep the Java values as-is in the output table
            end
            if any(emptyIdx)
                try
                    colData(emptyIdx) = {missing};
                catch
                    colData(emptyIdx) = {NaN};  % converted to 0 for int types
                end
            end

            % Ensure that all table items are row vectors, not column vectors
            % (TODO: actually, not sure if we really want to do this...)
            %colData = reshape([colData{:}],[],numRows)';
            for rowIdx = 1 : numRows
                item = colData{rowIdx};
                if ~isempty(item) && ~isscalar(item) && iscolumn(item)
                    colData{rowIdx} = item';
                end
            end

            % Assign the possibly-modified column back into the cell array 
            % that will be used to create the table (following the loop, below)
            dsCells(:,colIdx) = colData;
        end
    end

    % Finally, create the table from the modified 2D cell array
    T = cell2table(dsCells, 'VariableNames',colNames);
end

function item = javaArrayToMatlabArray2(item)
    % Convert the [possibly multi-] wrapped Java array into a Matlab cell array
    item = javaArrayToMatlabArray2b(item);

    % Try to rearrange the 1D or 2D cell array according to original orientation
    try
        item = num2cell(cell2mat(item));
    catch
        try item = reshape([item{:}], size(item)); catch, end
    end
end
function item = javaArrayToMatlabArray2b(item)
    if isa(item,'scala.collection.mutable.WrappedArray$ofRef')  % TODO handle other array types
        item = cellfun(@javaItemToMatlabItem, cell(item.array), 'uniform',0);
    end
end

function item = javaStructToMatlabStruct2(item)
    if isa(item,'org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema')  % TODO handle other struct types
        fieldVals = cellfun(@javaItemToMatlabItem, cell(item.values), 'uniform',0);
        fieldNames = cell(item.schema.fieldNames);
        item = cell2struct(fieldVals, fieldNames);
    end
end

function item = javaMapToMatlabMap2(item) %supports all java.util.Map subclasses
    try
        if getSparkMajorVersion < 3
            tmpKeys = item.keys.toIndexedSeq;
            tmpVals = item.values.toIndexedSeq;
            N = item.size;
            mKeys = cell(1, N);
            mVals = cell(1, N);
            for k=1:N
                mKeys{k} = tmpKeys.apply(k-1);
                mVals{k} = tmpVals.apply(k-1);
            end
        else
            mKeys = cell(item.keySet.toArray);
            mVals = cell(item.values.toArray);
        end
    catch  % a scala.collection.* map object
        mKeys = cell(item.keySet.toArray(scala.reflect.ClassTag.AnyRef));
        mVals = cell(item.values.toArray(scala.reflect.ClassTag.AnyRef));
    end
    mVals = cellfun(@javaItemToMatlabItem, mVals, 'uniform',0);
    item = containers.Map(mKeys, mVals);
end

function item = javaItemToMatlabItem(item)
    if isjava(item)
        switch class(item)
            case 'java.sql.Date'
                %item = datetime(char(item.toString)); %this is relatively slow
                item = datetime(item.getYear+1900, item.getMonth+1, item.getDate);
            case 'java.util.Date'
                %item = datetime(char(item.toString));  % this croaks!
                item = datetime(item.getYear+1900, item.getMonth+1, item.getDate,...
                                item.getHours, item.getMinutes, item.getSeconds);
                % no sub-second information readily available in java.util.Date
            case 'java.sql.Timestamp'
                %item = datetime(char(item.toString)); %this is relatively slow
                item = datetime(item.getYear+1900, item.getMonth+1, ...
                                item.getDate,     item.getHours, ...
                                item.getMinutes + item.getTimezoneOffset, ...
                                item.getSeconds + item.getNanos/1e9);
            case 'java.time.Period'
                item = days(item.getDays);  % a duration object
            case 'java.time.Duration'
                item = duration(0,0,item.getSeconds);
            case 'org.apache.spark.unsafe.types.CalendarInterval'
                item = duration(0,0,item.microseconds/1e6);
            case 'org.apache.spark.sql.types.Decimal'
                item = item.toDouble;
            case 'java.math.BigDecimal'
                item = item.doubleValue;
            case 'java.util.ArrayList'
                item = getInnerArray(item);
            case 'scala.collection.mutable.WrappedArray$ofRef'  % TODO handle other array types
                item = javaArrayToMatlabArray2b(item)';
                %try item = cell2mat(item); catch, end  % leave as a cell-array if not array-able (non-uniform)
                try if numel(item) > 1, item = [item{:}]; end, catch, end
            case 'org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema'  % TODO handle other struct types
                item = javaStructToMatlabStruct2(item);
            case 'java.util.HashMap'  % TODO other types of java.util.Map
                item = javaMapToMatlabMap2(item);
            otherwise
                % TODO handle other Java types - leave unchanged for now
        end
    %else
        % Matlab value(s) - leave unchanged
    end
end

function c = getTableColumns(JD, MD)
    c = cell(MD.numRows, MD.numCols);
    for colIdx = 1:MD.numCols
        colData = getTableColumn(JD, MD, colIdx);
        if iscell(colData)
            for rowIdx=1:MD.numRows
                c{rowIdx, colIdx} = colData{rowIdx};
            end
        else
            for rowIdx=1:MD.numRows
                c{rowIdx, colIdx} = colData(rowIdx);
            end
        end
    end
end

function col = getTableColumn(JD, MD, colIdx)
    typeName = MD.typeNames(colIdx);
    jData = JD.values.get(colIdx-1);
    switch typeName
        case 'string'
            col = string(jData.data);
        case 'double'
            col = javaArrayToMatlabArray(jData.data, 'double');
        case 'float'
            col = javaArrayToMatlabArray(jData.data, 'single');
        case 'integer'
            col = javaArrayToMatlabArray(jData.data, 'int32');
        case 'long'
            col = javaArrayToMatlabArray(jData.data, 'int64');
        case "boolean"
            col = javaArrayToMatlabArray(jData.data, 'logical');
        case "date"
            col = getDateCol(jData.data);
        case "timestamp"
            col = getTimestampData(jData.data);            
        case 'struct'
            col = javaStructArrayToMatlabStruct(jData.data);
        case 'array'
            col = javaWrappedArrayToMatlabArray(jData.data);
        case 'map'
            fields = JD.schema.fields;
            col = javaMapArrayToMatlabMap(jData.data, fields(colIdx));
        case 'binary'
            col = javaBinaryArrayToMatlabArray(jData.data);
        otherwise
            error('SPARK:ERROR', 'Unsupported typename, "%s"', typeName);

    end
end

function matlabArr = javaBinaryArrayToMatlabArray(data)
    numRows = size(data,1);
    matlabArr = cell(numRows, 1);
    for k=1:numRows
        matlabArr{k} = data(k,:);
    end
end

function matlabArr = javaArrayToMatlabArray(javaArr, matlabType)
    numRows = numel(javaArr);
    matlabArr = zeros(numRows,1, matlabType);    
    for rowIdx = 1:numRows
        val = javaArr(rowIdx);
        if isempty(val)
            if isinteger(matlabArr)
                matlabArr(rowIdx) =  0;
            else
                matlabArr(rowIdx) =  missing;
            end
        else
            matlabArr(rowIdx) =  double(val);
        end
    end
end

function matlabType = getMatlabTypeFromJavaType(javaType)
    switch char(javaType)
        case 'java.lang.Long'
            matlabType = 'int64';
        otherwise
            error('SPARK:ERROR', 'Unsupported typename, "%s"', javaType);
    end

end

function mData = javaStructArrayToMatlabStruct(javaArr)
    numRows = numel(javaArr);
    mData = makeEmptyStructFromJavaStruct(javaArr(1), numRows);
    fieldNames = fieldnames(mData);
    for k=1:numRows
        JA = javaArr(k);
        JAvalues = JA.values;
        for fieldIdx = 1:numel(fieldNames)
            FN = fieldNames{fieldIdx};
            mData(k).(FN) = convertJavaElement(JAvalues(fieldIdx));
        end
    end
end

function mData = javaRowArrayToMatlabStruct(javaArr, schema)
    numRows = numel(javaArr);
    fieldNames = string(schema.fieldNames);
    mData = makeEmptyStructFromFieldnames(fieldNames, numRows);
    for k=1:numRows
        JA = javaArr(k);
        JAvalues = JA.values;
        for fieldIdx = 1:numel(fieldNames)
            FN = fieldNames(fieldIdx);
            mData(k).(FN) = convertJavaElement(JAvalues(fieldIdx));
        end
    end
end

function mData = javaMapArrayToMatlabMap(javaArr, mapFieldSchema)
    numRows = numel(javaArr);

    schema = mapFieldSchema.dataType.valueType;
    mData = cell(numRows, 1);
    for k=1:numRows
        JA = javaArr(k);
        keys = JA.keys;
        vals = JA.data;
        numElems = numel(keys);
        mKeys = javaArrayToMatlabArray(keys, getMatlabTypeFromJavaType(JA.keyType));
        switch string(schema.typeName)
            case 'struct'
                mVals = javaRowArrayToMatlabStruct(vals, schema);
                % Convert it into a cell array
                mVals = arrayfun(@(x) x, mVals, 'UniformOutput', false);
            otherwise
                mVals = cell(numElems, 1);
                for me = 1:numElems
                    mVals{me} = convertValueWithSchema(vals(me), schema);
                end
        end
        mData{k} = containers.Map(mKeys, mVals);
    end
end

function data = convertValueWithSchema(value, schema)
    typeName = char(schema.typeName);
    switch typeName
        case 'struct'
            fieldNames = string(schema.fieldNames);
            numFields = numel(fieldNames);
            data = makeEmptyStructFromFieldnames(fieldNames);
            for field = 1:numFields
                data.(fieldNames(field)) = convertJavaElement(value.get(field-1));
            end
    end
end
function col = javaWrappedArrayToMatlabArray(javaArr)
    numRows = numel(javaArr);
    col = cell(numRows, 1);
    for k = 1:numRows
       col{k}= getInnerArray(javaArr(k));
    end
end

function arr = getInnerArray(jArr)
   numElems = jArr.size();
   elem1 = jArr.get(0);
   if isjava(elem1)
       % In this case, we're dealing with a nested array
       arr = cell(1, numElems);
       for k = 1:numElems
           arr{k} = convertJavaElement(jArr.get(k-1));
       end
   else
       arr = zeros(1, numElems);
       for k = 1:numElems
           arr(k) = convertJavaElement(jArr.get(k-1));
       end
   end

end

function mData = convertJavaElement(jData)
    if ~isjava(jData)
        mData = jData;
    else
        % Test different kinds of Java objects
        switch class(jData)
            case 'com.mathworks.scala.MatlabDataStruct'
                mData = javaStructToMatlabStruct(jData);
            case 'java.sql.Timestamp'
                mData = datetime(string(jData.toString));                
            case 'java.util.ArrayList'
                mData = getInnerArray(jData);
            otherwise
                error('SPARK:ERROR', 'Unsupported typename, "%s"', class(jData));
        end
    end
end

function mData = javaStructToMatlabStruct(javaStruct)
    mData = makeEmptyStructFromJavaStruct(javaStruct);
    fieldNames = fieldnames(mData);
    JAvalues = javaStruct.values;
    for fieldIdx = 1:numel(fieldNames)
        FN = fieldNames{fieldIdx};
        mData.(FN) = convertJavaElement(JAvalues(fieldIdx));
    end
end

function dateCol = getDateCol(values)
    N = numel(values);
    for k=1:N
        V = values(k);
        if isempty(V)
            dateCol(k) = NaT; %#ok<AGROW>
        else
            dateCol(k) =  datetime(string(V.toString)); %#ok<AGROW>
        end
    end
    dateCol = dateCol(:);    
end

function tsCol = getTimestampData(values)
    N = numel(values);
    for k=1:N
        V = values(k);
        if isempty(V)
            tsCol(k) = NaT; %#ok<AGROW>
        else
            tsCol(k) =  datetime(string(V.toString)); %#ok<AGROW>
        end
    end
    tsCol = tsCol(:);    

end

function S = makeEmptyStructFromJavaStruct(javaStruct, numRows)
    fieldNames = string(javaStruct.fieldNames);
    if nargin == 1
        S = makeEmptyStructFromFieldnames(fieldNames);
    else
        S = makeEmptyStructFromFieldnames(fieldNames, numRows);
    end
end

function S = makeEmptyStructFromFieldnames(fieldNames, numRows)
    N = numel(fieldNames);
    C = cell(2,N);
    for k=1:N
        C{1,k} = fieldNames(k);
    end
    S = struct(C{:});
    if nargin > 1
       S(numRows).(fieldNames(1)) = [];
       S = S(:);
    end
end

function ds = ensureDatasetIsDataframe(ds)
   % ensureDatasetIsDataframe 
   %
   % MATLAB can only handle untyped Datasets, i.e. DataFrames.
   % If ds is a typed Dataset, we convert it to a DataFrame.
   %H = ds.head();  %this takes too long, so skip check and always convert to DF
   %if ~isa(H, 'org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema')
       ds = ds.toDF();
   %end
end
