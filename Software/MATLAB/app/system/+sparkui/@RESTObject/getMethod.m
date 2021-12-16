function method = getMethod(~, method)
% GETMETHOD Returns a matlab.net.http.RequestMethod 

%   Copyright 2021 MathWorks, Inc.

if isa(method, 'matlab.net.http.RequestMethod')
    % This is the right type already, use it.
else
    if ischar(method) || isStringScalar(method) 
        % This method will throw an error if method is not one of the
        % allowed types
        method = matlab.net.http.RequestMethod(method);
    else
        error('SPARK:ERROR',[ ...
            'The method to a request must be either a string or char ("POST", ''GET'', etc.)', newline, ...
            'or a an object of type matlab.net.http.RequestMethod', newline]);
    end
end

end