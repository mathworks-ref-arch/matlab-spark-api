classdef SparkApi < compiler.build.spark.buildtype.BaseType
    % SparkApi BuildType for spark (used with tall)
    
    % Copyright 2021 The MathWorks, Inc.
    
    methods
        function obj = SparkApi(parent)
            obj.SB = parent;
        end
        
        function opts = mccOpts(~)
            opts = '-m';
        end
        
        function str = getBuildTarget(obj)
            str = '';
        end
        
        function str = getLinkArgument(obj)
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