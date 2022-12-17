function [targetArray]=ccBack(targetArray,sourceArray,index) % index to a cell entry within array of cells

try; index=num2str(index); end;
% linearIndex=sub2ind(size(array{1,1}),vout({[3,3]}))
for m=1:size(sourceArray,1)
    %   output{m,1}=array{m}(index);
%     targetArray{m}(index)=sourceArray{m};
    path=['targetArray{m}(',index,')=sourceArray{m};'];
    eval(path);
%     try
%         path=['output{m,1}=array{m}(',index,');'];
%         eval(path);
%     catch % if array does not contain cells
%         output{m,1}=[];
%     end
end
