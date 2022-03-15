classdef SparkSession < handle
    % SPARKSESSION Entry point to programming Spark with the Dataset and DataFrame API
    % The Spark Context is retrieved using the .getOrCreate to return the shared Spark
    % Context as required by Spark.
    %
    % For example to create a session:
    %   % Create a Spark configuration and shared Spark session
    %
    %     conf = createJavaSparkConf( ...
    %         'Master', 'local',...
    %         'AppName', 'mysession', ...
    %         'SparkProperties', getDefaultSparkProperties ...
    %         );
    %
    %   % This will create a singleton SparkSession using the getOrCreate() method
    %   spark = matlab.compiler.mlspark.SparkSession(conf);
    %
    
    % Copyright 2015-2021 The MathWorks, Inc.
       
    properties(SetAccess=private)
       SparkServer
       AppName
    end
    
    properties(Access=public, Hidden=true)
        % these properties are used internally
        
        % Scala Spark Session
        sparkSession;
        
    end
    
    methods
        function obj = SparkSession(javaSparkConf)
            
            if ~isa(javaSparkConf, 'org.apache.spark.SparkConf')
                error('SparkAPI:Error', ...
                    'The argument to the SparkSession constructor must be of type "org.apache.spark.SparkConf"');
            end
            
            % Create a SparkSession builder
            sparkSessionBuilder = org.apache.spark.sql.SparkSession.builder();
            %
            % sparkSessionBuilder.appName(conf.AppName);
            % sparkSessionBuilder.master(conf.Master);
            sparkSessionBuilder.config(javaSparkConf);
            
            obj.sparkSession = sparkSessionBuilder.getOrCreate();
            
            
            obj.SparkServer = char(javaSparkConf.get('spark.master'));
            obj.AppName = char(javaSparkConf.get('spark.app.name'));
            
        end
        
        function delete(obj)
            if ~isempty(obj.sparkSession)
                obj.sparkSession.stop();
            end
        end
        
        function result = getSparkConf(obj)
            result = obj.sparkSession.conf;
        end
                
        function setLogLevel(obj, logLevel)
            sparkVer = obj.sparkSession.version();
            vercell = regexp(char(sparkVer),'(\d.\d).\d','tokens');
            if ~isempty(vercell) && strcmp(vercell{1}{1},'1.3')
                error(message('mlspark:internal:UnsupportedSparkAPI'));
            end
            % logLevel is a string that is supported by Spark. As of 04/2016
            % the valid log levels are: 'ALL', 'DEBUG', 'ERROR', 'FATAL',
            % 'INFO', 'OFF', 'TRACE', 'WARN'
            obj.sparkSession.setLogLevel(logLevel);
        end
        
        function setCheckpointDir(obj, dirName)
            obj.sparkSession.setCheckpointDir(dirName);
        end
    end
    
    methods(Hidden = true)
        
        function result = getJavaStorageLevel(obj, storageLvl)
            if ~isa(storageLvl,'org.apache.spark.storage.StorageLevel')
                ME = MException('mlspark:sparkSession:StorageLevel', ...
                    'storageLevel must be of type mlspark.StorageLevel');
                throw(ME);
            end
            
            result = org.apache.spark.storage.StorageLevel(storageLvl.useDisk, ...
                storageLvl.useMemory, ...
                storageLvl.useOffHeap, ...
                storageLvl.deserialized, ...
                storageLvl.replication);
        end
        
        function addtoBroadcastList(obj, bobj)
            obj.broadcastList = {obj.broadcastList, bobj};
        end
    end
    
    
end
