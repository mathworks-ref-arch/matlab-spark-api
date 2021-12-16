classdef Float < compiler.build.spark.types.ArgType
    % Float Class used for SparkBuilder datatype handling
    
    % Copyright 2021 The MathWorks, Inc.
    
    methods
        function obj = Float(varargin)
            obj@compiler.build.spark.types.ArgType(varargin{:});
            obj.MATLABType = "single";
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
                encInst = "Encoders.FLOAT";
            else
                encInst = "SparkUtilityHelper.floatArrayEncoder(spark)";
            end
        end
        
        function str = convertMWToRetValue(obj,  srcData)
           if obj.isScalarData
               str = sprintf("((MWNumericArray) %s).getFloat()", srcData);
           else
               str = sprintf("((MWNumericArray) %s).getFloatData()", srcData);
           end
        end
        
    end
end