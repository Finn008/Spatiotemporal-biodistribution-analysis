function autofluorescenceAnalysis(PlaqueListSingle,PlaqueArray1,MouseInfo)

global W;
Path2file=[W.G.PathOut,'\Autofluorescence\'];
% Relationship: 1-quadrants, 2-laterally, 3-above, 4-below, 5-blood, 6-outside
TimeMinMax=[min(PlaqueArray1.Time2Treatment);max(PlaqueArray1.Time2Treatment)];

%% mice groups
Path2file=[W.G.PathOut,'\SurfacePlots\VGLUT1ClusterDistribution\'];
Groups={[314;336;341;353;375],'Vehicle_314;336;341;353;375';...
    [279;318;331;346;349;371],'NB360_279;318;331;346;349;371';...
    [314;336;341;353;375;279;318;331;346;349;371],'All_314;336;341;353;375;279;318;331;346;349;371';...
    };
Groups=array2table(Groups,'VariableNames',{'MouseIds';'Description'});

%% initial calculations
RelationshipIDs=[1;2;3];

PlaqueArray1=PlaqueArray1(ismember(PlaqueArray1.Relationship,RelationshipIDs),:);
PlaqueArray1(:,{'Relationship'})=[];

Data2Quantify={'MetBlue';'MetRed';'BRratio';'Autofluo1';'MetBlueCorr';'Dystrophies1';'Dystrophies1Pl'};
for Var=Data2Quantify.'
    PlaqueArray1{:,Var}=PlaqueArray1{:,Var}.*PlaqueArray1.Volume;
end

PlaqueArray1=accumarray_8(PlaqueArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),PlaqueArray1(:,[{'VolumeUm3';'Volume'};Data2Quantify]),@nansum);

for Var={'MetBlue';'MetRed';'BRratio'}.' % for intensity data calculate mean intensity per shell (Volume is actually number of pixels)
    PlaqueArray1{:,Var}=PlaqueArray1{:,Var}./PlaqueArray1.Volume;
end
PlaqueArray1_2=PlaqueArray1; % remove

for Var={'Autofluo1';'MetBlueCorr';'Dystrophies1'}.' % for fraction data calculate mean fraction per shell and read out as percent
    PlaqueArray1{:,Var}=PlaqueArray1{:,Var}./PlaqueArray1.Volume*100;
end

PlaqueArray1.Dystrophies1Pl=PlaqueArray1.Dystrophies1Pl./PlaqueArray1.Volume.*PlaqueArray1.VolumeUm3; % for volume based data calculate volume in µm^3 of each shell

PlaqueArray1=fuseTable_MatchingColums_2(PlaqueArray1,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});

TableExport=table;
%% generate mean DistanceTraces
BinInfo={'MouseId',0,0,0;
    'Time2Treatment',[35],[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',[2;4;10;999],[0;999],0 %
    'Distance',[1],[-30;50],0; % 1µm steps
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(PlaqueArray1,BinInfo,'Dystrophies1',[],@nanmean);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Dystrophies1',MouseInfo.MouseId);
Table.Specification(:,1)={'MeanDistanceTraces'};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;

%% calculate total amount of autofluorescent tissue
Table=accumarray_8(PlaqueArray1(:,{'MouseId';'Time2Treatment'}),PlaqueArray1(:,{'VolumeUm3';'Dystrophies1Pl'}),@nansum);
Table.Dystrophies1Pl=Table.Dystrophies1Pl./Table.VolumeUm3*100;

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',[7;14],[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(Table,BinInfo,'Dystrophies1Pl',[],@nanmean);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Dystrophies1Pl',MouseInfo.MouseId);
Table.Properties.VariableNames{end}='Dystrophies1';
Table.Specification(:,1)={'TotalDystrophicFraction'};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;

%% generate mean fraction at plaque border
Table=PlaqueArray1(PlaqueArray1.Distance==1,:);
BinInfo={'MouseId',0,0,0;
    'Time2Treatment',[14;35],[-999;999],0; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',[2;4;10;999],[0;999],0 %
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(Table,BinInfo,'Dystrophies1',[],@nanmean);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Dystrophies1',MouseInfo.MouseId);
Table.Specification(:,1)={'MeanAtPlaqueBorder'};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;

%% export as excel file
Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'Dystrophies1'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;

OutputFilename=[W.G.T.TaskName{W.Task},'_Autofluorescence'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'Dystrophies1',[],'Delete');
Workbook.Save;
Workbook.Close;


%% for each plaque radius (2µm binning) make plot of MetBlueCorr, MetRed,Dystrophies1

RadiiBinning=2;
RadiusMinMax=[0;20];
DistanceBinning=1;
DistanceMinMax=[-30;100];
TimeBinning=-2;
TimeMinMax=[42;70];

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',-2,0,TimeMinMax;
    'PlaqueRadius',[RadiiBinning],[0;999],0
    'Distance',[1],DistanceMinMax,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});

[Table]=accumArrayBinning(PlaqueArray1,BinInfo,{'MetBlueCorr';'MetRed';'Dystrophies1'},[],@nanmean);

PlotRadiusVsDistanceVsFractionVsCohort('MetBlueCorr','314;336;341;353;375;279;318;331;346;349;371',Table,MouseInfo,Groups.MouseIds([1;2]),RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file);

PlotRadiusVsDistanceVsFractionVsCohort('MetRed','314;336;341;353;375;279;318;331;346;349;371',Table,MouseInfo,Groups.MouseIds([1;2]),RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file);


RadiiBinning=2;
RadiusMinMax=[0;20];
DistanceBinning=1;
DistanceMinMax=[-30;100];
TimeBinning=-2;
TimeMinMax=[-28;70];

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',-2,0,TimeMinMax;
    'PlaqueRadius',[RadiiBinning],[0;999],0
    'Distance',[1],DistanceMinMax,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});

PlotRadiusVsDistanceVsFractionVsDataType({'MetRed';'MetBlueCorr'},'314;336;341;353;375;279;318;331;346;349;371',Table,MouseInfo,Groups.MouseIds(3),RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file);

