function [name, plainName] = getSparkBuilderRuntimeQueueFullName()
    % getSparkBuilderRuntimeQueueFullName Retrieve name of sparkbuilder-runtimequeue jar
    %
    % name = matlab.sparkutils.getSparkBuilderRuntimeQueueFullName()
    % name =
    %     "/local/.../sparkbuilder-runtimequeue_9.12-0.1.0.jar"
    %
    % [name, plainName] = matlab.sparkutils.getSparkBuilderRuntimeQueueFullName()
    % name =
    %     "/local/.../sparkbuilder-runtimequeue_9.12-0.1.0.jar"
    % plainName =
    %     "sparkbuilder-runtimequeue_9.12-0.1.0.jar"
    %

    % Copyright 2022 The MathWorks, Inc.

    rtqVer = matlab.sparkutils.getSparkBuilderRuntimeQueueVersion();
    nameCandidate = "sparkbuilder-runtimequeue-" + rtqVer +".jar";
    candidatesFullname = getSparkApiRoot('lib', 'jar', nameCandidate);

    if isfile(candidatesFullname)
        name = candidatesFullname;
        plainName = nameCandidate;
    else
        error("SPARK_API:runtimequeue_not_found", ...
        "Jar file not found: %s\n" + ...
        "Please refer to documentation for more information.\n" + ...
        "It can be built (provided JDK and Maven are present) with the " + ...
        "command:\n\t" + ...
        "matlab.sparkutils.buildRuntimeQueueJar()", ...
        candidatesFullname);
    end
end

