function data = root(obj, varargin)
% ROOT Calls the base/root /applications endpoint
% Returns details of all applications

%  Copyright 2021 MathWorks, Inc.

% TODO add varargin parsing for query parameters i.e.:
% ?status=[completed|running] list only applications in the chosen state.
% ?minDate=[date] earliest start date/time to list.
% ?maxDate=[date] latest start date/time to list.
% ?minEndDate=[date] earliest end date/time to list.
% ?maxEndDate=[date] latest end date/time to list.
% ?limit=[limit] limits the number of applications listed.
% Examples:
% ?minDate=2015-02-10
% ?minDate=2015-02-03T16:42:40.000GMT
% ?maxDate=2015-02-11T20:41:30.000GMT
% ?minEndDate=2015-02-12
% ?minEndDate=2015-02-12T09:15:10.000GMT
% ?maxEndDate=2015-02-14T16:30:45.000GMT
% ?limit=10


response = obj.sendRequest();
obj.unexpectedResponseWarning(response, {matlab.net.http.StatusCode.OK});

if response.StatusCode == matlab.net.http.StatusCode.OK
    data = struct2table(response.Body.Data);
else 
    disp('Body Data:');
    disp(char(response.Body.Data));
    data = [];
end

end