function needs = needsPostProcessing(obj)
    % needsPostProcessing Check if wrapper code should be generated

    % Copyright 2021 The MathWorks, Inc.
    needs = false;
    if isa(obj.BuildType, 'compiler.build.spark.buildtype.JavaLib')
        % Do the reprocessing
        needs = true;
    elseif isa(obj.BuildType, 'compiler.build.spark.buildtype.SparkApi')
        % This is using the -m, for an executable. Do nothing
        return
    elseif isa(obj.BuildType, 'compiler.build.spark.buildtype.SparkTall')
        % This is a Jar file, but with precompiled code. No need
        % for post processing
        return
    else
        error('SparkAPI:Error', 'Unsupported BuildType');
    end

end

