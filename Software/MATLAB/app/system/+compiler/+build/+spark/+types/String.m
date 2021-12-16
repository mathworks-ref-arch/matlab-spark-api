classdef String < compiler.build.spark.types.ArgType
    % String Class used for SparkBuilder datatype handling
    
    % Copyright 2021 The MathWorks, Inc.
    
    methods
        function obj = String(varargin)
            obj@compiler.build.spark.types.ArgType(varargin{:});
            obj.MATLABType = "string";
        end
        
        function encType = getEncoderType(obj)
            if obj.isScalarData
                encType = obj.getJavaType;
            else
                encType = obj.getPrimitiveJavaType;
            end
        end
        
        function encInst = getEncoderInstantiation(obj)
            if obj.isScalarData
                encInst = "Encoders.DOUBLE";
            else
                encInst = "SparkUtilityHelper.doubleArrayEncoder(spark)";
            end
        end
        
        function str = convertMWToRetValue(obj,  srcData)
            if compiler.build.spark.internal.hasMWStringArray
                if obj.isScalarData
                    str = sprintf("(String)((MWStringArray) %s).get(1)", srcData);
                else
                    str = sprintf("(String[])((MWStringArray) %s).getData()", srcData);
                end
            else
                if obj.isScalarData
                    str = sprintf("(String)((MWCharArray) %s).toString()", srcData);
                else
                    error("SparkBuilder:UnsupportedType", ...
                        "String arrays are note supported in versions earlier than R2020b\n");
                end
            end
        end
        
    end
end