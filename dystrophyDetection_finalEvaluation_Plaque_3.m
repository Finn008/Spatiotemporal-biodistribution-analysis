function dystrophyDetection_finalEvaluation_Plaque_3(MouseInfo,PlaqueListSingle,DataArray)

global W;
TableExport=table;
DataArray.Plaque=double(DataArray.Distance<=0)*100;

%% RoiMeans
DataArray2=DataArray;
DataArray2.Plaque=DataArray2.Plaque.*DataArray2.VolumeUm3/100;
DataArray2=accumarray_9(DataArray2(:,{'MouseId';'RoiId'}),DataArray2(:,{'Plaque';'VolumeUm3'}),@nansum);
DataArray2.Plaque=DataArray2.Plaque./DataArray2.VolumeUm3*100;
DataArray2(:,'VolumeUm3')=[];
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId','Plaque',MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['TotalFraction']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
%% MouseMean
DataArray2=DataArray;
DataArray2.Plaque=DataArray2.Plaque.*DataArray2.VolumeUm3/100;
DataArray2=accumarray_9(DataArray2(:,{'MouseId'}),DataArray2(:,{'Plaque';'VolumeUm3'}),@nansum);
DataArray2.Plaque=DataArray2.Plaque./DataArray2.VolumeUm3*100;
MouseInfo.TotalVolume(:,1)=NaN;
MouseInfo.TotalVolume(:,1)=DataArray2.VolumeUm3(ismember2(MouseInfo.MouseId,DataArray2.MouseId))/1000000000;

DataArray2(:,'VolumeUm3')=[];
DataArray2.Specification(:,1)={['TotalFraction']};
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId','Plaque',MouseInfo.MouseId,'Data');
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
TableExport(end+1,{'Specification','Data'})={'TotalVolume',MouseInfo.TotalVolume.'};


%% plaque size histogram
BinInfo={'MouseId',0,0,0;
    'PlaqueRadius',[2;4;5;6],[0;999],0 %
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;

PlaqueListSingle.Number(:,1)=1;
[Table]=accumArrayBinning(PlaqueListSingle,BinInfo,'Number',[],@nansum);
% [~,Wave1]=ismember(Table.MouseId,MouseInfo.MouseId); % at what ind are mice in first table in second
% Table.TotalVolume(:,1)=MouseInfo.TotalVolume(Wave1);
Table=fuseTable_MatchingColums_4(Table,MouseInfo,{'MouseId'},{'TotalVolume'});
Table.PlaqueDensityPERmm3=Table.Number./Table.TotalVolume;
Table1=distributeColumnHorizontally_4(Table(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'PlaqueDensityPERmm3'}),[],'MouseId','PlaqueDensityPERmm3',MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['PlaqueDensityPERmm3']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

Table1=distributeColumnHorizontally_4(Table(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Number'}),[],'MouseId','Number',MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['PlaqueNumber']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;


% count total plaque number and total density per mouse
Wave2=accumarray_9(PlaqueListSingle(:,{'MouseId'}),PlaqueListSingle(:,{'Number'}),@nansum);
[~,Wave1]=ismember(MouseInfo.MouseId,Wave2.MouseId); % at what ind are mice in first table in second
MouseInfo.PlaqueNumber(:,1)=Wave2.Number(Wave1);
MouseInfo.PlaqueDensityPERmm3=MouseInfo.PlaqueNumber./MouseInfo.TotalVolume;
TableExport(end+1,{'Specification','Data'})={'TotalPlaqueNumber',MouseInfo.PlaqueNumber.'};
TableExport(end+1,{'Specification','Data'})={'PlaqueDensityPERmm3',MouseInfo.PlaqueDensityPERmm3.'};
% normalized to 100%
[~,Wave1]=ismember(Table.MouseId,MouseInfo.MouseId); % at what ind are mice in first table in second
Table.TotalPlaqueNumber(:,1)=MouseInfo.PlaqueNumber(Wave1);
Table.PlaqueDensityNormalized=Table.Number./Table.TotalPlaqueNumber*100;

Table1=distributeColumnHorizontally_4(Table(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'PlaqueDensityNormalized'}),[],'MouseId','PlaqueDensityNormalized',MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['PlaqueDensityNormalized']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

% quantifiy mean plaque size
Wave1=accumarray_9(PlaqueListSingle(:,{'MouseId'}),PlaqueListSingle(:,{'PlaqueRadius'}),@nanmean);
MouseInfo.PlaqueRadiusMean(:,1)=Wave1.PlaqueRadius(ismember2(MouseInfo.MouseId,Wave1.MouseId));% specifies the positions within Array2 of the IDs found in Array1
TableExport(end+1,{'Specification','Data'})={'PlaqueRadiusMean',MouseInfo.PlaqueRadiusMean.'};
PlaqueListSingle=removevars(PlaqueListSingle,'Number');

%% plaque density with regards to distance to individual plaques
PlaqueDensityAnalysis=0;
if PlaqueDensityAnalysis==1
    Table=table;
    for Pl=1:size(PlaqueListSingle,1)
        DistanceDistribution=table;
        DistanceDistribution.Volume=PlaqueListSingle.DistanceDistribution{Pl}(2:end);
        %     PlaqueListSingle3.Distance=((PlaqueListSingle3.UmCenter(:,1)-PlaqueListSingle3.UmCenter(Pl,1)).^2 + (PlaqueListSingle3.UmCenter(:,2)-PlaqueListSingle3.UmCenter(Pl,2)).^2 + (PlaqueListSingle3.UmCenter(:,3)-PlaqueListSingle3.UmCenter(Pl,3)).^2).^0.5;
        %     PlaqueListSingle3.Distance=PlaqueListSingle3.Distance-PlaqueListSingle3.PlaqueRadius(Pl);
        Wave1=PlaqueListSingle.InterPlaqueDistance{Pl}.Border2Center;
        DistanceDistribution.PlaqueNumber(:,1)=histcounts(Wave1,([-999,1:1:size(DistanceDistribution,1)]));
        DistanceDistribution.PlaqueNumber(1,1)=DistanceDistribution.PlaqueNumber(1,1)-1; % remove itself
        DistanceDistribution(size(DistanceDistribution,1)-find(flip(DistanceDistribution.Volume)>0,1)+2:end,:)=[];
        DistanceDistribution.Distance(:,1)=1:size(DistanceDistribution,1);
        
        DistanceDistribution.PlId(:,1)=PlaqueListSingle.PlId(Pl);
        DistanceDistribution.Filename(:,1)=PlaqueListSingle.Filename(Pl);
        Table=[Table;DistanceDistribution];
    end
    
    Table=fuseTable_MatchingColums_4(Table,PlaqueListSingle,{'Filename';'PlId'},{'PlaqueRadius';'MouseId';'DystrophicVolume'});
    BinInfo={'MouseId',0,0,0;
        'PlaqueRadius',-2,0,[0;10;999]; %     'PlaqueRadius',[5;10;999],[0;999],0;
        'DystrophicVolume',-2,0,[0;20;999];
        'Distance',[5;10;20],[0;999],0;
        };
    BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name; BinInfo.Properties.RowNames=BinInfo.Name;
    % 'ClusterSize',-2,0,Settings.ClusterSizeEdges; % [0;5;10;15;20;999]
    
    [Table2]=accumArrayBinning(Table,BinInfo,'Volume',[],@nansum);
    [Table3]=accumArrayBinning(Table,BinInfo,'PlaqueNumber',[],@nansum);
    Table2.PlaqueNumber=Table3.PlaqueNumber;
    Table2.PlaqueDensity=Table2.PlaqueNumber./Table2.Volume*1000000000;
    
    Table3=distributeColumnHorizontally_4(Table2(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'DystrophicVolume_Min';'DystrophicVolume_Max';'PlaqueDensity'}),[],'MouseId','PlaqueDensity',MouseInfo.MouseId,'Data');
    Table3.Specification(:,1)={['PlaqueDensityVersusDistance']};
    TableExport(end+1:end+size(Table3,1),Table3.Properties.VariableNames)=Table3;
end
%% write to excel
OutputFilename=[W.G.T.TaskName{W.Task},'_','Plaque','.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'DystrophicVolume_Min';'DystrophicVolume_Max';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
try; TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.Age); end;

xlsActxWrite(TableExport,Workbook,'Plaque',[],'Delete');
xlsActxWrite(MouseInfo,Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;
