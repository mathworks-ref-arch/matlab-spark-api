function data = stages(obj, appId, varargin)
% STAGES Returns stage details for a given application

%  Copyright 2021 MathWorks, Inc.

if ischar(appId) || isStringScalar(appId)
    callUri = obj.endPointUri;
    callUri.Path(end+1) = appId;
else
    error('SPARK:ERROR','Expected application id as a character vector or scalar string');
end

% If no stage id is set all stages are returned
callUri.Path(end+1) = 'stages';

% Set a stage id if present
if length(varargin) >= 1
    stageId = varargin{1};
    if ischar(stageId) || isStringScalar(stageId)
        callUri.Path(end+1) = stageId;
    else
        error('SPARK:ERROR','Expected a stage id as a character vector or scalar string');
    end
end

% Set a stage attempt id if present
if length(varargin) >= 2
    stageAttemptId = varargin{2};
    if ischar(stageAttemptId) || isStringScalar(stageAttemptId)
        callUri.Path(end+1) = stageAttemptId;
    else
        error('SPARK:ERROR','Expected a stage attempt id as a character vector or scalar string');
    end
end

% Set taskList or taskSummary
if length(varargin) >= 3
    stageAttemptId = varargin{3};
    if ischar(stageAttemptId) || isStringScalar(stageAttemptId)
        if strcmpi(stageAttemptId, 'taskSummary')
            callUri.Path(end+1) = 'taskSummary';
        elseif strcmpi(stageAttemptId, 'taskList')
            callUri.Path(end+1) = 'taskList';
        else
            error('SPARK:ERROR','Expected taskSummary or taskList as an argument');
        end
    else
        error('SPARK:ERROR','Expected taskSummary or taskList as a character vector or scalar string');
    end
end

if length(varargin) > 3
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