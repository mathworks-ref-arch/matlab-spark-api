function buildRuntimeQueueJar()
    % buildRuntimeQueueJar Build script for runtimequeue

    % Copyright 2022 The MathWorks, Inc.

    srcDir = getSparkApiRoot(-1, "Java", "RuntimeQueue");
    old = cd(srcDir);
    goBack = onCleanup(@() cd(old));

    V = ver('matlab');
    javaBuilderLoc = fullfile(matlabroot, 'toolbox', 'javabuilder', 'jar', 'javabuilder.jar');

    artifactId = "javabuilder";

    % Store Javabuilder locally
    mvn( ...
        "org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file", ...
        "-Dfile=""" + javaBuilderLoc + """", ...
        "-Dpackaging=jar", ...
        "-DartifactId=" + artifactId, ...
        "-Dversion=""" + V.Version + """", ...
        "-DgroupId=com.mathworks.sparkbuilder")

    % Build the runtimequeue
    mvn( ...
        "-Dmatlab.runtime.version=" + V.Version, ...
        "clean", ...
        "package")
end

function mvn(varargin)
    cmd = sprintf("mvn %s", join(string(varargin), " "));
    [result, status] = system(cmd);
    if (result ~= 0)
        disp(status);
        error('SparkAPI:SparkBuilder', 'Problems running Maven command');
    end
end