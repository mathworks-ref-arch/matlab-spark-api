function extraJars = getMatlabSparkExtraJars(getFullName)
    % getMatlabSparkExtraJars Retrieve names of jars needed for Spark
    %
    % Retrieve the jar files for this Spark setup. The result depends on
    % the current configuration.
    %
    % extraJars = matlab.sparkutils.getMatlabSparkExtraJars
    % extraJars =
    %   3×1 string array
    %     "/some/path/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/delta-core_2.12-0.7.0.jar"
    %     "/some/path/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/spark-avro_2.12-3.0.1.jar"
    %     "/some/path/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/matlab-spark-utility-spark_3.0.1-0.2.6.jar"
    %
    % To only get the file names, use an argument of false:
    % extraJars = matlab.sparkutils.getMatlabSparkExtraJars(false)
    % extraJars =
    %   3×1 string array
    %     "delta-core_2.12-0.7.0.jar"
    %     "spark-avro_2.12-3.0.1.jar"
    %     "matlab-spark-utility-spark_3.0.1-0.2.6.jar"
    
    % Copyright 2021 The MathWorks, Inc.
    
    if nargin < 1
        getFullName = true;
    end
    
    C = matlab.sparkutils.Config.getInMemoryConfig();
    
    fullMatlabJar = matlab.sparkutils.getMatlabSparkUtilityFullName('fullpath', true);
    [jarDir, matlabJar, ext] = fileparts(fullMatlabJar);
    matlabJar = matlabJar + ext;
    extraJars = [C.getCurrentJars, matlabJar];

    if getFullName
        extraJars = arrayfun(@(x) fullfile(jarDir, x), extraJars, 'UniformOutput', true);
    end
   
    extraJars = extraJars(:);
end

