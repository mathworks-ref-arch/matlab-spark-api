classdef File < handle
    % File A class for describing files for Spark compiler
    
    % Copyright 2021 The MathWorks, Inc.
    
    properties
        name string
        funcName string
        nArgIn
        nArgOut
        Args
        ExcludeFromWrapper = false
        InTypes compiler.build.spark.types.ArgType
        OutTypes compiler.build.spark.types.ArgType
        TableInterface = false
    end
    
    methods
        function obj = File(fileName, inArgs, outArgs)
            % Constructor for File class
            % This method takes either one or three arguments
            %
            % Only the file name, will assume each argument and return
            % value is a double  scalar.
            %
            % F = File("foo.m")
            %
            % Use three arguments like this:
            % F = File("bar.m", inArgs, outArgs)
            % inArgs and outArgs are cell arrays or string arrays, with as
            % many entries as input and output arguments to the function.
            % The elements of these cell arrays may be
            %   a string - the datatype of the argument, size is scalar
            %   a cell array - This cell array will have 2 or 3 elements,
            %       a string - the datatype of the argument, and
            %       a vector - [1, inf], to describe that it's a vector
            %       a string - A name of the arguments, which is optional
            %
            % F = File("bar.m", {{"double", [1, inf], "tempCelsius"}}, {"float", {"int32", [1,inf]}});
            if nargin ~= 1 && nargin ~= 3
                error("Spark:Error", "Wrong number of input arguments");
            end
            
            obj.name = fileName;
            [funFolder, funName] = fileparts(obj.name);
            obj.funcName = funName;
            
            if strlength(funFolder) > 0
                oldDir = cd(funFolder);
                goBack = onCleanup(@() cd(oldDir));
            end
            
            if nargin == 3
                obj.nArgIn = numel(inArgs);
                if iscell(inArgs)
                    for k=1:obj.nArgIn
                        arg = inArgs{k};
                        if iscell(arg)
                            obj.InTypes(k) = compiler.build.spark.types.ArgType.instantiate(arg{:});
                        else
                            obj.InTypes(k) = compiler.build.spark.types.ArgType.instantiate(arg);
                        end
                    end
                else
                    for k=1:obj.nArgIn
                        obj.InTypes(k) = compiler.build.spark.types.ArgType.instantiate(inArgs(k));
                    end
                end
                obj.nArgOut = numel(outArgs);
                if iscell(outArgs)
                    for k=1:obj.nArgOut
                        arg = outArgs{k};
                        if iscell(arg)
                            obj.OutTypes(k) = compiler.build.spark.types.ArgType.instantiate(arg{:});
                        else
                            obj.OutTypes(k) = compiler.build.spark.types.ArgType.instantiate(arg);
                        end
                    end
                else
                    for k=1:obj.nArgOut
                        obj.OutTypes(k) = compiler.build.spark.types.ArgType.instantiate(outArgs(k));
                    end
                end
            else
                obj.nArgIn = nargin(funName);
                obj.nArgOut = nargout(funName);
                for k=1:obj.nArgIn
                    obj.InTypes(k) = compiler.build.spark.types.ArgType.instantiate("Double");
                end
                for k=1:obj.nArgOut
                    obj.OutTypes(k) = compiler.build.spark.types.ArgType.instantiate("Double");
                end
                
            end
        end
        
        function retType = getReturnType(obj)
            nOut = obj.nArgOut;
            if  nOut == 0
                retType = "void";
            elseif nOut == 1
                retType = getReturnType(obj.OutTypes);
            else
                types = string.empty;
                for k=1:nOut
                    types(k) = getReturnType(obj.OutTypes(k));
                end
                retType = sprintf("scala.Tuple%d<%s>", nOut, ...
                    types.join(", "));
                
            end
        end
        
        function entry = getEncoderStruct(obj)
            entry = struct(...
                'Name', obj.funcName + "_encoder", ...
                'EncType', obj.getReturnType, ...
                'Constructor', obj.getEncoderCreator);
        end
        
        function enc = getEncoderCreator(obj)
            %  getEncoderCreator Encoder for output of map
            encEntries = obj.OutTypes.getEncoderCreator;
            
            if obj.nArgOut == 1
                enc = encEntries;
            else
                enc =  sprintf("Encoders.tuple(%s)", encEntries.join(", "));
            end
        end
        
        function [outType, outTypeDefinition] = getOutSparkType(obj)
            sparkTypes = [obj.OutTypes.SparkType];
            
            if obj.nArgOut == 1
                outType = "DataTypes." + sparkTypes(1);
                outTypeDefinition = "";
            else
                outType = obj.funcName + "_SparkType";
                SW = matlab.sparkutils.StringWriter();
                N = obj.nArgOut;
                SW.pf("/* StructType '%s' needed for UDF registration */\n", outType);
                SW.pf("List<StructField> fields = new ArrayList<StructField>();\n");
                for kf = 1:N
                    SW.pf("fields.add(DataTypes.createStructField(""a%d"", DataTypes.%s, false));\n", ...
                        kf, sparkTypes(kf));
                end
                SW.pf("StructType " + outType + " = DataTypes.createStructType(fields);\n\n");
                outTypeDefinition = SW.getString();
            end
        end
        
        function names = generateArgNames(obj, direction, base)
            sprintfStr = sprintf("%s%%d", base);
            switch lower(direction)
                case 'in'
                    names = arrayfun(@(x) sprintf(sprintfStr, x), (1:obj.nArgIn));
                case 'out'
                    names = arrayfun(@(x) sprintf(sprintfStr, x), (1:obj.nArgOut));
                otherwise
                    error('SparkBuilder:ArgError', 'Only supported for "in" or "out"');
            end
        end
        
        function [args, types, funcDefinitionArgs] = getArgArray(obj, direction, base)
            %  getArgArray Create array of arguments and their types
            %
            %
            % [a,b,c] = f.getArgArray('in', 'arg')
            % a =
            %   1×2 string array
            %     "arg1"    "arg2"
            % b =
            %   1×2 string array
            %     "Double"    "Double"
            % c =
            %     "Double arg1, Double arg2"
            
            sprintfStr = sprintf("%s%%d", base);
            switch lower(direction)
                case 'in'
                    args = arrayfun(@(x) sprintf(sprintfStr, x), (1:obj.nArgIn));
                    
                    types = getPrimitiveJavaType(obj.InTypes);
                case 'out'
                    args = arrayfun(@(x) sprintf(sprintfStr, x), (1:obj.nArgOut));
                    types = getPrimitiveJavaType(obj.OutTypes);
                otherwise
                    error('SPARK:ERROR', 'Only supported for ''in'' or ''out''');
            end
            if numel(types)==0
                typeAndArgs = string.empty;
            else
                typeAndArgs = arrayfun(@(t,a) t + " " + a, types, args);
            end
            funcDefinitionArgs = join(typeAndArgs, ", ");
            
        end
        
        function writeMethodComment(obj, funcName, SW)
            SW.pf("/** Function: %s\n", funcName);
            SW.pf(" * Num arg in: %d\n", obj.nArgIn);
            SW.pf(" * Num arg out: %d */\n", obj.nArgOut);
        end
        
        function [udfName, udfType, callTypes, UDF] = getUDFInfo(obj)            
            udfName = sprintf("UDF%d", obj.nArgIn);
            UDF.FuncName = udfName;
            callTypes = string.empty;
            convCode = string.empty;
            argNames = string.empty;
            convArgs = string.empty;
            for k=1:obj.nArgIn
                CA = obj.InTypes(k);
                argNames(k) = "arg" + k;
                if CA.isScalarData
                    callTypes(k) = CA.getReturnType;
                    convCode(k) = "";
                    convArgs(k) = argNames(k);
                else
                    callTypes(k) = "WrappedArray<Object>";
                    convName = "conv" + k;
                    convCode(k) = CA.getRowInputValue(argNames(k), convName);
                    convArgs(k) = convName;
                end
            end
            UDF.CallTypes = callTypes;
            UDF.ConvCode = convCode;
            UDF.ConvArgs = convArgs;
            types = [callTypes, obj.getReturnType];
            udfType = sprintf("%s<%s>", udfName, types.join(", "));
            UDF.UDFType = udfType;
        end
    end
    
    methods(Access=private)
        function init(obj)
            
            for k=1:obj.nArgIn
                if k==1
                    obj.Args.In = getArgEntry('double', 1);
                else
                    obj.Args.In(k) = getArgEntry('double', 1);
                end
            end
            for k=1:obj.nArgOut
                if k==1
                    obj.Args.Out = getArgEntry('double', 1);
                else
                    obj.Args.Out(k) = getArgEntry('double', 1);
                end
            end
        end
    end
end

function entry = getArgEntry(mwArgType, argSize)
    entry = matlab.sparkutils.datatypeMapper('matlab', mwArgType);
    
    entry.Size = argSize;
end

% MWClassID.
% CELL   DOUBLE     INT16   INT64   LOGICAL   OPAQUE   STRING   UINT16   UINT64   UNKNOWN
% CHAR   FUNCTION   INT32   INT8    OBJECT    SINGLE   STRUCT   UINT32   UINT8

% d1.get
% getByte         getFloatData      getImagDoubleData   getImagLongData    getLongData
% getByteData     getImag           getImagFloat        getImagShort       getShort
% getClass        getImagByte       getImagFloatData    getImagShortData   getShortData
% getDouble       getImagByteData   getImagInt          getInt
% getDoubleData   getImagData       getImagIntData      getIntData
% getFloat        getImagDouble     getImagLong         getLong

