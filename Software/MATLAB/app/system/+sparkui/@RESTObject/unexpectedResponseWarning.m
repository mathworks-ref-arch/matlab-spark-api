function tf = unexpectedResponseWarning(~, response, expectedResponse)
% UNEXPECTEDRESPONSEWARNING Log a warning if a response is not as expected
% The warning shows the status code and the reason associated with the response.
% expectedResponse is a cell array of matlab.net.http.StatusCode objects, e.g.
% matlab.net.http.StatusCode.NotFound, numeric HTTP codes e.g. 404 or
% Enumeration Member Names in character vector format e.g. 'NotFound'
% If only a single response type is expected it may be used as is, rather than
% in a cell array.
% A logical true is returned if an unexpected response is detected and a warning
% has been issued, otherwise false is returned.

% Copyright 2020-2021 The MathWorks, Inc.

if ~isa(response, 'matlab.net.http.ResponseMessage')
    error('SPARK:ERROR','Expected response of type matlab.net.http.ResponseMessage');
end

expRespArray = matlab.net.http.StatusCode.empty;
if ~iscell(expectedResponse)
    if ischar(expectedResponse) || isnumeric(expectedResponse)
        expRespArray(1) = matlab.net.http.StatusCode(expectedResponse);
    else
        error('SPARK:ERROR','Expected expectedResponse of type matlab.net.http.StatusCode, character vector, double or integer');
    end
else
    for n = 1:numel(expectedResponse)
        if ischar(expectedResponse{n}) || isnumeric(expectedResponse{n})
            expRespArray(end+1) = matlab.net.http.StatusCode(expectedResponse{n}); %#ok<AGROW>
        else
            error('SPARK:ERROR','Expected expectedResponse of type matlab.net.http.StatusCode, character vector, double or integer');
        end
    end
end

members = ismember(response.StatusCode, expRespArray);
if sum(members) == 0
    warning(['Response: ', char(getReasonPhrase(getClass(response.StatusCode))),': ',char(getReasonPhrase(response.StatusCode))]);
    warning(['  Reason: ', char(response.StatusLine.ReasonPhrase)]);
    tf = true;
else
    tf = false;
end

end
