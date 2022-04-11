function entry = datatypeMapper( from, name )
    % datatypeMapper Do mappings of datatypes
    %
    % This helps with mapping of datatypes between matlab, Java and Spark.
    % entry = matlab.sparkutils.datatypeMapper(from, name)
    % returns the types for matlab, java and spark (values for from) for
    % the datatype named 'name'.
    % entry = matlab.sparkutils.datatypeMapper('matlab', 'single')
    % entry =
    %   struct with fields:
    %
    %     MATLABType: "single"
    %       JavaType: "Float"
    %      SparkType: "FloatType"
    % entry = matlab.sparkutils.datatypeMapper('java', 'String')
    % entry =
    %   struct with fields:
    %
    %     MATLABType: "string"
    %       JavaType: "String"
    %      SparkType: "StringType"
    %
    % Call without arguments to see what types are supported.
    
    % Copyright 2021 MathWorks, Inc.
    
    persistent ML JV SP DB PY
    
    if isempty(ML)
        DB = initDB();
        ML = [DB.MATLABType];
        JV = [DB.JavaType];
        SP = [DB.SparkType];
        PY = [DB.PythonType];
    end

    if nargin == 0
        entry = struct2table(DB);
        return;
    end
    
    errPrefix = 'SPARK:Error';
    switch lower(from)
        case 'matlab'
            idx = find(ML.matches(name));
        case 'java'
            idx = find(JV.matches(name));
        case 'spark'
            idx = find(SP.matches(name));
        otherwise
            error(errPrefix, 'Only support from as ''matlab'', ''java'', or ''spark''\n');
    end
    
    if isempty(idx)
        error(errPrefix, 'Type ''%s'' not found for ''%s''\n', name, from);
    end
    
    entry = DB(idx);
    
end

function DB = initDB()
    DB = [ ...
        addEntry("logical", "Boolean", "boolean", "BooleanType", "BOOLEAN", "getBoolean"), ...
        addEntry("double", "Double", "double", "DoubleType", "DOUBLE", "getDouble"), ...
        addEntry("single", "Float", "float", "FloatType", "FLOAT", "getFloat"), ...
        addEntry("int16", "Short", "short", "ShortType", "SHORT", "getShort"), ...
        addEntry("int32", "Integer", "int", "IntegerType", "INT", "getInt"), ...
        addEntry("int64", "Long", "long", "LongType", "LONG", "getLong"), ...
        ];
    
    if compiler.build.spark.internal.hasMWStringArray
        E =  addEntry("string", "String", "String", "StringType", "STRING", "get");
    else
        % For versions earlier than R2020b, there was no MWStringArray
        E =  addEntry("string", "String", "String", "StringType", "STRING", "toString");
    end
    DB(end+1) = E;
end

function E = addEntry(mlType, javaType, primJavaType, sparkType, encoder, mwGet)
    switch mlType
        case "string"
            if compiler.build.spark.internal.hasMWStringArray
                mwType = "MWStringArray";
            else
                % For versions earlier than R2020b, there was no MWStringArray
                mwType = "MWCharArray";
            end
            pyType = "str";
        case "logical"
            mwType = "MWLogicalArray";
            pyType = "bool";
        case {"double", "single"}
            mwType = "MWNumericArray";
            pyType = "float";
        case {"int64", "int32", "int16"}
            mwType = "MWNumericArray";
            pyType = "int";
        otherwise
            error("Spark:Error", "Bad MATLAB type, %s\n", mlType);
    end
    E = struct(...
        "MATLABType", mlType, ...
        "JavaType", javaType, ...
        "PrimitiveJavaType", primJavaType, ...
        "PythonType", pyType, ...
        "SparkType", sparkType, ...
        "Encoders", encoder, ...
        "MWClassID", "MWClassID." + upper(mlType), ...
        "MWget", mwGet, ...
        "MWType", mwType);
    
end

