function authField = getAuthorizationField(obj, varargin)
% GETAUTHORIZATIONFIELD Return the authorization field for API

%   Copyright 2021 MathWorks, Inc.

authField = matlab.net.http.field.AuthorizationField();
authField.Name = 'Authorization';
authField.Value = ['Bearer',' ',obj.token];

end %function
