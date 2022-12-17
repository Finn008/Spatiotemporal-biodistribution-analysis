function dystrophyDetection_ImarisSpot_2(MouseInfo,SingleStacks)

global W;
OutputFilename=[W.G.T.TaskName{W.Task},'_ImarisSpot.xlsx'];
PathExcelExport=getPathRaw(OutputFilename);
% PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
SingleStacks(datenum(SingleStacks.Date,'yyyy.mm.dd HH:MM')<datenum('2018.01.05','yyyy.mm.dd'),:)=[];
OrigSingleStacks=SingleStacks;
for ReadOut={'EF1A','PSD95'}
    TableExport=table;
    
    VariableNames={'Volume';'DiameterX';'IntensityMean'};
    Table=table;
    for Row=1:size(SingleStacks,1)
%         ObjInfo=SingleStacks.ImarisSpot{Row,1}.ObjInfo(:,VariableNames);
        ObjInfo=SingleStacks.ImarisSpot{Row,1}.Statistics{ReadOut}.ObjInfo(:,VariableNames);
        ObjInfo(ObjInfo.Volume<=0.01,:)=[];
        ObjInfo(:,{'MouseId';'RoiId';'TreatmentType';'Region'})=repmat(SingleStacks(Row,{'MouseId';'RoiId';'TreatmentType';'Region'}),[size(ObjInfo,1),1]);
        
        SingleStacks.Volume(Row,1)=prod(SingleStacks.Um{Row});
        SingleStacks.SpotNumber(Row,1)=size(ObjInfo,1);
        Table(size(Table,1)+1:size(Table,1)+size(ObjInfo,1),ObjInfo.Properties.VariableNames)=ObjInfo(:,ObjInfo.Properties.VariableNames);
    end
    
    ChannelNames=SingleStacks.ImarisSpot{Row,1}.Statistics{ReadOut}.ChannelNames;
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
    MouseInfo(ismember(MouseInfo.MouseId,unique(Table2.MouseId))==0,:)=[];
    for Calc={'CumSum','NormHistogram'}
        Wave1=distributeColumnHorizontally_4(Table2(:,{Calc{1};'Edges';'MouseId';'Region';'Specification'}),[],'MouseId',Calc{1},MouseInfo.MouseId,'Data');
        Wave1.MathOperation(:,1)=Calc;
        TableExport(end+1:end+size(Wave1,1),Wave1.Properties.VariableNames)=Wave1;
    end
    TableExport=sortrows(TableExport,{'Specification';'MathOperation';'Region';'Edges'});
    
    SingleStacks.SpotDensity=SingleStacks.SpotNumber./SingleStacks.Volume;
    for Reg=1:size(Regions,1)
        Data=SingleStacks(strcmp(SingleStacks.Region,Regions(Reg)),:);
%         Volume=accumarray_9(Data(:,{'MouseId'}),Data(:,'Volume'),@nanmean);
%         SpotNumber=accumarray_9(Data(:,{'MouseId'}),Data(:,'SpotNumber'),@nanmean);
        SpotDensity=accumarray_9(Data(:,{'MouseId'}),Data(:,'SpotDensity'),@nanmean);
%         MouseInfo.Volume(:,Reg)=Volume.Volume(ismember2(MouseInfo.MouseId,Volume.MouseId));
%         MouseInfo.SpotNumber(:,Reg)=SpotNumber.SpotNumber(ismember2(MouseInfo.MouseId,SpotNumber.MouseId));
%         MouseInfo.SpotDensity(:,Reg)=MouseInfo.SpotNumber(:,Reg)./MouseInfo.Volume(:,Reg);
        
        
%         TableExport(end+1,{'Region';'Specification';'Data'})={Regions(Reg),{'SpotDensity'},SpotDensity.SpotDensity(ismember2(MouseInfo.MouseId,SpotDensity.MouseId))};
%         TableExport(end+1,{'Region';'Specification';'Data'})={Regions(Reg),{'SpotDensity'},{SpotDensity.SpotDensity(ismember2(MouseInfo.MouseId,SpotDensity.MouseId))};
        
        TableExport(end+1,{'Region';'Specification';'Data'})=[Regions(Reg),{'SpotDensity'},{SpotDensity.SpotDensity(ismember2(MouseInfo.MouseId,SpotDensity.MouseId)).'}];
    end
    
%     MouseInfo.SpotDensity(:,Reg)=SpotDensity.SpotDensity(ismember2(MouseInfo.MouseId,SpotDensity.MouseId));
    
%     Wave1=table; Wave1.Data=[MouseInfo.Volume.';MouseInfo.SpotNumber.';MouseInfo.SpotDensity.'];
%        
%     Wave1=table; Wave1.Data=[MouseInfo.Volume.';MouseInfo.SpotNumber.';MouseInfo.SpotDensity.'];
%     Wave1.Region=repmat(Regions,[3,1]);
%     Wave1.Specification={'Volume';'Volume';'SpotNumber';'SpotNumber';'SpotDensity';'SpotDensity'};
%     TableExport(end+1:end+size(Wave1,1),Wave1.Properties.VariableNames)=Wave1;
    
    Wave1=accumarray_9(Table(:,{'MouseId';'Region'}),Table(:,DataTypes.Name),@nanmean);
    for Reg=1:size(Regions,1)
        for Type=1:size(DataTypes,1)
            Wave2=Wave1(strcmp(Wave1.Region,Regions{Reg}),{'MouseId',DataTypes.Name{Type}});
            Wave2=Wave2{ismember2(MouseInfo.MouseId,Wave2.MouseId),DataTypes.Name{Type}};
            TableExport(end+1,{'Region';'Specification';'MathOperation';'Data'})={Regions{Reg},DataTypes.Name{Type},'Mean',Wave2.'};
        end
    end
    
    Wave1=findIntersection_2({'Specification';'MathOperation';'Region';'Edges';'Data'},TableExport.Properties.VariableNames.');
    TableExport=TableExport(:,Wave1);
    [TableExport]=table2cell_2(TableExport);
    
    TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
    TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
    TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
    
    % keyboard;
    xlsActxWrite(TableExport,Workbook,['ImarisSpot_',ReadOut{1}],[],'Delete');
end
xlsActxWrite(MouseInfo(:,{'MouseId';'RoiNumber';'TreatmentType'}),Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;