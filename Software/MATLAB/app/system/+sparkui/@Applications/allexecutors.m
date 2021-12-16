function data = allexecutors(obj, appId, varargin)
% EXECUTORS Returns all executors (active and dead) for the given application Id

%  Copyright 2021 MathWorks, Inc.

if ischar(appId) || isStringScalar(appId)
    callUri = obj.endPointUri;
    callUri.Path(end+1) = appId;
else
    error('SPARK:ERROR','Expected application id as a character vector or scalar string');
end

callUri.Path(end+1) = 'allexecutors';

response = obj.sendRequest(callUri);
obj.unexpectedResponseWarning(response, {matlab.net.http.StatusCode.OK});

if response.StatusCode == matlab.net.http.StatusCode.OK
    data = struct2table(response.Body.Data);
else 
    disp('Body Data:');
    disp(char(response.Body.Data));
    data = [];
end

end