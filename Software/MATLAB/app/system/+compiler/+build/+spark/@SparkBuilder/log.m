function log(obj, varargin)
    % log A small logger utility for the SparkBuilder
    %
    % The log method takes printf-like arguments. It's output depends on
    % the setting of the Verbose property
    
    % Copyright 2021 The MathWorks, Inc.
    
    if obj.Verbose
        fprintf( "SparkBuilder: %s: ", datestr(now,31));
        fprintf( varargin{:} );
        fprintf( "\n");
    end
end
