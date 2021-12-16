function data = storageRdd(obj, appId, varargin)
% STORAGERDD Returns stored RDDs for the given application Id

%  Copyright 2021 MathWorks, Inc.

if ischar(appId) || isStringScalar(appId)
    callUri = obj.endPointUri;
    callUri.Path(end+1) = appId;
else
    error('SPARK:ERROR','Expected application id as a character vector or scalar string');
end

callUri.Path(end+1) = 'storage';
callUri.Path(end+1) = 'rdd';

% Set a rdd id if present
if length(varargin) >= 1
    rddId = varargin{1};
    if ischar(rddId) || isStringScalar(rddId)
        callUri.Path(end+1) = rddId;
    else
        error('SPARK:ERROR','Expected a rdd id as a character vector or scalar string');
    end
end

if length(varargin) > 1
    error('SPARK:ERROR','Unexpected number of arguments');
end

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