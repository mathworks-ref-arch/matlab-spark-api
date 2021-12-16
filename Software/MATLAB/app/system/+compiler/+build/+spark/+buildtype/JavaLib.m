classdef JavaLib < compiler.build.spark.buildtype.BaseType
    % JavaLib BuildType for java libraries
    
    % Copyright 2021 The MathWorks, Inc.
    
    methods
        function obj = JavaLib(parent)
            obj.SB = parent;
        end
        
        function opts = mccOpts(~)
            opts = '-vW';
        end
        
        function str = getBuildTarget(obj)
            JC1 = obj.SB.javaClasses(1);
            str = sprintf(' ''java:%s,%s''', obj.SB.package, JC1.name); 
        end
        
        function str = getLinkArgument(obj)
           str = ' -T link:lib'; 
        end
        
        function str = getClassBuild(obj)
            str = '';
            for k=1:length(obj.SB.javaClasses)
                str = [str, getClassBuild(obj.SB.javaClasses(k))];   %#ok<AGROW>
            end 
        end
        
    end
end