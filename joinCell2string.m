function [output]=joinCell2string(array)

for m=1:numel(array); array{m}=num2str(array{m}); end;

output=cell(size(array,1),1);
for m=1:size(array,1);
    output{m}=strjoin(array(m,:));
end
output = regexprep(output, ' ', '');
a1=1;


