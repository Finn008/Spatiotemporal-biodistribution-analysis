function [Out]=num2strArray_3(In)
if isnumeric(In)
    In=num2cell(In);
end
% Out=cellstr(num2str(In));
for m=1:size(In,1)
    for m2=1:size(In,2)
        Out{m,m2}=num2str(In{m,m2});
    end
end
% Out=num2str(In,10);
% Out=cellstr(Out);
% Out=regexprep(Out, ' ', '');