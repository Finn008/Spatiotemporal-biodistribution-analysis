function [output]=cc(array,index) % index to a cell entry within array of cells

try; index=num2str(index); end;
% linearIndex=sub2ind(size(array{1,1}),vout({[3,3]}))
for m=1:numel(array)
    %   output{m,1}=array{m}(index);
    try
        path=['output{m,1}=array{m}(',index,');'];
        eval(path);
    catch % if array does not contain cells
        output{m,1}=[];
    end
end
