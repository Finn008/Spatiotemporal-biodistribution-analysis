
% in array1 search in specified column after strings given in array2,
% provide array1 selection
function [newValues,indices]=findStrValue(oldArray,newArray,oldValues)

rows=size(newArray,1);
indices(rows,1)=NaN;
for m=1:rows
    [ind]=findInd(oldArray,newArray{m,1});
    indices(m,1)=ind(1);
    if isnan(ind(1))==0
        newValues(m,1)=oldValues(ind(1));
    end
end

if size(newValues,1)<rows
    try
        newValues(rows,1)=Nan;
    catch
        newValues(rows,1)={[]};
    end
end
% if turn2Numeric==1
%     newValues=cell2mat(newValues);
% end

a1=1;