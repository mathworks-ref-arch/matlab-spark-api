classdef Integer < compiler.build.spark.types.ArgType
    % Integer Class used for SparkBuilder datatype handling
    
    % Copyright 2021 The MathWorks, Inc.
    
    methods
        function obj = Integer(varargin)
            obj@compiler.build.spark.types.ArgType(varargin{:});
            obj.MATLABType = "int32";
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
                encInst = "Encoders.INT";
            else
                encInst = "SparkUtilityHelper.intArrayEncoder(spark)";
            end
        end
        
        function str = convertMWToRetValue(obj,  srcData)
           if obj.isScalarData
               str = sprintf("((MWNumericArray) %s).getInt()", srcData);
           else
               str = sprintf("((MWNumericArray) %s).getIntData()", srcData);
           end
        end
        
    end
end