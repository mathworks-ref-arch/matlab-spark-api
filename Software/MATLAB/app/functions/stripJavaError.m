function niceError = stripJavaError(err)
    %stripJavaError Attempt to convert a stack trace into something prettier.
    % (adapted from sendmail.m)
    
    % Copyright 2021 MathWorks, Inc.

    % First, strip the prefix, suffix, "$" sign, and empty lines
    prefix = '^Java exception occurred:\s*';
    suffix = '\s*at (org|java|scala)\..+$';
    err = regexprep(err,{prefix,suffix,'\n\s*\n','\$'},{'','','\n',''});

    % Two nice single-line error messages.  Extract and merge them.
    header = '\S+:\s*';  % e.g. 'java.lang.IllegalArgumentException: '
    pat = [header '(.*?)\n\s*nested exception is:\s*' header '(.*?)\s*'];
    m = regexp(err,pat,'tokens','once');
    if ~isempty(m)
        niceError = sprintf('%s\n%s',m{:});
        return
    end

    % One nice error message (possibly multi-line).  Extract it.
    pat = [header '(.*)\s*'];
    m = regexp(err,pat,'tokens','once');
    if ~isempty(m) && ~isempty(m{1})
        niceError = m{1};
        return
    end

    % Handle special-case popular exceptions.
    pat = '(\S+)\s*';
    m = regexp(err,pat,'tokens','once');
    if ~isempty(m)
        switch m{1}
            case 'javax.mail.AuthenticationFailedException'
                niceError = getString(message('MATLAB:sendmail:assignment_AuthenticationFailed'));
                return
        end
    end

    % Can't find a nice message - return the error message unchanged (except
    % for the prefix, suffix and stack trace, which we don't want to report).
    niceError = err;
end
