classdef SparkTall < compiler.build.spark.buildtype.BaseType
    % SparkTall BuildType for spark (used with tall)
    
    % Copyright 2021 The MathWorks, Inc.
    
    methods
        function obj = SparkTall(parent)
            obj.SB = parent;
        end
        
        function opts = mccOpts(~)
            opts = '-vCW';
        end
        
        function str = getBuildTarget(obj)
            JC1 = obj.SB.javaClasses(1);
            C = matlab.sparkutils.Config.getInMemoryConfig;
            str = sprintf(' ''spark:%s,%d''', JC1.name, C.getSparkMajorVersion);
        end
        
        function str = getLinkArgument(~)
            str = '';
        end
        
        function str = getClassBuild(obj)
            str = '';
            for k=1:length(obj.SB.javaClasses)
                str = [str, ' ', ...
                    char(join(getFileNames(obj.SB.javaClasses(k)), " "))];   %#ok<AGROW>
            end 
        end
        
    end
end