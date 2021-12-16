classdef ArgTypeInfo < handle
    % ArgTypeInfo TODO
    
    % Copyright 2021 The MathWorks, Inc.
    
    properties (SetAccess = private)
        MATLABType string
        Size double
        JavaType string
        PrimitiveJavaType string
        SparkType string
        Encoder string
        MWClassID string
        MWget string
        MWType string
    end
    
    methods
        function obj = ArgTypeInfo(typeName, sz)
            % Constructor for ArgTypeInfo
            %
            % Scalar of type int32
            % A = compiler.build.spark.ArgTypeInfo("int32")
            %
            % Vector of type float
            % A = compiler.build.spark.ArgTypeInfo("single", [1,inf])
            %
            % Scalar of type double
            % A = compiler.build.spark.ArgTypeInfo()
            
            
            switch nargin
                case 0
                    typeName = "double";
                    sz = [1,1];
                case 1
                    if iscell(typeName)
                        sz = typeName{2};
                        typeName = typeName{1};
                    else
                        sz = [1,1];
                    end
                case 2
                    % Do nothing, normal case
                otherwise
                    error('Spark:Error', 'Bad arguments for ArgTypeInfo');
            end
            obj.MATLABType = typeName;
            obj.Size = sz;
            init(obj)
        end
        
        function ret = isScalarData(obj)
           ret = prod(obj.Size) == 1;
        end
        
        function str = instantiateValue(obj, srcData)
            switch obj.MATLABType
                case "logical"
                    str = sprintf("new %s(%s)", ...
                        obj.MWType, srcData);
                case {"double", "single", "int64", "int32", "int16"}
                    str = sprintf("new %s(%s, %s)", ...
                        obj.MWType, srcData, obj.MWClassID);
                case "string"
                    str = sprintf("new %s(%s)", ...
                        obj.MWType, srcData);
                otherwise
                    error("Spark:Error", "Unsupported MATLAB type, %s\n", obj.MATLABType);
            end
        end
        
        function str = defineNullVariable(obj, varName)
           str = sprintf("%s %s = null;", ...
               obj.MWType, varName);
        end
        
        function str = convertMWValue(obj, srcData)
            switch obj.MATLABType
                case "logical"
                    str = sprintf("((%s) %s).%s(1)", ...
                        obj.MWType, srcData, obj.MWget);
                case {"double", "single", "int64", "int32", "int16"}
                    if isScalarData(obj)
                        getFunc = obj.MWget;
                    else
                        getFunc = obj.MWget + "Data";
                    end
                    str = sprintf("((%s) %s).%s()", ...
                        obj.MWType, srcData, getFunc);
                case "string"
                    if compiler.build.spark.internal.hasMWStringArray
                        str = sprintf("(String)((%s) %s).%s(1)", ...
                            obj.MWType, srcData, obj.MWget);
                    else
                        str = sprintf("((%s) %s).%s()", ...
                            obj.MWType, srcData, obj.MWget);
                    end
                otherwise
                    error("Spark:Error", "Unsupported MATLAB type, %s\n", obj.MATLABType);
            end
        end

        function str = convertMWValue2(obj, srcData, retName)
            switch obj.MATLABType
                case "logical"
                    if obj.isScalarData
                        str = sprintf("%s %s = ((%s) %s).%s(1);", ...
                            obj.getJavaType, retName, obj.MWType, srcData, obj.MWget);
                    else
                        str = sprintf("%s %s = (%s)((%s) %s).getData();", ...
                            obj.getPrimitiveJavaType, retName, ...
                            obj.getPrimitiveJavaType, ...
                            obj.MWType, srcData);
                    end
                case {"double", "single", "int64", "int32", "int16"}
                    if isScalarData(obj)
                        str = sprintf("%s %s = ((%s) %s).%s();", ...
                            obj.getJavaType, retName, ...
                            obj.MWType, srcData, obj.MWget);
                    else
                        str = sprintf("%s %s = ((%s) %s).%s();\n", ...
                            obj.getPrimitiveJavaType, retName, ...
                            obj.MWType, srcData, obj.MWget + "Data");
                    end
                case "string"
                    if compiler.build.spark.internal.hasMWStringArray
                        if obj.isScalarData
                            str = sprintf("%s %s = (String)((%s) %s).%s(1);", ...
                                obj.getJavaType, retName, obj.MWType, srcData, obj.MWget);
                        else
                            str = sprintf("%s %s = (String[])((%s) %s).%sData();", ...
                                obj.getJavaType, retName, obj.MWType, srcData, obj.MWget);
                        end
                    else
                        str = sprintf("%s %s = ((%s) %s).%s();", ...
                            obj.getJavaType, retName, obj.MWType, srcData, obj.MWget);
                    end
                otherwise
                    error("Spark:Error", "Unsupported MATLAB type, %s\n", obj.MATLABType);
            end
        end

        function T = getJavaType(obj)
            if ~isscalar(obj)
                T = string.empty();
                N = length(obj);
                for k=1:N
                   T(k) = getJavaType(obj(k)); 
                end
            else
                T = obj.JavaType;
                if ~isScalarData(obj)
                    T = T + "[]";
                end
            end
        end

        
        function str = getRowInputValue(obj, src, argName)            
            primType = obj.getPrimitiveJavaType;
            if obj.isScalarData
                str = sprintf("%s %s = (%s) (%s);\n", ...
                    primType, argName, primType, src);
            else
                sw = matlab.sparkutils.StringWriter();
                tmpArg = argName + "_w";
                sw.pf("Object[] %s = SparkUtilityHelper.WrappedArrayRefToArray(%s).toArray();\n", tmpArg, src);
                sw.pf("%s[] %s = new %s[%s.length];\n", ...
                    obj.PrimitiveJavaType, argName, obj.PrimitiveJavaType, tmpArg);
                sw.pf("for (int k=0; k< %s.length; k++) {\n", argName);
                sw.indent();
                switch obj.JavaType
                    case "String"
                        sw.pf("%s[k] = (%s) %s[k];\n", ...
                            argName, obj.JavaType, tmpArg);
                    otherwise
                        sw.pf("%s[k] = ((%s) %s[k]).%sValue();\n", ...
                            argName, obj.JavaType, tmpArg, obj.PrimitiveJavaType);
                end
                sw.unindent();
                sw.pf("}\n");
                str = sw.getString();
            end
        end
        
        function enc = getEncoderCreator(obj)
            if ~isscalar(obj)
                enc = string.empty();
                N = length(obj);
                for k=1:N
                   enc(k) = getEncoderCreator(obj(k)); 
                end
            else
                if obj.isScalarData
                    enc = sprintf("Encoders.%s()", obj.Encoder);
                else
                    switch obj.JavaType
                        case "Boolean"
                            enc = "SparkUtilityHelper.booleanArrayEncoder(spark)";
                        case "Double"
                            enc = "SparkUtilityHelper.doubleArrayEncoder(spark)";
                        case "Float"
                            enc = "SparkUtilityHelper.floatArrayEncoder(spark)";
                        case "Short"
                            enc = "SparkUtilityHelper.shortArrayEncoder(spark)";
                        case "Integer"
                            enc = "SparkUtilityHelper.intArrayEncoder(spark)";
                        case "Long"
                            enc = "SparkUtilityHelper.longArrayEncoder(spark)";
                        case "String"
                            enc = "SparkUtilityHelper.stringArrayEncoder(spark)";
                        otherwise
                            error("SparkAPI:Error", "Unsupported datatype for arrays: %s\n", obj.JavaType);
                    end
                end
            end
            
        end
        
        function retType = getReturnType(obj)
            if isscalar(obj)
                if obj.isScalarData
                    retType = obj.JavaType;
                else
                    retType = obj.PrimitiveJavaType + "[]";
                end
            else
                nOut = length(obj);
                types = string.empty;
                for k=1:nOut
                    types(k) = getReturnType(obj(k));
                end
                retType = sprintf("scala.Tuple%d<%s>", nOut, ...
                    types.join(", "));
            end
        end
        
        
        function primitiveName = getPrimitiveJavaType(obj)
            if ~isscalar(obj)
                primitiveName = string.empty();
                N = length(obj);
                for k=1:N
                   primitiveName(k) = getPrimitiveJavaType(obj(k)); 
                end                
            else
                % switch obj.JavaType
                %     case "Double"
                %         primitiveName = "double";
                %     case "Integer"
                %         primitiveName = "int";
                %     otherwise
                %         error("SparkAPI:Error", "Unsupported datatype: %s\n", name);
                % end
                primitiveName = obj.PrimitiveJavaType;
                if ~isScalarData(obj)
                    primitiveName = primitiveName + "[]";
                end
            end
        end
    end
    
    methods (Hidden)
        function init(obj)
            E = matlab.sparkutils.datatypeMapper("matlab", obj.MATLABType);
            obj.JavaType = E.JavaType;
            obj.PrimitiveJavaType = E.PrimitiveJavaType;
            obj.SparkType = E.SparkType;
            obj.Encoder = E.Encoders;
            obj.MWClassID = E.MWClassID;
            obj.MWget = E.MWget;
            obj.MWType = E.MWType;
        end
    end
    
end

