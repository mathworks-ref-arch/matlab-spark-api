function buildMWEncoder()
    % buildMWEncoder Builds the MWEncoder Jar
    %
    % The MWEncoder Jar is needed when building Jars using the
    % SparkBuilder. Differences in the underlying implementation affects
    % the sources, so different versions must be built for Apache Spark and
    % Databricks

    % Copyright 2022 The MathWorks, Inc.

    % Generate localized version of MWEncoders.scala
    % This is no longer needed, but is kept here for reference
    % matlab.sparkutils.internal.genExpressionEncoders();

    srcDir = getSparkApiRoot(-1, 'Java', 'MWEncoders');
    old = cd(srcDir);
    goBack = onCleanup(@() cd(old));

    profile = lower(getSparkEnvironmentType());

    mvnCmd = sprintf("mvn -B -P%s clean package", profile);

    if profile == "databricks"
        % Install matlab-databricks-connet jar locally in maven
        databricks.internal.installMWDBXJarLocally();

        [~, mvnInfo] = databricksConnectJar();
        mvnCmd = mvnCmd + " -Dmatlab.databricks.connect.version=" + mvnInfo.version;
    end

    [r,s] = system(mvnCmd, '-echo');
    if r == 0
        fprintf('Built MWEncoders package\n');
    else
        error('SPARKAPI:mwencoder_build', ...
            'Problems building the MWEncoders package.\n%s\n', s);
    end
end