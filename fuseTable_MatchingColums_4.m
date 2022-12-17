% change to _2: unknown values are set to NaN
function Table1=fuseTable_MatchingColums_4(Table1,Table2,MatchingColumns,Colums2Integrate,NewColumnNames)

if exist('Colums2Integrate')~=1
    Colums2Integrate=Table2.Properties.VariableNames;
end
if exist('NewColumnNames')~=1
    NewColumnNames=Colums2Integrate;
end

[RowIds1,RowIds2]=findCommonMultiColLinInd(Table1(:,MatchingColumns),Table2(:,MatchingColumns));

[~,SourceRows]=ismember(RowIds1,RowIds2);
% ZeroIds if some IDs from the TargetTable1 are not found in the SourceTable2

for m=1:size(Colums2Integrate,1)
    if iscell(Table2{1,Colums2Integrate{m}})
        Table1{:,NewColumnNames{m}}={[]};
    elseif isnumeric(Table2{1,Colums2Integrate{m}})
        Table1{:,NewColumnNames{m}}=NaN;
    else
        keyboard;
    end
end

Table1(SourceRows>0,NewColumnNames)=Table2(SourceRows(SourceRows>0),Colums2Integrate);

 
