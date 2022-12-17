function dystrophyDetection_ImarisSpot(MouseInfo,SingleStacks)

global W;

TableExport=table;
ChannelNames=SingleStacks.ImarisSpot{1,1}.ChannelNames;

VariableNames={'Volume';'DiameterX';'IntensityMean'};
Table=table;
for Row=1:size(SingleStacks,1)
    ObjInfo=SingleStacks.ImarisSpot{Row,1}.ObjInfo(:,VariableNames);
    ObjInfo(ObjInfo.Volume<=0.01,:)=[];
    ObjInfo(:,{'MouseId';'RoiId';'TreatmentType';'Region'})=repmat(SingleStacks(Row,{'MouseId';'RoiId';'TreatmentType';'Region'}),[size(ObjInfo,1),1]);
    
    SingleStacks.Volume(Row,1)=prod(SingleStacks.Um{Row});
    SingleStacks.SpotNumber(Row,1)=size(ObjInfo,1);
    Table(size(Table,1)+1:size(Table,1)+size(ObjInfo,1),ObjInfo.Properties.VariableNames)=ObjInfo(:,ObjInfo.Properties.VariableNames);
end

for Var={'IntensityMean'}
    for Ch=1:size(ChannelNames,1)
        Table{:,[Var{1},'_',ChannelNames{Ch}]}=Table{:,Var{1}}(:,Ch);
    end
end

DataTypes=table;
DataTypes(1,{'Name','Edges','DataArray'})={'Volume',(0:0.01:1).',table};
DataTypes(2,{'Name','Edges','DataArray'})={'DiameterX',(0:0.01:0.8).',table};
DataTypes(3,{'Name','Edges','DataArray'})={['IntensityMean_',ChannelNames{1}],(0:100:10000).',table}; % 8129 and 43000
DataTypes(4,{'Name','Edges','DataArray'})={['IntensityMean_',ChannelNames{2}],(0:500:66000).',table};

% distribution of DataTypes
Table2=table;
MouseIds=unique(Table.MouseId);
Regions=unique(Table.Region);
for Mouse=1:size(MouseIds,1)
    for Reg=1:size(Regions,1)
        for Type=1:size(DataTypes,1)
            Data=Table{Table.MouseId==MouseIds(Mouse) & strcmp(Table.Region,Regions{Reg}),DataTypes.Name{Type}};
            Wave1=table;
            [Wave1.CumSum,Wave1.NormHistogram]=cumSumGenerator(Data,DataTypes.Edges{Type});
            Wave1.Edges=DataTypes.Edges{Type}(2:end);
            Wave1(:,{'MouseId';'Region';'Specification'})=repmat({MouseIds(Mouse),Regions{Reg},DataTypes.Name{Type}},[size(Wave1,1),1]);
            Table2=[Table2;Wave1];
            %             MouseInfo.MeanIntensity
        end
    end
end

for Calc={'CumSum','NormHistogram'}
    Wave1=distributeColumnHorizontally_4(Table2(:,{Calc{1};'Edges';'MouseId';'Region';'Specification'}),[],'MouseId',Calc{1},MouseInfo.MouseId,'Data');
    Wave1.MathOperation(:,1)=Calc;
    TableExport(end+1:end+size(Wave1,1),Wave1.Properties.VariableNames)=Wave1;
end
TableExport=sortrows(TableExport,{'Specification';'MathOperation';'Region';'Edges'});

for Reg=1:size(Regions,1)
    Data=SingleStacks(strcmp(SingleStacks.Region,Regions(Reg)),:);
    Volume=accumarray_9(Data(:,{'MouseId'}),Data(:,'Volume'),@nanmean);
    SpotNumber=accumarray_9(Data(:,{'MouseId'}),Data(:,'SpotNumber'),@nanmean);

    MouseInfo.Volume(:,Reg)=Volume.Volume(ismember2(MouseInfo.MouseId,Volume.MouseId));
    MouseInfo.SpotNumber(:,Reg)=SpotNumber.SpotNumber(ismember2(MouseInfo.MouseId,SpotNumber.MouseId));
    MouseInfo.SpotDensity(:,Reg)=MouseInfo.SpotNumber(:,Reg)./MouseInfo.Volume(:,Reg);
end

Wave1=table; Wave1.Data=[MouseInfo.Volume.';MouseInfo.SpotNumber.';MouseInfo.SpotDensity.'];
Wave1.Region=repmat(Regions,[3,1]);
Wave1.Specification={'Volume';'Volume';'SpotNumber';'SpotNumber';'SpotDensity';'SpotDensity'};
TableExport(end+1:end+size(Wave1,1),Wave1.Properties.VariableNames)=Wave1;

Wave1=accumarray_9(Table(:,{'MouseId';'Region'}),Table(:,DataTypes.Name),@nanmean);
for Reg=1:size(Regions,1)
    for Type=1:size(DataTypes,1)
        Wave2=Wave1(strcmp(Wave1.Region,Regions{Reg}),{'MouseId',DataTypes.Name{Type}});
        Wave2=Wave2{ismember2(MouseInfo.MouseId,Wave2.MouseId),DataTypes.Name{Type}};
        TableExport(end+1,{'Region';'Specification';'MathOperation';'Data'})={Regions{Reg},DataTypes.Name{Type},'Mean',Wave2.'};
    end
end

OutputFilename=[W.G.T.TaskName{W.Task},'_ImarisSpot'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
Wave1=findIntersection_2({'Specification';'MathOperation';'Region';'Edges';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);

% keyboard;
xlsActxWrite(TableExport,Workbook,'ImarisSpot',[],'Delete');
xlsActxWrite(MouseInfo,Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;