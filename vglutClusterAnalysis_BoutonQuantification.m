function vglutClusterAnalysis_BoutonQuantification(VglutArray1,PlaqueListSingle,BoutonList2,MouseInfo,Groups,RelationshipIDs,Path2file)
global W;
BoutonList2=BoutonList2(ismember(BoutonList2.Relationship,RelationshipIDs),:); % include only selected subregions of the 3D volume
BoutonList2(:,{'Relationship'})=[];
BoutonList2=BoutonList2(BoutonList2.DistInMax>=3 & BoutonList2.DistInMax<=9,:); % select only structures in certain range as boutons
BoutonList2.Distance=int16(BoutonList2.Distance)-50;

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',0,0,0;
    'RoiId',0,0,0;
    'PlId',0,0,0;
    'Distance',0,0,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});

% [Wave1]=accumArrayBinning(BoutonList2,BinInfo,,[],@sum);
[Wave1]=accumArrayBinning(BoutonList2,BinInfo,'Radius',[],@sum,'CountInstances'); % Radius is only taken as container for CountInstances

VglutArray1=fuseTable_MatchingColums_2(VglutArray1,Wave1,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'},{'CountInstances'},{'BoutonNumber'});
VglutArray1.BoutonDensity=VglutArray1.BoutonNumber./VglutArray1.VolumeUm3;

% get BoutonDensityDistantEach
Wave1=VglutArray1(VglutArray1.Distance>20,:);
Wave1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId'}),VglutArray1(:,{'VolumeUm3';'BoutonNumber'}),@nansum);
Wave1.BoutonDensity=Wave1.BoutonNumber./Wave1.VolumeUm3;
VglutArray1=fuseTable_MatchingColums_2(VglutArray1,Wave1,{'MouseId';'Time2Treatment';'RoiId'},{'BoutonDensity'},{'BoutonDensityDistantEach'});
VglutArray1.BoutonDensityNormEach=VglutArray1.BoutonDensity./VglutArray1.BoutonDensityDistantEach*100;

% get BoutonDensityDistantBefore
Wave1=VglutArray1(VglutArray1.Time2Treatment<=0 & VglutArray1.Distance>20,:);
Wave1=accumarray_8(VglutArray1(:,{'MouseId';'RoiId'}),VglutArray1(:,{'VolumeUm3';'BoutonNumber'}),@nansum);
Wave1.BoutonDensity=Wave1.BoutonNumber./Wave1.VolumeUm3;
VglutArray1=fuseTable_MatchingColums_2(VglutArray1,Wave1,{'MouseId';'RoiId'},{'BoutonDensity'},{'BoutonDensityDistantBefore'});
VglutArray1.BoutonDensityNorm=VglutArray1.BoutonDensity./VglutArray1.BoutonDensityDistantBefore*100;

VglutArray1=fuseTable_MatchingColums_2(VglutArray1,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});
keyboard;
%% from week 0 to 10 weeks for 4µm binned radii
RadiiBinning=4;
RadiusMinMax=[0;20];
DistanceBinning=1;
DistanceMinMax=[-20;100];
TimeBinning=-2;
TimeMinMax=[0;70];

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',-2,0,TimeMinMax;
    'PlaqueRadius',[RadiiBinning],[0;999],0
    'Distance',[1],DistanceMinMax,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
[Table]=accumArrayBinning(VglutArray1,BinInfo,'BoutonDensityNormEach'); % previously BoutonDensityNorm
Table.Properties.VariableNames{11}='BoutonDensity';
Table=distributeColumnHorizontally_4(Table,[],'MouseId','BoutonDensity',MouseInfo.MouseId);
vglutClusterAnalysis_PlotBoutonDensity(['NormBoutonDensity_',Groups.Description{1},'_',Groups.Description{8}],Table,MouseInfo,Groups.MouseIds([1;8]),RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file);

%% from week -4 to 10, all mice pooled for 4µm binned radii
RadiiBinning=4;
RadiusMinMax=[0;24];
DistanceBinning=1;
DistanceMinMax=[-20;100];
TimeBinning=-2;
TimeMinMax=[42;56]; % TimeMinMax=[0;70];

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',-2,0,TimeMinMax;
    'PlaqueRadius',[RadiiBinning],[0;999],0
    'Distance',[1],DistanceMinMax,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
[Table]=accumArrayBinning(VglutArray1,BinInfo,'BoutonDensityNormEach'); % previously BoutonDensityNorm
Table.Properties.VariableNames{11}='BoutonDensity';
Table=distributeColumnHorizontally_4(Table,[],'MouseId','BoutonDensity',MouseInfo.MouseId);
vglutClusterAnalysis_PlotBoutonDensity(['NormBoutonDensity_',Groups.Description{6},'_',Groups.Description{7}],Table,MouseInfo,Groups.MouseIds([6;7]),RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file);
% vglutClusterAnalysis_PlotBoutonDensity('NormBoutonDensityPooled_336;341;353;375;279;318;331;346;349;371',Table,MouseInfo,Groups.MouseIds(2),RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file);

%% TotalDensity
TotalDensity=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment'}),VglutArray1(:,{'VolumeUm3';'BoutonNumber'}),@nansum);
TotalDensity.BoutonDensity=TotalDensity.BoutonNumber./TotalDensity.VolumeUm3;
Wave1=TotalDensity(TotalDensity.Time2Treatment<=0,:);
Wave1=accumarray_8(Wave1(:,{'MouseId'}),Wave1(:,{'VolumeUm3';'BoutonNumber'}),@nansum);
Wave1.BoutonDensity=Wave1.BoutonNumber./Wave1.VolumeUm3;
TotalDensity=fuseTable_MatchingColums_2(TotalDensity,Wave1,{'MouseId'},{'BoutonDensity'},{'BoutonDensityBefore'});

TotalDensity.BoutonDensityNormBefore=TotalDensity.BoutonDensity./TotalDensity.BoutonDensityBefore*100;

BinInfo=array2table({'MouseId',0,0,0;'Time2Treatment',[7;14],[-28;70],0},'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
[Table]=accumArrayBinning(TotalDensity,BinInfo,'BoutonDensityNormBefore');
Table=distributeColumnHorizontally_4(Table,[],'MouseId','BoutonDensityNormBefore',MouseInfo.MouseId);

[TableExport]=table2cell_2(Table);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);

OutputFilename=[W.G.T.TaskName{W.Task},'_BoutonQuantification'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];

% PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'BoutonDensityNormBefore',[],'Delete');