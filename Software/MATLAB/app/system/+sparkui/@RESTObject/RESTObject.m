classdef RESTObject < dynamicprops
    % RESTOBJECT Spark UI root object
    % Properties added to this object will be available on all Spark UI
    % classes.
    
    
    %  Copyright 2021 MathWorks, Inc.
    
    properties(Hidden)
        token = '';
    end
    
    properties
        cluster_id = '';
        host = '';
        port = [];
        endPointType = sparkui.EndPointType.empty;
        HTTPOptions = matlab.net.http.HTTPOptions.empty;
    end
    
    properties (Dependent)
        baseUri % URI at the per Class instance level e.g./applications
    end


    methods % Constructor
        function obj = RESTObject(~, varargin)
            obj.HTTPOptions = obj.getOptions();
        end
    end
    

    methods % set / get
        function set.endPointType(obj, endPointType)
            if ~isa(endPointType, 'sparkui.EndPointType')
                error('SPARK:ERROR','Expected an endPointType of type sparkui.EndPointType');
            else
                obj.endPointType = endPointType;
            end
        end

        function set.port(obj, port)
            obj.port = obj.iSanitizePort(port);
        end

        function set.host(obj, host)
            obj.host = obj.iSanitizeHost(host);
        end
        
        function baseUri = get.baseUri(obj)
            if obj.endPointType == sparkui.EndPointType.Databricks
                if isempty(obj.host)
                    error('SPARK:ERROR','Host value not set');
                else
                    % Create the URI object
                    baseUri = matlab.net.URI(obj.host);
                end
                baseUri.Path = {'driver-proxy-api'};
                baseUri.Path(end+1) = 'o';
                baseUri.Path(end+1) = '0';
                if isempty(obj.cluster_id)
                    error('SPARK:ERROR','Cluster_id value not set');
                else
                    baseUri.Path(end+1) = obj.cluster_id;
                end
                if isempty(obj.port)
                    error('SPARK:ERROR','Port value not set');
                else
                    baseUri.Path(end+1) = num2str(obj.port); % Checked above
                end
                baseUri.Path(end+1) = 'api';
                baseUri.Path(end+1) = 'v1';

            elseif obj.endPointType == sparkui.EndPointType.ApacheSpark
                if isempty(obj.host)
                    error('SPARK:ERROR','Host value not set');
                else
                    % Create the URI object
                    baseUri = matlab.net.URI(obj.host);
                end
                baseUri.Path = {'api'};
                baseUri.Path(end+1) = 'v1';
                if isempty(obj.port)
                    disp('Port value not set, using Apache Spark localhost default: 4040');
                    obj.port = 4040;
                    baseUri.Port = obj.port;
                else
                    baseUri.Port = obj.port;
                end
            else
                error('SPARK:ERROR','Only Databricks and Apache Spark endpoints are currently supported');
            end
        end
    end


    methods(Hidden)
        function candidateHost = iSanitizeHost(~,hostConfig)
            % Set Host
            if ~(ischar(hostConfig) || isStringScalar(hostConfig))
                error('SPARK:ERROR','Host must be a character vector or scalar string');
            end
            candidateHost = deblank(hostConfig);
            if strlength(candidateHost) == 0
                error('SPARK:ERROR','Host value is empty');
            end
            if ~(startsWith(candidateHost, 'https://', 'IgnoreCase',true) || startsWith(candidateHost, 'http://', 'IgnoreCase',true))
                error('SPARK:ERROR','Expected host value to start with https:// or http://');
            end
            if strcmp(candidateHost(end),'/')
                % Trailing / has been used in the configuration
                % Strip it out.
                candidateHost = candidateHost(1:end-1);
            end
        end

        function candidatePort = iSanitizePort(~, port)
            if isa(port, 'double') || isa(port, 'float') || isinteger(port)
                if isscalar(port)
                    candidatePort = port;
                else
                    error('SPARK:ERROR','Expected port to be scalar');
                end
            else
                error('SPARK:ERROR','Expected port to be of type double, float or integer');
            end
        end
    end
    

    methods
        function getConnectionConfig(obj, varargin)
            if isempty(varargin)
                if obj.endPointType == sparkui.EndPointType.Databricks
                    configFile = databricks.getConfigFile();
                    if isfile(configFile)
                        configData = jsondecode(fileread(configFile));
                        obj.token = configData.token; % Set auth token
                        obj.host = obj.iSanitizeHost(configData.host); % Host (handle trailing characters)
                        obj.cluster_id = configData.cluster_id;
                    else
                        error('SPARK:ERROR','Configuration file not found: %s', char(configFile));
                    end
                elseif obj.endPointType == sparkui.EndPointType.ApacheSpark
                    % No default file currently supported for Apache Spark
                    % default to using local host if not set
                    if isempty(obj.host)
                        disp('Using Apache Spark default host: http://localhost')
                        obj.host = obj.iSanitizeHost('http://localhost');
                    end
                else
                    error('SPARK:ERROR','Unsupported endPoint type');
                end
            elseif length(varargin) == 1
                % In this case, an alternative configuration file was used as an argument
                configFile = varargin{1};
                if ischar(configFile) || isStringScalar(configFile)
                    if isfile(configFile)
                        configData = jsondecode(fileread(configFile));
                    else
                        error('SPARK:ERROR','Configuration file not found: %s', char(configFile));
                    end
                    if obj.endPointType == sparkui.EndPointType.Databricks
                        obj.token = configData.token;
                        obj.host = obj.iSanitizeHost(configData.host);
                        obj.cluster_id = configData.cluster_id;
                    elseif obj.endPointType == sparkui.EndPointType.ApacheSpark
                        obj.host = obj.iSanitizeHost(configData.host);
                    else
                        error('SPARK:ERROR','Unsupported endPoint type');
                    end
                else
                    error('SPARK:ERROR','Expected a configuration file path as a character vector or scalar string');
                end
            elseif length(varargin) > 1
                % Validate the inputs
                validString = @(x) ischar(x) || isStringScalar(x);
                
                p = inputParser;
                p.CaseSensitive = false;
                p.addParameter('host','',validString);
                p.addParameter('token','',validString);
                p.addParameter('cluster_id','',validString);
                p.parse(varargin{:});
                
                if isempty(p.UsingDefaults.host) || isempty(p.UsingDefaults.token) || isempty(p.UsingDefaults.cluster_id)
                    error('SPARK:ERROR','host, token & cluster_id parameters must be set');
                else
                    if ~p.UsingDefaults.host
                        obj.host = obj.iSanitizeHost(p.Results.host);
                    end
                    if ~p.UsingDefaults.token
                        obj.token = p.Results.token;
                    end
                    if ~p.UsingDefaults.cluster_id
                        obj.cluster_id = p.Results.cluster_id;
                    end
                end
            end
        end
    end
    

    methods (Access = protected)
        function addStructureAsDynProps(obj, S)
            propList = fieldnames(S);
            
            for pCount = 1:numel(propList)
                propName = propList{pCount};
                % create the properties on the object
                if ~isprop(obj,propName)
                    addprop(obj, propName);
                end
                
                val = S.(propName);
                
                % populate the information about the object
                obj.(propName) = val;
            end
            
        end
    end
    
end %class
