function [a,b,c,d,e] = myscalars(p, q, r, s, t)
    % myscalars Test function for compiler

    % Copyright 2021 The MathWorks, Inc.

    a = p + double(pi);
    b = q + single(pi);
    c = r + int64(pi);
    d = s + int32(pi);
    e = t + int16(pi);
    %    f = xor(u, true);

end