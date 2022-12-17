function dystrophyDetection_finalEvaluation_Plaque_2(MouseInfo,PlaqueListSingle,DataArray)

global W;
TableExport=table;
DataArray.Plaque=double(DataArray.Distance<=0)*100;
%% RoiMeans
DataArray2=DataArray;
DataArray2.Plaque=DataArray2.Plaque.*DataArray2.VolumeUm3/100;
DataArray2=accumarray_9(DataArray2(:,{'MouseId';'RoiId'}),DataArray2(:,{'Plaque';'VolumeUm3'}),@nansum);
DataArray2.Plaque=DataArray2.Plaque./DataArray2.VolumeUm3*100;
DataArray2(:,'VolumeUm3')=[];
% DataArray2.Specification(:,1)={['RoiMean']};
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId','Plaque',MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['TotalFraction']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
%% MouseMean
DataArray2=DataArray;
DataArray2.Plaque=DataArray2.Plaque.*DataArray2.VolumeUm3/100;
DataArray2=accumarray_9(DataArray2(:,{'MouseId'}),DataArray2(:,{'Plaque';'VolumeUm3'}),@nansum);
DataArray2.Plaque=DataArray2.Plaque./DataArray2.VolumeUm3*100;
MouseInfo.TotalVolume(:,1)=NaN;
[~,Wave1]=ismember(MouseInfo.MouseId,DataArray2.MouseId); % at what ind are mice in first table in second
MouseInfo.TotalVolume(:,1)=DataArray2.VolumeUm3(Wave1)/1000000000;

% Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId','Plaque',MouseInfo.MouseId,'Data');
DataArray2(:,'VolumeUm3')=[];
% DataArray2.Specification(:,1)={['MouseMean']};
DataArray2.Specification(:,1)={['TotalFraction']};
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId','Plaque',MouseInfo.MouseId,'Data');
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
TableExport(end+1,{'Specification','Data'})={'TotalVolume',MouseInfo.TotalVolume.'};


%% plaque size histogram
BinInfo={'MouseId',0,0,0;
    'PlaqueRadius',[2;4;10],[0;999],0 %
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;

PlaqueListSingle.Number(:,1)=1;
[Table]=accumArrayBinning(PlaqueListSingle,BinInfo,'Number',[],@nansum);
[~,Wave1]=ismember(Table.MouseId,MouseInfo.MouseId); % at what ind are mice in first table in second
Table.TotalVolume(:,1)=MouseInfo.TotalVolume(Wave1);
Table.PlaqueDensityPERmm3=Table.Number./Table.TotalVolume;
Table1=distributeColumnHorizontally_4(Table(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'PlaqueDensityPERmm3'}),[],'MouseId','PlaqueDensityPERmm3',MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['PlaqueDensityPERmm3']};
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
% [~,Wave1]=ismember(MouseInfo.MouseId,Wave1.MouseId); % at what ind are mice in first table in second
MouseInfo.PlaqueRadiusMean(:,1)=Wave1.PlaqueRadius(ismember2(MouseInfo.MouseId,Wave1.MouseId));% specifies the positions within Array2 of the IDs found in Array1 
% MouseInfo.PlaqueDensityPERmm3=MouseInfo.PlaqueNumber./MouseInfo.TotalVolume;
% TableExport(end+1,{'Specification','Data'})={'TotalPlaqueNumber',MouseInfo.PlaqueNumber.'};
TableExport(end+1,{'Specification','Data'})={'PlaqueRadiusMean',MouseInfo.PlaqueRadiusMean.'};



%% write to excel
% OutputFilename=[W.G.T.TaskName{W.Task},'_',DataType,'.xlsx'];


OutputFilename=[W.G.T.TaskName{W.Task},'_','Plaque','.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);
% PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);


Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
try; TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.Age); end;

% Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
% TableExport=TableExport(:,Wave1);
% [TableExport]=table2cell_2(TableExport);
% 
% TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
% TableExport=[TableExport(1,:);TableExport];
% TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
xlsActxWrite(TableExport,Workbook,'Plaque',[],'Delete');
xlsActxWrite(MouseInfo,Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;
