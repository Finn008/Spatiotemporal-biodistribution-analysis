function [Out]=miceCounter_AgeHistogram(Table,AgeRanges,AgeLabel)

for m=1:size(Table,1)
    clear Wave1;
    for m2=1:size(AgeRanges,1)
        Wave1(m2,1)=size(find(Table.Sel{m,1}.Age>AgeRanges(m2,1)&Table.Sel{m,1}.Age<=AgeRanges(m2,2)),1);
    end
    
    Out(m,:)=Wave1;
end
% keyboard;
Out(Out==0)=NaN;
Out=[[{'Months'},num2cell(AgeLabel.')];[Table.Name,num2cell(Out)]];

