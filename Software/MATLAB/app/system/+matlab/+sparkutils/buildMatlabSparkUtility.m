function [r,s] = buildMatlabSparkUtility(options)
    % buildMatlabSparkUtility Start a Maven build for the MATLAB Spark Utility
    %
    % This function will start a Maven build of the MATLAB Spark Utility.
    % To run this function, it is necessary to run it on a system with
    % Java and Maven properly configured.
    %
    % It relies on information from matlab.sparkutility.Config, to use the
    % correct information.
    
    % Copyright 2020-2023 MathWorks Inc.

    arguments
        options.sparkVersion (1,1) string = ""
    end
   
    % If the databricks package is available use it to provide a warning
    if isDatabricksEnvironment
        if exist('detectProxy', 'file') == 2
            [tf, proxyUri] = detectProxy();
            if tf
                mvnProxyHelp = "https://maven.apache.org/guides/mini/guide-proxies.html";
                warning("A HTTP proxy has been detected: %s\nEnsure Maven has been configured to use the proxy if necessary: %s", proxyUri.EncodedURI, mvnProxyHelp);
            end
        end
    end

    swRoot = fileparts(getSparkApiRoot());
    sparkUtilityDir = fullfile(swRoot, 'Java', 'SparkUtility');
    
    old = cd(sparkUtilityDir);
    goBack = onCleanup(@() cd(old));
    
    C = matlab.sparkutils.Config.getInMemoryConfig();
    if strlength(options.sparkVersion) > 0
        C.CurrentVersion = options.sparkVersion;
    end
    
    mvnCmd = C.genMavenBuildCommand();

    if isDatabricksEnvironment
        % Databricks Spark

        % Install matlab-databricks-connet jar locally in maven
        [~, mvnInfo] = databricksConnectJar();

        if isempty(mvnInfo)
            error('MATLABSparkApi:build_spark_utility_no_dbc_jar', ...
                "Could find a matlab-databricks-connect*-*.jar file. Please build this first.");
        end

        if ~matlab.utils.Maven.installFileToRepo(mvnInfo.file, mvnInfo.groupId, mvnInfo.artifactId, mvnInfo.version, 'echo', true)
            error('MATLABSparkApi:build_spark_utility_install_dbc', "Error installing Databricks Connect jar to Maven repository");
        end
        verFields = split(mvnInfo.version, '.');
        majorVer = str2double(verFields(1));
        if majorVer >= 13
            mvnCmd = mvnCmd + " -Dmatlab.databricks.connectv2.version=" + mvnInfo.version + "-PdatabricksConnectv2";
        else
            mvnCmd = mvnCmd + " -Dmatlab.databricks.connect.version=" + mvnInfo.version + " -Pdatabricks";
        end

        fprintf("Running:\n\t%s\n", mvnCmd);
        [r,s] = system(mvnCmd, '-echo');
    else
        % Plain Apache Spark
        mvnCmdSparkFull = mvnCmd + " -Papachespark";
        fprintf("Running:\n\t%s\n", mvnCmdSparkFull);
        [r1,s1] = system(mvnCmdSparkFull, '-echo');

        mvnCmdSparkPlain = mvnCmd + " -Papachespark_plain";
        fprintf("Running:\n\t%s\n", mvnCmdSparkPlain);
        [r2,s2] = system(mvnCmdSparkPlain, '-echo');

        r = r1 || r2;
        s = [s1,s2];
    end
end