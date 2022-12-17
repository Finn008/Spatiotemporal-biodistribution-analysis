function [Table]=processTraceGroups_3(MouseInfo,PlaqueListSingle,DataArray,DataType,RadiiBinning,TimeBinning,ThresholdDistanceCenter2TopBottom)
global W;

TableExport=table;
if strfind1({'Boutons1';'Bace1';'Lamp1';'Iba1'},DataType,1)
    DistanceMinMax=[-20;31];
elseif strfind1({'Dystrophies1';'Bace1Corona';'Lamp1Corona';'Microglia';'MicrogliaSoma';'MicrogliaFibers';'APPCorona'},DataType,1)
    DistanceMinMax=[-10;101];
elseif strfind1({'MetBlue'},DataType,1)
    DistanceMinMax=[-20;101];
else
    keyboard;
end

if exist('RadiiBinning')~=1 || isempty(RadiiBinning)
    RadiiBinning=[999;10;4;2];
end
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[999];
end


% % % Wave1=DataArray(DataArray.PlaqueRadius<4 & DataArray.BorderTouch~=0,:);

DataArray(DataArray.VolumeUm3==0,:)=[];
% Exclude Plaques at the borders: BorderTouch==2 touches border laterally, BorderTouch==1 DistanceCenter2TopBottom<6
% DataArray(DataArray.BorderTouch==2,:)=[];
if exist('ThresholdDistanceCenter2TopBottom')==1
    DataArray(DataArray.BorderTouch==1 & min(DataArray.DistanceCenter2TopBottom,[],2)<ThresholdDistanceCenter2TopBottom,:)=[];
else
    DataArray(DataArray.BorderTouch==1,:)=[];
end

DataArray=DataArray(DataArray.VolumeUm3>=0.5^3,:); % only include distance rings larger than 0.5µm^3

%% generate mean DistanceTraces
BinInfo={'MouseId',0,0,0;
    'Time2Treatment',TimeBinning,[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',RadiiBinning,[0;999],0 %
    'Distance',[1],DistanceMinMax,0; % 1µm steps
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;
[DataArray2]=accumArrayBinning(DataArray,BinInfo,DataType,[],@nanmean,'CountInstances');
CountInstances=DataArray2.CountInstances; DataArray2(:,'CountInstances')=[];
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={'MeanDistanceTraces'};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

DataArray2{:,DataType}=CountInstances;
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['MeanDistanceTraces','_Count']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

%% generate median MaxFraction
DataArray2=DataArray(DataArray.Distance<=10,:);

DataArray2=accumarray_8(DataArray2(:,{'MouseId';'Time2Treatment';'RoiId';'PlId'}),DataArray2(:,{DataType}),@nanmax);
DataArray2=fuseTable_MatchingColums_2(DataArray2,DataArray,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'PlaqueRadius'});

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',TimeBinning,[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',RadiiBinning,[0;999],0 %
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;

[DataArray2]=accumArrayBinning(DataArray2,BinInfo,DataType,[],@nanmedian,'CountInstances');
CountInstances=DataArray2.CountInstances; DataArray2(:,'CountInstances')=[];
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={'MaxFraction'};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

DataArray2{:,DataType}=CountInstances;
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['MaxFraction','_Count']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;


%% generate mean fraction at plaque border
DataArray2=DataArray(DataArray.Distance==1,:);
BinInfo={'MouseId',0,0,0;
    'Time2Treatment',TimeBinning,[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',RadiiBinning,[0;999],0 %
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;

[DataArray2]=accumArrayBinning(DataArray2,BinInfo,DataType,[],@nanmean,'CountInstances');
CountInstances=DataArray2.CountInstances; DataArray2(:,'CountInstances')=[];
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={'MeanAtPlaqueBorder'};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

DataArray2{:,DataType}=CountInstances;
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['MeanAtPlaqueBorder','_Count']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

%% RoiMeans
DataArray2=DataArray;
DataArray2{:,{DataType}}=DataArray2{:,{DataType}}.*DataArray2.VolumeUm3/100;
DataArray2=accumarray_9(DataArray2(:,{'MouseId';'RoiId'}),DataArray2(:,{DataType;'VolumeUm3'}),@nansum);
DataArray2{:,{DataType}}=DataArray2{:,{DataType}}./DataArray2.VolumeUm3*100;
DataArray2(:,'VolumeUm3')=[];
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
Table1.Specification(:,1)={['RoiMean']};
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
%% MouseMean
DataArray2=DataArray;
DataArray2{:,{DataType}}=DataArray2{:,{DataType}}.*DataArray2.VolumeUm3/100;
DataArray2=accumarray_9(DataArray2(:,{'MouseId'}),DataArray2(:,{DataType;'VolumeUm3'}),@nansum);
DataArray2{:,{DataType}}=DataArray2{:,{DataType}}./DataArray2.VolumeUm3*100;
DataArray2(:,'VolumeUm3')=[];
DataArray2.Specification(:,1)={['MouseMean']};
Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;

%%FitPerDistance, EC50

%% write to excel
OutputFilename=[W.G.T.TaskName{W.Task},'_',DataType,'.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);

% PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);


Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
try; TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.Age); end;

keyboard;
xlsActxWrite(TableExport,Workbook,DataType,[],'Delete');
xlsActxWrite(MouseInfo,Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;


