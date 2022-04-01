classdef ArgType < handle & matlab.mixin.Heterogeneous
    % ArgType Base class for argument types
    %
    % Subclasses are instances of specific data types, e.g. Double, Float,
    % Boolean, etc. The names of the Subclasses will coincide with the Java
    % type names.
    % Compound types may be be subclassed too, or simlpy created by virtue
    % of being an array.
    
    % Copyright 2021 The MathWorks, Inc.

    properties
        Name string
    end
    
    properties (SetAccess = protected)
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
        function obj = ArgType(sz, name)
            if nargin == 0
                sz = [1,1];
            end
            obj.Size = sz;
            if nargin > 1
                obj.Name = name;
            end
            init(obj);
        end
        function ret = isScalarData(obj)
            ret = prod(obj.Size) == 1;
        end
    end
    
    methods (Static)
        function obj = instantiate(typeName, varargin)
            switch lower(string(typeName))
                case "double"
                    javaType = "Double";
                case {"single", "float"}
                    javaType = "Float";
                case {"long", "int64"}
                    javaType = "Long";
                case {"int", "integer", "int32"}
                    javaType = "Integer";
                case {"short", "int16"}
                    javaType = "Short";
                case {"boolean", "logical"}
                    javaType = "Boolean";
                case "string"
                    javaType = "String";
                case "table"
                    javaType = "Table";
                otherwise
                    error("SparkBuilder:DataTypes", ...
                        "Unsupported datatype: '%s'\n", typeName);
                    
            end
            clsName = "compiler.build.spark.types." + javaType;
            obj = feval(clsName, varargin{:});
        end
    end
    
    methods (Abstract)
        encType = getEncoderType(obj)
        encInst = getEncoderInstantiation(obj)
        str = convertMWToRetValue(obj,  srcData)
    end
    
    methods (Sealed)
        function types = getReturnTypes(obj)
            types = string.empty;
            for k=1:length(obj)
                types(k) = obj(k).getReturnType;
            end
        end
        
        function types = getFuncArgTypes(obj)
            types = string.empty;
            for k=1:length(obj)
                types(k) = obj(k).getFuncArgType;
            end
        end
        
        function retType = getReturnType(obj)
            retType = getEncoderType(obj);
        end
        
        function argType = getFuncArgType(obj)
            argType = getPrimitiveJavaType(obj);
        end
        
        function argType = getUDFFuncArgType(obj)
            if obj.isScalarData
                argType = obj.getFuncArgType();
            else
                argType = "WrappedArray<Object>";
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
        
        function mwType = getMWArgType(obj)
            mwType = obj.MWType;
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
        
        function str = instantiateMWValue(obj, srcData, castArgument)
            % instantiateMWValue - Instantiate MW type Java object
            % Arguments:
            %  src - a text string describing the variable to use
            %  castArgument [optional] - a boolean stating if we should use
            %  explicit casting (in case it's just an Object. Default value
            %  is false.
            
            if nargin < 3
                castArgument = false;
            end
            if castArgument
                castStr = sprintf("(%s)", obj.getJavaType);
            else
                castStr = "";
            end
            switch obj.JavaType
                case {"Boolean", "String"}
                    str = sprintf("new %s(%s%s)", ...
                        obj.MWType, castStr, srcData);
                case {"Double", "Float", "Long", "Integer", "Short"}
                    str = sprintf("new %s(%s%s, %s)", ...
                        obj.MWType, castStr, srcData, obj.MWClassID);
                otherwise
                    error("Spark:Error", "Unsupported MATLAB type, %s\n", obj.MATLABType);
            end
        end
        
        function str = declareAndSetRowValue(obj, srcData, inArgName)
            inArgType = obj.getFuncArgType;
            if obj.isScalarData
                str = sprintf("%s %s = (%s) (%s);\n", ...
                    inArgType, inArgName, inArgType, srcData);
            else
                sw = matlab.sparkutils.StringWriter();
                tmpArg = inArgName + "_w";
                sw.pf("Object[] %s = SparkUtilityHelper.WrappedArrayRefToArray(%s).toArray();\n", tmpArg, srcData);
                sw.pf("%s %s = new %s[%s.length];\n", ...
                    inArgType, inArgName, obj.PrimitiveJavaType, tmpArg);
                sw.pf("for (int k=0; k< %s.length; k++) {\n", inArgName);
                sw.indent();
                % TODO: Add some method like unboxArrayElement
                switch obj.JavaType
                    case "String"
                        sw.pf("%s[k] = (%s) %s[k];\n", ...
                            inArgName, obj.JavaType, tmpArg);
                    otherwise
                        sw.pf("%s[k] = ((%s) %s[k]).%sValue();\n", ...
                            inArgName, obj.JavaType, tmpArg, obj.PrimitiveJavaType);
                end
                sw.unindent();
                sw.pf("}\n");
                str = sw.getString();
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
        function primitiveName = getPrimitiveJavaType(obj)
            if ~isscalar(obj)
                primitiveName = string.empty();
                N = length(obj);
                for k=1:N
                    primitiveName(k) = getPrimitiveJavaType(obj(k));
                end
            else
                primitiveName = obj.PrimitiveJavaType;
                if ~isScalarData(obj)
                    primitiveName = primitiveName + "[]";
                end
            end
        end
        
    end
    
    methods (Access = private)
        function init(obj)
            cls = string(class(obj));
            parts = cls.split(".");
            if parts(end)=="Table"
                % Tables are handled separately
                return;
            end
            E = matlab.sparkutils.datatypeMapper("java", parts(end));
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


