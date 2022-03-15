function uploadWheelToDatabricks(obj, uploadFolder, clusterId)
    % uploadWheelToDatabricks Upload wheel to Databricks
    %
    % This method only makes sense when using the matlab-spark-api package
    % in a Databricks context.
    %
    % Please note that this method can only upload files to DBFS. If using
    % other storage, e.g. s3, it has to be uploaded by other means. The
    % library can still be easily installed, using similar code as at the
    % bottom of this method (see databricks.Library).

    % Copyright 2022 The MathWorks, Inc.

    if getSparkEnvironmentType ~= "Databricks"
        error("Databricks:upload_to_databricks_environment", ...
            "This upload method can only be used in a Databricks environment")
    end

    narginchk(2, 3);

    if nargin < 3
        cfg = getConfig(databricks.Object);
        clusterId = cfg.cluster_id;
    end
    
    [wheelFile, wheelName] = obj.getWheelFile();
    % Upload the file to DBFS
    db = databricks.DBFS();
    
    fprintf("Uploading %s to %s ... \n", wheelName, uploadFolder);
    db.upload(wheelFile, uploadFolder)
    if uploadFolder(end) ~= '/'
        uploadFolder(end+1) = '/';
    end
    wheelDbfsName = ['dbfs:', uploadFolder, wheelName];

    fprintf("Installing wheel on cluster %s\n", clusterId);
    PW = databricks.Library;
    PW.setType('whl');
    PW.whl = wheelDbfsName;
    PW.install(clusterId)

end
