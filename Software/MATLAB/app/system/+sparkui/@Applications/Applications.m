classdef Applications < sparkui.RESTObject
    % APPLICATIONS Object to handle /applications calls
    %
    % Example:
    %   app = sparkui.Applications(sparkui.EndPointType.Databricks);
    %   rootData = app.root()
    %   rrdData = app.storageRdd(rootData.id)
    %   execData = app.executors(rootData.id)
    %   allexecData = app.allexecutors(rootData.id)

    %  Copyright 2021 MathWorks, Inc.

properties
    request = matlab.net.http.RequestMessage.empty;
    endPointUri = matlab.net.URI.empty; % URI at the per call level e.g. /applications/allexecutors
end

methods
    % Constructor
    function obj = Applications(endPointType, port, varargin)
        % Set endpoint type first
        obj.endPointType = endPointType;
        obj.port = port;
        
        if isempty(varargin)
            obj.getConnectionConfig();
        else
            obj.getConnectionConfig(varargin);
        end

        obj.request = obj.configRequestMessage('GET');
        obj.endPointUri = obj.baseUri;
        obj.endPointUri.Path(end+1) = 'applications';
    end
end %methods

end %class