function data = executors(obj, appId, varargin)
% EXECUTORS Returns active executors for the given application Id
% Handles API calls of form:
%   /applications/[app-id]/executors
%   /applications/[app-id]/executors/[executor-id]/threads

%  Copyright 2021 MathWorks, Inc.

if ischar(appId) || isStringScalar(appId)
    callUri = obj.endPointUri;
    callUri.Path(end+1) = appId;
else
    error('SPARK:ERROR','Expected application id as a character vector or scalar string');
end

% If no executor id is set all executors are returned
callUri.Path(end+1) = 'executors';

% Set an executor id if present
if length(varargin) >= 1
    executor = varargin{1};
    if ischar(executor) || isStringScalar(executor)
        callUri.Path(end+1) = executor;
    else
        error('SPARK:ERROR','Expected a executor id as a character vector or scalar string');
    end
end

% Set threads
if length(varargin) >= 2
    threads = varargin{2};
    if ischar(threads) || isStringScalar(threads)
        if strcmpi(threads, 'threads')
            callUri.Path(end+1) = 'threads';
        else
            error('SPARK:ERROR','Expected threads as an argument');
        end
    else
        error('SPARK:ERROR','Expected threads as a character vector or scalar string');
    end
end

if length(varargin) > 2
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