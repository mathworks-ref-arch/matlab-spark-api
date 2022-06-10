classdef Config < handle
    % Config Class to handle Spark configurations
    %
    % This class will make it easier to use different versions of Spark,
    % and to build the Jar files and classpath files necessary.
    %
    % The standard configuration is kept in a config file, in JSON, shipped
    % with this package, but settings can be changed and written to disk.
    % If written to disk, they will be written to the current users
    % prefdir.
    %
    % It is also possible to use a Configuration "in memory", and change it
    % there. The methods and functions that need a config setting will use
    % the getInMemoryConfig method, i.e.
    %
    % C = matlab.sparkutils.Config.getInMemoryConfig
    %
    % This is a Config that can be changed, and which will be used,
    % e.g. to change what Spark cluster to connect to.
    %
    
    % Copyright 2020 The MathWorks, Inc.
    
    properties (Hidden = true)
        Data
    end
    
    properties (Dependent = true, SetAccess = private)
        Versions
    end
    properties (Dependent = true)
        CurrentVersion
        Master
    end
    
    methods
        function obj = Config()
            loadConfig(obj);
        end
        
        function loadConfig(obj)
            obj.Data = jsondecode(fileread(obj.getConfigFile));
        end
        
        function entry = getCurrentEntry(obj)
            idx = find(obj.Data.CurrentVersion == obj.Versions, 1);
            entry = obj.Data.Version(idx);
        end
        
        function jars = getCurrentJars(obj)
            entry = getCurrentEntry(obj);
            if isempty(entry.libs)
                jars = string.empty;
            else
                jars = string({entry.libs.jar});
            end
        end
        
        function libs = getLibraries(obj)
            entry = getCurrentEntry(obj);
            libs = entry.libs;
        end

        function verNum = getSparkMajorVersion(obj)
            entry = getCurrentEntry(obj);
            verNum = str2double(entry.name(1));
        end
        
        function mvnCmd = genMavenBuildCommand(obj, envType)
            
            if nargin < 2
                envType = getSparkEnvironmentType();
            end
            
            entry = getCurrentEntry(obj);
            
            mvnCmd = sprintf("mvn --batch-mode -P%s -Dspark.fullversion=%s", ...
                lower(envType), entry.name);
            for k=1:length(entry.maven)
                mvnCmd = sprintf("%s -D%s=%s", mvnCmd, entry.maven(k).name, entry.maven(k).value);
            end
            mvnCmd = sprintf("%s clean package", mvnCmd);
            if nargout == 0
                fprintf("Run this command to build matlab-spark-utility:\n\t%s\n", mvnCmd);
                clear("mvnCmd");
            end
        end
        
        function saveConfig(obj)
            str = pretty(jsonencode(obj.Data));
            cfgFile = obj.getUserConfigFile();
            fh = fopen(cfgFile, 'w');
            if fh < 0
                error('SPARK:ERROR', 'Could not open config file for writing');
            end
            closeAfter = onCleanup(@() fclose(fh));
            fprintf(fh, '%s', str);
        end
        
        function editConfig(obj)
            if batchStartupOptionUsed
                error('SPARK:ERROR', 'Could not open config file for editing, MATLAB stated in batch mode');
            else
                edit(obj.getConfigFile());
            end
        end
        
        
    end
    
    methods % (Access = private)
        function cfg = getConfigFile(obj)
            cfg = getUserConfigFile(obj);
            if ~exist(cfg, 'file')
                cfg = getDefaultConfigFile(obj);
            end
        end
        
        function cfg = getDefaultConfigFile(~)
            cfg = getSparkApiRoot('config', 'matlab_spark_config.json');
        end
        
        function cfg = getUserConfigFile(~)
            cfg = fullfile(prefdir, 'matlab_spark_config.json');
        end
        
        function setCurrentVersionFromSparkHome(obj)
            try
                sparkVer = matlab.sparkutils.getVersionFromSparkHome();
                obj.CurrentVersion = sparkVer;
            catch ME %#ok<NASGU>
                % No SPARK_HOME variable defined. Leave at normal setting
            end
        end
    end
    
    % Getters/Setters
    methods
        function vers = get.Versions(obj)
            vers = string({obj.Data.Version.name});
        end
        
        function curVer = get.CurrentVersion(obj)
            curVer = obj.Data.CurrentVersion;
        end
        
        function set.CurrentVersion(obj, newVer)
            versions = obj.Versions;
            if ismember(newVer, versions)
                obj.Data.CurrentVersion = string(newVer);
            else
                error('SPARK:ERROR', 'The version %s is not part of the available versions (%s)', ...
                    newVer, sprintf('%s ', versions(:)));
            end
        end
        
        function master = get.Master(obj)
            master = obj.Data.Master;
        end
        
        function set.Master(obj, master)
            if ischar(master) || isstring(master)
                obj.Data.Master= string(master);
            else
                error('SPARK:ERROR', 'The master must be a string or char array');
            end
        end
        
    end
    
    methods (Static = true)
        function overwriteUserConfig()
            % overwriteUserConfig Overwrite user config with defaults
            % This may be needed if user config is present, but the
            % structure of the default config has changed.
            
            C = matlab.sparkutils.Config();
            userCfg = C.getUserConfigFile();
            if exist(userCfg, 'file')
                delete(userCfg);
            end
            C = matlab.sparkutils.Config();
            C.saveConfig();
        end
        
        function setInMemoryVersion(versionString)
            C = matlab.sparkutils.Config.getInMemoryConfig();
            C.CurrentVersion = versionString;
        end
        
        function config = getInMemoryConfig()
            % getInMemoryConfig Returns a config that is kept in memory
            % This allows the user to change a config in a session, without
            % writing the changes to a configuration file.
            % This makes it possible to use different configurations in
            % parallel sessions, which may be useful in testing, or when a
            % user has no write privileges.
            
            persistent C
            if isempty(C)
                C = matlab.sparkutils.Config();
            end
            config = C;
        end
        
    end
end
