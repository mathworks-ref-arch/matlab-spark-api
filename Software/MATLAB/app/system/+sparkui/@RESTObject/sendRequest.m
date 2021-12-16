function response = sendRequest(obj, varargin)
% SENDREQUEST Sends a performed HTTP request

%  Copyright 2021 MathWorks, Inc.

if length(varargin) == 1
    % Assume the call URI has been passed as an argument
    uri = varargin{1};
    if ~isa(uri, 'matlab.net.URI')
        error('SPARK:ERROR',' Expected a URI of type matlab.net.URI');
    end
else
    % Use the endpoint uri 
    uri = obj.endPointUri;
end

[response, ~] = obj.request.send(uri, obj.HTTPOptions); %#ok<ASGLU>

end