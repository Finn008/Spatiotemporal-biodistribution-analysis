function result = errorfun(S, varargin)
warning(S.identifier, S.message);
result = NaN;