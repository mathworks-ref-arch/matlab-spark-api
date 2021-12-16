function doesSupport = hasMWStringArray()
    % hasMWStringArray Returns true if release support MWStringArray
    %
    % This is an internal function, and not part of the API.
    
    % Copyright 2021 MathWorks, Inc.
    
    doesSupport = ~verLessThan('matlab', '9.9');
    
end


