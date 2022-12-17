
% in array1 search in specified column after strings given in array2,
% provide array1 selection
function [output,indices]=findStrValue2(array1,col,array2)
dbstop if error;
if ischar(col)
    col=findInd(array1.Properties.VariableNames,col);
end
rows=size(array2,1);
indices=zeros(rows,1);
for m=1:rows
    [ind]=findInd(array1{:,col},array2{m,1});
    indices(m,1)=ind(1);
%     if isnan(ind(1))==0
%         newValues(m,1)=array1(ind(1));
%     end
end
wave1=indices; wave1(isnan(wave1))=1;
nanRows=find(isnan(indices)==1);
output=array1(wave1,:);

for m=1:size(nanRows,1)
    for n = 1:size(output,2)
        if iscell(output{nanRows(m),n})
            output{nanRows(m),n}{1}='';
        elseif isnumeric(output{nanRows(m),n})
            output{nanRows(m),n}=NaN;
        end
    end
end
output{nanRows,col}=array2(nanRows);

a1=1;