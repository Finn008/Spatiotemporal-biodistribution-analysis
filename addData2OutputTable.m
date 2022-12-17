function Table=addData2OutputTable(Table,Data2Add,RowIds,Col)

if isstruct(Data2Add) % output format
    MouseInfo=RowIds;
    
%     Wave1=findIntersection_2({'Specification';'TimeMin';'TimeMax';'TimeBin';'RadMin';'RadMax';'RadBin';'Data'},Table.Properties.VariableNames.');
    Wave1=findIntersection_2({'Specification';'TimeMin';'TimeMax';'TimeBin';'RadMin';'RadMax';'RadBin';'Roi';'Distance';'Data'},Table.Properties.VariableNames.');
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

% keyboard; % make faster using RowNameIDs

if isstruct(RowIds)
    RowIds=struct2table(RowIds);
end
VariableNames=RowIds.Properties.VariableNames.';

for Row=1:size(RowIds,1)
    Map=false(size(Table,1),0);
    for m=1:size(VariableNames,1)
        Value=RowIds{Row,m};
        if ischar(Value)
            Value={Value};
        end
        if isempty(Table) || strfind1(VariableNames{m},Table.Properties.VariableNames.')==0
            Map=[Map,false(size(Table,1),1)];
            continue;
        end
        
        if isnumeric(Value)
            Map=[Map,Table{:,VariableNames{m}}==Value];
        else
            Map=[Map,strcmp(Table{:,VariableNames{m}},Value)];
        end
    end
    Ind=find(sum(Map,2)==size(VariableNames,1));
    if isempty(Ind)
        Ind=size(Table,1)+1;
        Table(Ind,VariableNames.')=RowIds(Row,:);
        Table.Data(Ind,:)=NaN;
    end
    Table.Data(Ind,Col)=Data2Add(Row);
end
