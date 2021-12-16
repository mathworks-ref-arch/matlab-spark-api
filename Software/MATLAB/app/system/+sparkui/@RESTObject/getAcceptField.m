function AcceptField = getAcceptField(~, varargin)
% GETACCEPTFIELD Returns a Accept field of the given type, default to application/json

%   Copyright 2021 MathWorks, Inc.

if isempty(varargin)
    AcceptField = matlab.net.http.field.AcceptField('application/json');
elseif length(varargin) == 1
    value = varargin{1};
    if ischar(value) || isStringScalar(value)
        AcceptField = matlab.net.http.field.AcceptField(value);
    else
        error('SPARK:ERROR','Expected a single character vector or scalar string argument')
    end
else
    error('SPARK:ERROR','Expected a single character vector or scalar string argument');
end

end