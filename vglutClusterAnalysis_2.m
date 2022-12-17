function vglutClusterAnalysis_2(PlaqueListSingle,VglutArray1,VglutArray2,MouseInfo)
global W;
% Relationship: 1-quadrants, 2-laterally, 3-above, 4-below, 5-blood, 6-outside
% keyboard;
TimeMinMax=[min(VglutArray1.Time2Treatment);max(VglutArray1.Time2Treatment)];
BinInfo={   'MouseId',0,0,0; % no binning
    'Time2Treatment',[7;14],TimeMinMax,0; % weekly
    'PlaqueRadius',[999;10],[0;999],0
    'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
    'Distance',[1],[-20;51],0; % 1µm steps
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});

RelationshipIDs=[1;2;3];
VglutArray2=VglutArray2(ismember(VglutArray2.Relationship,RelationshipIDs),:);
VglutArray2(:,{'Relationship'})=[];
VglutArray2=accumarray_8(VglutArray2(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Dystrophies2Radius';'Distance'}),VglutArray2(:,{'VolumeUm3'}),@nansum,[],'Sparse');

VglutArray1=VglutArray1(ismember(VglutArray1.Relationship,RelationshipIDs),:);
VglutArray1(:,{'Relationship'})=[];
VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),VglutArray1(:,{'VolumeUm3'}),@nansum,[],'Sparse');
% make a framework with all 'existing' cluster bins set to zero
ClusterBins=unique(VglutArray2.Dystrophies2Radius);
% Wave1=table2cell(VglutArray1);

VglutArray1=[repmat(VglutArray1,[size(ClusterBins,1),1])];
Wave1=repmat(ClusterBins.',[size(VglutArray1,1),1]);
VglutArray1.Dystrophies2Radius(:,1)=Wave1(:);

Wave1=full(VglutArray1{:,:});
Wave1=[repmat(Wave1,[size(ClusterBins,1),1])];
VglutArray1

Wave1=fuseTable_MatchingColums_2(VglutArray2,VglutArray1,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'},{'VolumeUm3'});
VglutArray2.TotalVolume=Wave1.VolumeUm3;
VglutArray2.Fraction=full(VglutArray2.VolumeUm3./VglutArray2.TotalVolume*100);

Wave1=fuseTable_MatchingColums_2(VglutArray2,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'});
VglutArray2.PlaqueRadius=Wave1.RadiusFit1;

VglutArray2(:,{'RoiId';'PlId';'VolumeUm3';'TotalVolume'})=[];


[Table]=accumArrayBinning(VglutArray2,BinInfo,'Fraction','MouseId');




Mice=unique(VglutArray2.MouseId);
[Ind1,Ind2]=ismember(MouseInfo.MouseId,Mice);
Wave1=nan(size(Table,1),size(MouseInfo,1));
Wave1(:,Ind1==1)=Table.Fraction(:,Ind2(Ind1==1));
Table.Fraction=Wave1;

keyboard;

% export data to Excel
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

% image showing distribution of cluster size with regards to distance to the plaque
Groups={[314;336;341;353;375],{'Vehicle'},[0.5;0.5;0.5];...
    [318;331;346;347;371],{'NB-360_5Sel'},[0;0;0];...
    [275;279;280;318;331;371],{'NB-360_5Sel2'},[0;0;0];...
    [314],{'Mouse336'},[0;0;0];...
    [336],{'Mouse336'},[0;0;0];...
    [341],{'Mouse336'},[0;0;0];...
    [353],{'Mouse336'},[0;0;0];...
    [375],{'Mouse336'},[0;0;0];...
    [275;279;280;318;331;346;347;349;351;371],{'NB-360_All'},[0;0;0];...
    };
Groups=array2table(Groups,'VariableNames',{'MouseIds';'Description';'Color'});
Path2file=[W.G.PathOut,'\SurfacePlots\VGLUT1ClusterDistribution\'];

vglutClusterAnalysis_PlotClusterSizeDistribution('Vehicle_all',Table,MouseInfo,Groups([1],:),999,[0;999],1,[-10;51],14,[-14;0],[],Path2file);

vglutClusterAnalysis_PlotClusterSizeDistribution('Vehicle_0to10um',Table,MouseInfo,Groups([1],:),10,[0;10],1,[-10;51],14,[-14;0],[],Path2file);
vglutClusterAnalysis_PlotClusterSizeDistribution('Vehicle_10to20um',Table,MouseInfo,Groups([1],:),10,[10;20],1,[-10;51],14,[-14;0],[],Path2file);
vglutClusterAnalysis_PlotClusterSizeDistribution('Vehicle_20to30um',Table,MouseInfo,Groups([1],:),10,[20;30],1,[-10;51],14,[-14;0],[],Path2file);

vglutClusterAnalysis_PlotClusterSizeDistribution('M336_10to20um',Table,MouseInfo,Groups([6],:),10,[10;20],1,[-10;51],14,[-14;0],[],Path2file);
vglutClusterAnalysis_PlotClusterSizeDistribution('M336_10to20um',Table,MouseInfo,Groups([6],:),10,[10;20],1,[-10;51],7,[-7;0],[],Path2file);

% Times=(-21:7:63).';Times=[Times,Times+7];
% for Time=1:size(Times,1)
%     Week=num2str(Times(Time,1)/7);
%     processTraceGroups_RadiusDistanceFraction(['Vehicle_Vs_NB360sel_',Week],Table,MouseInfo,Groups([1:2],:),RadiiBinning,[0;30],1,[-10;20],Times(Time,:).',Zaxis,Path2file);
% end


