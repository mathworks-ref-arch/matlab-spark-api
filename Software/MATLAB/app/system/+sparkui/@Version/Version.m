classdef Version < sparkui.RESTObject
    % VERSION Object to handle /version calls
    %
    % Example:
    %   ver = sparkui.Version(sparkui.EndPointType.Databricks);
    %   version = ver.root()

    %  Copyright 2021 MathWorks, Inc.

properties
    request = matlab.net.http.RequestMessage.empty;
    endPointUri = matlab.net.URI.empty; % URI at the per call level e.g. /version
end

methods
    % Constructor
    function obj = Version(endPointType, port, varargin)
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
        obj.endPointUri.Path(end+1) = 'version';
    end
end %methods

end %class