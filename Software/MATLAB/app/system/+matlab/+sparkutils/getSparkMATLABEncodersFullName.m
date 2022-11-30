function [name, plainName] = getSparkMATLABEncodersFullName()
    % getSparkMATLABEncodersFullName Retrieve name of Spark Encoders Jar
    %
    % [name, plainName] = matlab.sparkutils.getSparkMATLABEncodersFullName
    % name =
    %     "C:\EI\BigData\matlab-apache-spark\Modules\matlab-spark-api\Software\MATLAB\lib\jar\matlab-spark-encoders_3.0.1-0.1.0.jar"
    % plainName =
    %     'matlab-spark-encoders_3.0.1-0.1.0.jar'
    %
    % [name, plainName] = matlab.sparkutils.getSparkMATLABEncodersFullName
    % name =
    %     "C:\EI\BigData\matlab-apache-spark\Modules\matlab-spark-api\Software\MATLAB\lib\jar\matlab-spark-encoders_3.0.1-0.1.0.jar"
    % plainName =
    %     'matlab-spark-encoders_3.0.1-0.1.0.jar'
    %

    % Copyright 2022 The MathWorks, Inc.

    candidates = dir(getSparkApiRoot('lib', 'jar', 'matlab-spark-encoders*.jar'));

    if numel(candidates) == 1
        name = string(fullfile(candidates.folder, candidates.name));
    else
        if isempty(candidates)
            error("SPARK_API:mwencoder_not_found", ...
                "No Jar for matlab-spark-encoders was found. " + ...
                "Please refer to documentation for more information.\n" + ...
                "It can be built (provided JDK and Maven present) with the " + ...
                "command:\n\t" + ...
                "matlab.sparkutils.buildMWEncoder()");
        else
            error('SPARK_API:multiple_mwencoder', ...
                "More than one Jar for matlab-spark-encoders was found. " + ...
                "Please make sure only one (preferrably with the highest version number)" + ...
                " is present.");
        end
    end

    if nargout > 1
        plainName = candidates.name;
    end
end

