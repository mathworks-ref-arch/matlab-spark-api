function req = configRequestMessage(obj, method)
% GCONFIGREQUESTMESSAGE Get the request message to call the databricks API
%
% TODO UPDATE
%    req = obj.getRequestMessage
%
%  will return a matlab.net.http.RequestMessage with the correct
%  authorization information set.
%
%    req = obj.getRequestMessage('POST')
%
%  will create a similar RequestMessage with the correct method set too.

%   Copyright 2021 MathWorks, Inc.

req = matlab.net.http.RequestMessage;
req.Header(end+1) = obj.getAuthorizationField();
req.Header(end+1) = obj.getAcceptField();
if nargin == 2
    req.Method = obj.getMethod(method);
else
    error("SPARK:ERROR","Expect a method type argument e.g.: 'GET'");
end
    
end %function



