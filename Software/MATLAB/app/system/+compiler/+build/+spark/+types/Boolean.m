classdef Boolean < compiler.build.spark.types.ArgType
    % Boolean Class used for SparkBuilder datatype handling
    
    % Copyright 2021 The MathWorks, Inc.

    methods
        function obj = Boolean(varargin)
            obj@compiler.build.spark.types.ArgType(varargin{:});
            obj.MATLABType = "logical";
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
                encInst = "Encoders.BOOLEAN";
            else
                encInst = "SparkUtilityHelper.booleanArrayEncoder(spark)";
            end
        end
        
        function str = convertMWToRetValue(obj,  srcData)
           if obj.isScalarData
               str = sprintf("((MWLogicalArray) %s).getBoolean(1)", srcData);
           else
               str = sprintf("(boolean[])((MWLogicalArray) %s).getData()", srcData);
           end
        end
        
    end
end