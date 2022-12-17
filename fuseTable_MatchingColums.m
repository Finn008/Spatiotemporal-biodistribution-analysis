function Table1=fuseTable_MatchingColums(Table1,Table2,MatchingColumns,Colums2Integrate,MissingRowHandling)

if exist('MissingRowHandling')~=1
    MissingRowHandling=[];
end
if exist('Colums2Integrate')~=1
    Colums2Integrate=Table2.Properties.VariableNames;
end

[RowIds1,RowIds2]=findCommonMultiColLinInd(Table1(:,MatchingColumns),Table2(:,MatchingColumns));

% RowIds1=multiColLinInd(Table1(:,MatchingColumns));
% RowIds2=multiColLinInd(Table2(:,MatchingColumns));

[~,TargetRows]=ismember(RowIds2,RowIds1);
ZeroIds=find(TargetRows==0);
TargetRows(ZeroIds,1)=(size(Table1,1)+1:size(Table1,1)+size(ZeroIds,1)).';
Table1(TargetRows,Colums2Integrate)=Table2(:,Colums2Integrate);


    



% keyboard;
if strcmp(MissingRowHandling,'CommonOverlap')
    [Wave1,Wave2]=ismember(RowIds2,RowIds1);
    Wave2=Wave2(Wave1);
    Table1=Table1(Wave2,:);
end