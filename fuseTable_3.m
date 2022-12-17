function [T1]=fuseTable_3(T1,T2,SourceTarget)

if exist('SourceTarget')==1
    SourceRows=SourceTarget(:,1);
    TargetRows=SourceTarget(:,2);
else
    TargetRows=T2.Properties.RowNames;
    SourceRows=TargetRows;
    if isempty(TargetRows)
        keyboard; % if no RowNames are present
        SourceRows=(1:size(T2,1)).';
        TargetRows=SourceRows+size(T1,1);
    end
end

for m=1:size(SourceRows,1)
    for m2=T2.Properties.VariableNames
        T1(TargetRows(m,1),m2)=T2(SourceRows(m,1),m2);
    end
end
