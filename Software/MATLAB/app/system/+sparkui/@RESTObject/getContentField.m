function contentField = getContentField(~, varargin)
% GETCONTENTFIELD Returns a content field of the given type, default to application/json

%   Copyright 2021 MathWorks, Inc.

if isempty(varargin)
    contentField = matlab.net.http.field.ContentTypeField('application/json');
elseif length(varargin) == 1
    value = varargin{1};
    if ischar(value) || isStringScalar(value)
        contentField = matlab.net.http.field.ContentTypeField(value);
    else
        error('SPARK:ERROR','Expected a single character vector or scalar string argument')
    end
else
    error('SPARK:ERROR','Expected a single character vector or scalar string argument');
end

end