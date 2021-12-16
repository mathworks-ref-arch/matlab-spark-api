function [matlabJar, jarDir] = getMatlabSparkUtilityFullName(varargin)
    % getMatlabSparkUtilityFullName Retrieve name of Spark Utility
    %
    % Retrieve name of matlab-spark-utility jar used with current
    % configuration.
    %
    % matlabJar = matlab.sparkutils.getMatlabSparkUtilityFullName()
    % matlabJar = 
    %     "matlab-spark-utility-shaded_3.0.1-0.2.7.jar"
    %     
    % Additionally retrieve the Jar folder too.
    %
    % matlabJar =
    %     "/some/folder/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/matlab-spark-utility-shaded_3.0.1-0.2.7.jar"
    %     
    % To get the name of the shaded or unshaded jar, use the argument
    % shaded, e.g.
    %
    % matlabJar = matlab.sparkutils.getMatlabSparkUtilityFullName('shaded', false)
    % matlabJar =
    %     "matlab-spark-utility_3.0.1-0.2.7.jar"
    % 
    
    % Copyright 2021 The MathWorks, Inc.
    
    p = inputParser;  
    p.addParameter('shaded', true);
    p.addParameter('fullpath',false);
    p.parse(varargin{:});
   
    shaded = p.Results.shaded;
    returnPath = p.Results.fullpath;
    
    C = matlab.sparkutils.Config.getInMemoryConfig();
    
    
    CE = C.getCurrentEntry();
    
    if isDatabricksEnvironment || shaded == false
        ext = "";
    else
        ext = "-shaded";
    end
    
    matlabJar = sprintf("matlab-spark-utility%s_%s-%s.jar", ...
        ext, ...
        CE.name, matlab.sparkutils.getMatlabSparkUtilityVersion());
    
    if returnPath
        matlabJar = string(getSparkApiRoot('lib', 'jar', matlabJar));        
    end
end

