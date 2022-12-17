function Table=addData2OutputTable_2(Table,Data2Add,RowIds,Col)

if isstruct(Data2Add) % output format
    MouseInfo=RowIds;
    
    Wave1=findIntersection_2({'Specification';'TimeMin';'TimeMax';'TimeBin';'RadMin';'RadMax';'RadBin';'DistMin';'DistMax';'DistBin';'Roi';'Distance';'Data'},Table.Properties.VariableNames.');
    TableExport=Table(:,Wave1);
    if exist('Col')==1 && isempty(Col)==0
        SortOrder=Col;
    else
        SortOrder=flip(TableExport.Properties.VariableNames.');
    end
    
    for m=SortOrder.'
        TableExport=sortrows(TableExport,m{1});
    end
    Ind=strfind1(TableExport.Specification,'MouseId',1);
    TableExport=[TableExport(Ind,:);TableExport(1:Ind-1,:);TableExport(Ind+1:end,:)];
    [TableExport]=table2cell_2(TableExport);
    TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType.';
    Table=TableExport;
    return;
end

if isstruct(RowIds)
    RowIds=struct2table(RowIds);
elseif iscell(RowIds)
    Wave1=table(RowIds{1,2},'VariableNames',RowIds(1,1));
    for m=2:size(RowIds,1)
        Wave1(:,RowIds{m,1})=RowIds(m,2);
    end
    RowIds=Wave1;
end

RowIdsVar=RowIds.Properties.VariableNames.';
VariableNames=findIntersection_2(Table.Properties.VariableNames.',RowIdsVar);
if size(VariableNames,1)<size(RowIdsVar,1)
    keyboard; % Variable not initialized
end
RowIds.Rownames(:,1)={''};
for Var=1:size(VariableNames,1)
    Wave1=RowIds{:,VariableNames{Var}};
    if isnumeric(Wave1)
        Wave1=num2strArray_3(Wave1);
    end
    RowIds.Rownames=strcat(RowIds.Rownames,Wave1,'_');
end
for Var=1:size(VariableNames,1)
    Table(RowIds.Rownames,VariableNames{Var})=RowIds(:,VariableNames{Var});
end
Table.Data(RowIds.Rownames,Col)=Data2Add;