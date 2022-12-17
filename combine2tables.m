function [FinalTable]=combine2tables(InitialTable,Data2add,Row)
if exist('Row')==0
    Row=1;
end

FinalTable=InitialTable;
Fields1=InitialTable.Properties.VariableNames.';
Fields2=Data2add.Properties.VariableNames.';
for m=1:size(Fields2,1)
    path=['FinalTable.',Fields2{m},'(Row,1)=Data2add.',Fields2{m},';'];
    eval(path);
end
