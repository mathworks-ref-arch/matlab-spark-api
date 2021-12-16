function data = root(obj, varargin)
% ROOT Calls the base/root /version endpoint
% Returns details of all applications

%  Copyright 2021 MathWorks, Inc.

response = obj.sendRequest();
obj.unexpectedResponseWarning(response, {matlab.net.http.StatusCode.OK});

if response.StatusCode == matlab.net.http.StatusCode.OK
    data = response.Body.Data.spark;
else 
    disp('Body Data:');
    disp(char(response.Body.Data));
    data = [];
end

end