function [result, status] =  buildRuntimeQueueJar()
    % buildRuntimeQueueJar Build script for runtime queue jar file
    % result returns a logical true on success
    % status optionally returns the Maven output

    % Copyright 2022-2023 The MathWorks, Inc.

    srcDir = getSparkApiRoot(-1, "Java", "RuntimeQueue");
    old = cd(srcDir);
    goBack = onCleanup(@() cd(old));

    if isDatabricksEnvironment
        matlab.utils.Maven.errorIfNotInstalled();
    end

    V = ver('matlab');
    if ~isscalar(V)
        error("SparkAPI:SparkBuilder", "Unexpected nonscalar ver('matlab') output, possibly caused by a misconfigured Contents.m file on the path");
    end
    javaBuilderLoc = matlab.sparkutils.getJavaBuilderPath();

    artifactId = "javabuilder";

    % Store Javabuilder locally
    mvn( ...
        "-B", ...
        "org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file", ...
        "-Dfile=""" + javaBuilderLoc + """", ...
        "-Dpackaging=jar", ...
        "-DartifactId=" + artifactId, ...
        "-Dversion=""" + V.Version + """", ...
        "-DgroupId=com.mathworks.sparkbuilder");

    % Build the runtimequeue
    [result, status] =  mvn( ...
        "-B", ...
        "-Dmatlab.runtime.version=" + V.Version, ...
        "clean", ...
        "package");
end

function [result, status] = mvn(varargin)
    cmd = sprintf("mvn %s", join(string(varargin), " "));
    [result, status] = system(cmd);
    if (result ~= 0)
        disp(status);
        warning('SparkAPI:SparkBuilder', 'Problems running Maven command:\n\t%s\n', cmd);
    end
end