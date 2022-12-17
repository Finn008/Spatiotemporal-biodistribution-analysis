function vglutClusterAnalysis_3(PlaqueListSingle,VglutArray1,VglutArray2,PlaqueArray1,BoutonList2,MouseInfo,Version)
global W;

% Relationship: 1-quadrants, 2-laterally, 3-above, 4-below, 5-blood, 6-outside
TimeMinMax=[min(VglutArray1{:,W.XaxisType});max(VglutArray1{:,W.XaxisType})];

%% mice groups
Path2file=[W.G.PathOut,'\SurfacePlots\VGLUT1ClusterDistribution\'];
Groups={[336;341;353;375],'Vehicle_336;341;353;375';... % 1
    [279;318;331;346;349;371],'NB360_279;318;331;346;349;371';... % 2
    [336;341;353;375;279;318;331;346;349;371],'All_336;341;353;375;279;318;331;346;349;371';... % 3
    [336;341;353;375;279;318;331;346;349;371;264;9266;614],'336;341;353;375;318;331;346;349;371;264;9266;614';... % 4
    [307;314;336;338;341;352;353;375;275;279;280;318;331;346;347;349;351;371],'All';... % 5
    [318;331;346;349;371],'NB360_318;331;346;349;371';... % 6
    [275;279;280;318;331;346;347;349;351;371],'NB360_275;279;280;318;331;346;347;349;351;371';... % 7
    [279;318;331;347;349;371],'NB360_279;318;331;347;349;371';... %8
    [279;318;331;346;347;349;371],'NB360_279;318;331;346;347;349;371';... %9
    [442;480;481;483],'TauKD_442;480;481;483';... %10
    [311;312;348;369;370;372;374;377;381;383;384;9347],'TauKO_311;312;348;369;370;372;374;377;381;383;384;9347';... %11
    [307],'307';...
    [314],'314';...
    [336],'336';...
    [338],'338';...
    [341],'341';...
    [352],'352';...
    [353],'353';...
    [375],'375';...
    [275],'275';...
    [279],'279';...
    [280],'280';...
    [318],'318';...
    [331],'331';...
    [346],'346';...
    [347],'347';...
    [349],'349';...
    [351],'351';...
    [371],'371';...
    [442],'442';...
    [480],'480';...
    [481],'481';...
    [483],'483';...
    [311],'311';...
    [312],'312';...
    [348],'348';...
    [369],'369';...
    [370],'370';...
    [372],'372';...
    [374],'374';...
    [377],'377';...
    [381],'381';...
    [383],'383';...
    [384],'384';...
    [9347],'9347';...
    };
Groups=array2table(Groups,'VariableNames',{'MouseIds';'Description'});

% condense Relationship
RelationshipIDs=[1;2;3;4;5]; % RelationshipIDs=[1;2;3;4]; % RelationshipIDs=[1;2;3;5];
VglutArray2=VglutArray2(ismember(VglutArray2.Relationship,RelationshipIDs),:);
VglutArray2(:,{'Relationship'})=[];
VglutArray2=accumarray_8(VglutArray2(:,{'MouseId';W.XaxisType;'RoiId';'PlId';'Dystrophies2Radius';'Distance'}),VglutArray2(:,{'VolumeUm3'}),@nansum,[]);

VglutArray1=VglutArray1(ismember(VglutArray1.Relationship,RelationshipIDs),:);
VglutArray1(:,{'Relationship'})=[];
VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';W.XaxisType;'RoiId';'PlId';'Distance'}),VglutArray1(:,{'VolumeUm3'}),@nansum,[]);

keyboard;
if strcmp(Version,'TotalDystrophicFraction') % for each plaque
    vglutClusterAnalysis_TotalDystrophicFraction_3(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file);
end

if strcmp(Version,'ClusterDistribution4AllPlaqueSizes')
    vglutClusterAnalysis_ClusterDistribution4AllPlaqueSizes(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,Path2file);
end

if strcmp(Version,'BoutonQuantification')
    vglutClusterAnalysis_BoutonQuantification(VglutArray1,PlaqueListSingle,BoutonList2,MouseInfo,Groups,RelationshipIDs,Path2file);
end
if strcmp(Version,'TransitionClusterSize')
    keyboard;
    BinInfo={'MouseId',0,0,0; % no binning
        'Time2Treatment',-2,0,[-28;70];
        'PlaqueRadius',[10],[0;999],0 %
        'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
        'Distance',[1],[-20;51],0; % 1µm steps
        };
end
if strcmp(Version,'ClusterDistributionDistantFromPlaque')
    vglutClusterAnalysis_ClusterDistributionDistantFromPlaque(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file);
end




keyboard; % default for any Cluster analysis

BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
BinInfo.Properties.RowNames=BinInfo.Name;

% make a framework with all 'existing' cluster bins set to zero
ClusterBins=unique(VglutArray2.Dystrophies2Radius);
Wave1=repmat(ClusterBins.',[size(VglutArray1,1),1]);
VglutArray1=[repmat(VglutArray1,[size(ClusterBins,1),1])];
VglutArray1.Dystrophies2Radius(:,1)=Wave1(:);

% VglutArray1
VariableNames=VglutArray2.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'VolumeUm3','ClusterVolume');
VglutArray2.Properties.VariableNames=VariableNames;

Wave1=fuseTable_MatchingColums_2(VglutArray1,VglutArray2,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance';'Dystrophies2Radius'},{'ClusterVolume'});
VglutArray1.ClusterVolume=full(Wave1.ClusterVolume);



Mice=unique(VglutArray1.MouseId);

if strcmp(Version,'DystrophicFraction4AllPlaqueSizesAndTimes');
    keyboard; % remove this version
    % sum all clustersizes from 10 upwards for each individual plaque
    VglutArray1(VglutArray1.Dystrophies2Radius<=9,:)=[];
    VglutArray1.Fraction=VglutArray1.ClusterVolume./VglutArray1.VolumeUm3*100;
    VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),VglutArray1(:,{'Fraction'}),@nansum);
    VglutArray1=fuseTable_MatchingColums_2(VglutArray1,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});
    VglutArray1(:,{'RoiId';'PlId'})=[];
    [Table]=accumArrayBinning(VglutArray1,BinInfo,'Fraction');
end
if strcmp(VersionGlobal,'Clusters')
    Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);
end

keyboard;

%% DystrophicFraction4AllPlaqueSizesAndTimes
if strcmp(Version,'DystrophicFraction4AllPlaqueSizesAndTimes')
    % cumsum of cluster fraction (Y) with regards to cluster size (X) over time (Z), with different cohorts (Control,Vehicle,NB360) in (blue,red,black)
    vglutClusterAnalysis_PlotDystrophicFractionWithPlaqueSizeAndAge(Groups.Description{2},Table,MouseInfo,Groups.MouseIds{2},2,[0;30],14,[-28,70],[0;1],Path2file);
    vglutClusterAnalysis_PlotDystrophicFractionWithPlaqueSizeAndAge(Groups.Description{2},Table,MouseInfo,Groups.MouseIds{2},2,[0;30],28,[-28,56],[0;1],Path2file);
    vglutClusterAnalysis_PlotDystrophicFractionWithPlaqueSizeAndAge(Groups.Description{2},Table,MouseInfo,Groups.MouseIds{2},2,[0;30],999,[-999,999],[0;1],Path2file);
    %     vglutClusterAnalysis_PlotDystrophicFractionWithPlaqueSizeAndAge(Groups.Description{2},Table,MouseInfo,Groups.MouseIds{2},2,[0;30],28,[-28,56],[0;1],Path2file);
    
end

%% export data to Excel
TableExport=Table;
TableExport=sortrows_2(TableExport,Table.Properties.VariableNames(1:end-1));
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'TreatmentType'})).';

TableExport(end+1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'MouseId'})).';
TableExport=[TableExport(1,:);TableExport(end,:);TableExport(2:end-1,:)];

ExcelFilename=['VGLUT1'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'Dystrophies2Radius',[],'Delete');

%% ClusterDistributionDistantFromPlaque
if strcmp(Version,'ClusterDistributionDistantFromPlaque')
    % cumsum of cluster fraction (Y) with regards to cluster size (X) over time (Z), with different cohorts (Control,Vehicle,NB360) in (blue,red,black)
    vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Groups.Description{4},Table,MouseInfo,Groups.MouseIds{4},7,[-28,70],[],Path2file);
    vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Groups.Description{4},Table,MouseInfo,Groups.MouseIds{4},14,[-28,70],[],Path2file);
    vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Groups.Description{4},Table,MouseInfo,Groups.MouseIds{4},28,[42,70],[],Path2file);
    
end



%% 3D plot showing the distribution of each cluster bin normalized to its maximum with regards to plaque distance
if strcmp(Version,'TransitionClusterSize')
    
    [Image]=vglutClusterAnalysis_PlotClusterSizeDistribution_2(Groups.Description{1},Table,MouseInfo,Groups.MouseIds{1},10,[10,20],1,[-20;51],-2,[-28,70],[],Path2file);
end




