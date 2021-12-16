function fixJarName(obj)
    % fixJarName Adapt Jar name for easier identification
    %
    % This method will add MATLAB Release and Spark Release information
    % to the name.
    
    % Copyright 2021 The MathWorks, Inc.
    if obj.AddReleaseToName
        if ~isa(obj.BuildType, 'compiler.build.spark.buildtype.JavaLib')
            % Only do the renaming for the JavaLib case
            return
        end
        pkgArray = string(obj.package).split(".");
        jarBase = char(pkgArray(end));
        
        relName = strcat('R', version('-release'));
        C = matlab.sparkutils.Config.getInMemoryConfig;
        sparkVer = sprintf('Spark%d.x', C.getSparkMajorVersion);
        
        newJarName = sprintf('%s_%s_%s_%s.jar', ...
            jarBase, relName, sparkVer, computer('arch'));
        
        oldDir = cd(obj.outputFolder);
        goBack = onCleanup(@() cd(oldDir));
        
        srcFile = [jarBase, '.jar'];
        dstFile = newJarName;
        if exist(dstFile, 'file')
            delete(dstFile);
        end
        
        movefile(srcFile, dstFile);
    end
end

