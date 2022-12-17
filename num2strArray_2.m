function [Out]=num2strArray_2(In)

% Out=cellstr(num2str(In));

Out=num2str(In,10);
Out=cellstr(Out);
Out=regexprep(Out, ' ', '');