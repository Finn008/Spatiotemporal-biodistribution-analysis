function out=num2strArray(in)

out=num2str(in,10);
out=cellstr(out);
out=regexprep(out, ' ', '');