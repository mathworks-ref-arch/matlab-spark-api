function data = jobs(obj, appId, varargin)
% JOBS Returns job details for a given application
% Handles API calls of form:
%   /applications/[app-id]/jobs
%   /applications/[app-id]/jobs/[job-id]

%  Copyright 2021 MathWorks, Inc.

if ischar(appId) || isStringScalar(appId)
    callUri = obj.endPointUri;
    callUri.Path(end+1) = appId;
else
    error('SPARK:ERROR','Expected application id as a character vector or scalar string');
end

% If no stage id is set all stages are returned
callUri.Path(end+1) = 'jobs';

% Set a job id if present
if length(varargin) >= 1
    jobId = varargin{1};
    if ischar(jobId) || isStringScalar(jobId)
        callUri.Path(end+1) = jobId;
    else
        error('SPARK:ERROR','Expected a job id as a character vector or scalar string');
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


end %function