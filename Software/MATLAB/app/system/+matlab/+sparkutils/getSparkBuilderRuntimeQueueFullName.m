function [name, plainName] = getSparkBuilderRuntimeQueueFullName()
    % getSparkBuilderRuntimeQueueFullName Retrieve name of Spark Utility
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
    % Retrieve name of sparkbuilder-runtimequeue used with current
    % MATLAB version.
    %

    % Copyright 2022 The MathWorks, Inc.

    V = ver('matlab');
    nameCandidate = "sparkbuilder-runtimequeue_" + V.Version + "*.jar";
    candidatesFolder = getSparkApiRoot('lib', 'jar', nameCandidate);

    candidates = dir(candidatesFolder);
    if numel(candidates) == 1
        name = string(fullfile(candidates.folder, candidates.name));

    else
        if isempty(candidates)
            error("SPARK_API:runtimequeue_not_found", ...
                "No Jar for sparkbuilder-runtimequeue was found. " + ...
                "Please refer to documentation for more information.\n" + ...
                "It can be built (provided JDK and Maven present) with the " + ...
                "command:\n\t" + ...
                "matlab.sparkutils.buildRuntimeQueueJar()");
        else
            error('SPARK_API:multiple_runtimequeues', ...
                "More than one Jar for sparkbuilder-runtimequeue was found. " + ...
                "Please make sure only one (preferrably with the highest version number)" + ...
                " is present.");
        end
    end

    if nargout > 1
        [~,f,e] = fileparts(name);
        plainName = f + e;
    end
end

