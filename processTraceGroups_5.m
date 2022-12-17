function [Table]=processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArray,DataType,RadiiBinning,TimeBinning)
global W;

DataArray(isnan(DataArray{:,DataType}),:)=[];
% DataArray(isnan(DataArray{:,'Ab126468'}),:)=[];
% DataArray(isnan(DataArray{:,'NAB228'})==0,:)=[];
TableExport=table;
if strfind1({'Boutons1';'Bace1';'Lamp1';'Iba1';'NAB228';'RBB';'Ab4G8';'Ab126468';'Ubiquitin'},DataType,1)
    DistanceMinMax=[-20;31];
elseif strfind1({'Dystrophies1';'Bace1Corona';'Lamp1Corona';'Microglia';'MicrogliaSoma';'MicrogliaFibers';'APPCorona';'SynucleinFibrils';'UbiquitinDystrophies'},DataType,1)
    DistanceMinMax=[-10;101];
elseif strfind1({'MetBlue'},DataType,1)
    DistanceMinMax=[-40;101];
else
    keyboard;
end

if exist('RadiiBinning')~=1 || isempty(RadiiBinning)
    RadiiBinning=0; %[999;10;4;2];
end
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[999];
end

if strfind1(DataArray.Properties.VariableNames,'Time2Treatment')==0
    DataArray.Time2Treatment(:,1)=0;
end
Wave1=ismember(MouseInfo.MouseId,unique(DataArray.MouseId))==0;
MouseInfo(Wave1,:)=[];
% % % Wave1=DataArray(DataArray.PlaqueRadius<4 & DataArray.BorderTouch~=0,:);


% Exclude Plaques at the borders: BorderTouch==2 touches border laterally, BorderTouch==1 DistanceCenter2TopBottom<6
if RadiiBinning~=0
    PlaqueListSingle.Membership=PlaqueListSingle.PlId;
    DataArray=fuseTable_MatchingColums_4(DataArray,PlaqueListSingle,{'Filename';'MouseId';'Membership'},{'PlaqueRadius';'BorderTouch'});
    DataArray(DataArray.BorderTouch==1,:)=[];
end

DataArray=DataArray(DataArray.VolumeUm3>=0.5^3,:); % only include distance rings larger than 0.5µm^3


%% Normalize
NormalizeEachImage=0;
if NormalizeEachImage==1
    DataArray2=DataArray(DataArray.Distance>=20|DataArray.Distance==-49,:);
    DataArray2{:,DataType}=DataArray2{:,DataType}.*DataArray2.VolumeUm3;
    %     DataArray2.Distance=[];
    DataArray2=accumarray_9(DataArray2(:,{'Filename'}),DataArray2(:,{DataType;'VolumeUm3'}),@nansum,[]);
    DataArray2.Ratio=DataArray2{:,DataType}./DataArray2.VolumeUm3;
    
    DataArray=fuseTable_MatchingColums_2(DataArray,DataArray2,{'Filename'},{'Ratio'});
    DataArray{:,DataType}=DataArray{:,DataType}./DataArray.Ratio*100;
    % %     A1=DataArray(DataArray.Distance>=20|DataArray.Distance==-49,:);mean(A1.MetBlue)
end

%% generate mean DistanceTraces
if RadiiBinning~=0
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
    
    % maximum of mean traces
    Wave1=DataArray2; Wave1(Wave1.Distance_Max>5,:)=[];
    Wave1=accumarray_8(Wave1(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin'}),Wave1(:,{DataType}),@nanmax);
    Table1=distributeColumnHorizontally_4(Wave1,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
    Table1.Specification(:,1)={'MaxOfMeanDistanceTraces'};
    TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
    
    if NormalizeEachImage==1
        % distance thresholds
        Groups=accumarray_8(DataArray2(:,{'MouseId';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin'}),DataArray2(:,{DataType}),@nanmax);
        Groups(:,DataType)=[];
        VariableNames=Groups.Properties.VariableNames.';
        DistanceThresholds=[120;140;150;200;250];
        
        Table1=table;
        for Group=1:size(Groups,1)
            Wave1=find(DataArray2.MouseId==Groups.MouseId(Group)&DataArray2.PlaqueRadius_Min==Groups.PlaqueRadius_Min(Group)&DataArray2.PlaqueRadius_Max==Groups.PlaqueRadius_Max(Group));
            Wave1=DataArray2(Wave1,:);
            Wave1(Wave1.Distance_Max>30,:)=[];
            for Threshold=1:size(DistanceThresholds,1)
                Wave2=size(Wave1,1)-find(flip(Wave1{:,DataType})>=DistanceThresholds(Threshold),1)+1;
                Wave2=mean(Wave1{Wave2,{'Distance_Min';'Distance_Max'}});
                Table1(end+1,VariableNames)=Groups(Group,VariableNames);
                try
                    Table1(end,{'Numeric';'Data'})={DistanceThresholds(Threshold),Wave2};
                end
            end
            
        end
        Table1=distributeColumnHorizontally_4(Table1,[],'MouseId','Data',MouseInfo.MouseId,'Data');
        Table1.Specification(:,1)={'DistanceThresholds'};
        TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
        % TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
    end
    % Count instances
    DataArray2{:,DataType}=CountInstances;
    Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
    Table1.Specification(:,1)={['MeanDistanceTraces','_Count']};
    TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
end

%% generate mean MaxFraction of individual plaques
if RadiiBinning~=0
    DataArray2=DataArray(DataArray.Distance<=10,:);
    DataArray2=accumarray_8(DataArray2(:,{'MouseId';'Time2Treatment';'Filename';'Membership'}),DataArray2(:,{DataType}),@nanmax);
    DataArray2=fuseTable_MatchingColums_2(DataArray2,DataArray,{'MouseId';'Time2Treatment';'Filename';'Membership'},{'PlaqueRadius'});
    
    BinInfo={'MouseId',0,0,0;
        'Time2Treatment',TimeBinning,[-999;999],0;
        'PlaqueRadius',RadiiBinning,[0;999],0 %
        };
    BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
    BinInfo.Properties.RowNames=BinInfo.Name;
    
    [DataArray2]=accumArrayBinning(DataArray2,BinInfo,DataType,[],@nanmean,'CountInstances');
    CountInstances=DataArray2.CountInstances; DataArray2(:,'CountInstances')=[];
    Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
    Table1.Specification(:,1)={'MaxFraction'};
    TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
    
    DataArray2{:,DataType}=CountInstances;
    Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
    Table1.Specification(:,1)={['MaxFraction','_Count']};
    TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
end

% % % %% generate mean fraction at plaque border
% % % if RadiiBinning~=0
% % %     keyboard; does not fit to values from MeanDistanceTraces==1
% % %     DataArray2=DataArray(DataArray.Distance==1,:);
% % %     BinInfo={'MouseId',0,0,0;
% % %         'Time2Treatment',TimeBinning,[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
% % %         'PlaqueRadius',RadiiBinning,[0;999],0 %
% % %         };
% % %     BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
% % %     BinInfo.Properties.RowNames=BinInfo.Name;
% % %
% % %     [DataArray2]=accumArrayBinning(DataArray2,BinInfo,DataType,[],@nanmean,'CountInstances');
% % %     CountInstances=DataArray2.CountInstances; DataArray2(:,'CountInstances')=[];
% % %     Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
% % %     Table1.Specification(:,1)={'MeanAtPlaqueBorder'};
% % %     TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
% % %
% % %     DataArray2{:,DataType}=CountInstances;
% % %     Table1=distributeColumnHorizontally_4(DataArray2,[],'MouseId',DataType,MouseInfo.MouseId,'Data');
% % %     Table1.Specification(:,1)={['MeanAtPlaqueBorder','_Count']};
% % %     TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
% % % end
%% mean fraction more than 20µm distant to plaques
if RadiiBinning~=0
    DataArray2=DataArray(DataArray.Distance>=20|DataArray.Distance==-49,:);
    DataArray2{:,DataType}=DataArray2{:,DataType}.*DataArray2.VolumeUm3/100;
    DataArray2.Distance=[];
    DataArray2=accumarray_9(DataArray2(:,{'MouseId'}),DataArray2(:,{DataType;'VolumeUm3'}),@nansum,[]);
    DataArray2{:,DataType}=DataArray2{:,DataType}./DataArray2.VolumeUm3*100;
    
    Wave1=ismember2(MouseInfo.MouseId,DataArray2.MouseId);
    Table1=table({'MeanDistant20'},DataArray2{:,DataType}(Wave1).','VariableNames',{'Specification';'Data'});
    TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
end
% A2=DataArray(DataArray.MouseId==71,:);


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

%% write to excel
OutputFilename=[W.G.T.TaskName{W.Task},'_',DataType,'.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'RoiId';'Numeric';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
try; TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.Age); end;

% keyboard;
xlsActxWrite(TableExport,Workbook,DataType,[],'Delete');
xlsActxWrite(MouseInfo,Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;


