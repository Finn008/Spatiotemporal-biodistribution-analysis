% change to _2: unknown values are set to NaN
function Table1=fuseTable_MatchingColums_3(Table1,Table2,MatchingColumns,Colums2Integrate,NewColumnNames)

if exist('Colums2Integrate')~=1
    Colums2Integrate=Table2.Properties.VariableNames;
end
if exist('NewColumnNames')~=1
    NewColumnNames=Colums2Integrate;
end

[RowIds1,RowIds2]=findCommonMultiColLinInd(Table1(:,MatchingColumns),Table2(:,MatchingColumns));

[~,SourceRows]=ismember(RowIds1,RowIds2);
% ZeroIds if some IDs from the TargetTable1 are not found in the SourceTable2

Table1{:,NewColumnNames}=NaN;
Table1(SourceRows>0,NewColumnNames)=Table2(SourceRows(SourceRows>0),Colums2Integrate);

 
