function vglutClusterAnalysis_ClusterDistributionDistantFromPlaque(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file)

DistanceThreshold=30;

[Wave1]=ismember(VglutArray2.MouseId,MouseInfo.MouseId(strcmp(MouseInfo.TreatmentType,'Control')));
VglutArray2.Distance(Wave1,1)=DistanceThreshold;
VglutArray2=VglutArray2(VglutArray2.Distance>=DistanceThreshold,:);
VglutArray2=accumarray_8(VglutArray2(:,{'MouseId';'Time2Treatment';'Dystrophies2Radius'}),VglutArray2(:,{'VolumeUm3'}),@nansum);

TotalVolume=accumarray_8(VglutArray2(:,{'MouseId';'Time2Treatment'}),VglutArray2(:,{'VolumeUm3'}),@nansum);

VglutArray2=fuseTable_MatchingColums_2(VglutArray2,TotalVolume,{'MouseId';'Time2Treatment'},{'VolumeUm3'},{'TotalVolume'});
VglutArray2.Data=VglutArray2.VolumeUm3./VglutArray2.TotalVolume*100;

TableExport=table;
BinInfo={'MouseId',0,0,0; % no binning
    'Time2Treatment',[7;14;28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; % 
    'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;


[Table]=accumArrayBinning(VglutArray2,BinInfo,'Data');

% make cumulative data for each 


Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);
Table.Specification(:,1)={['Distance: >=',num2str(DistanceThreshold)]};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;



Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'Dystrophies2Radius_Min';'Dystrophies2Radius_Max';'Dystrophies2Radius_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'ClusterDistributionDistant',[],'Delete');
Workbook.Save;
Workbook.Close;

return;

DistanceThreshold=30;
[Wave1]=ismember(VglutArray1.MouseId,MouseInfo.MouseId(strcmp(MouseInfo.TreatmentType,'Control')));
VglutArray1.Distance(Wave1,1)=DistanceThreshold;

VglutArray1=VglutArray1(VglutArray1.Distance>=DistanceThreshold,:);


% make a framework such that each single volume bin has all existing cluster bins set to zero
ClusterBins=unique(VglutArray2.Dystrophies2Radius);
Wave1=repmat(ClusterBins.',[size(VglutArray1,1),1]);
VglutArray1=[repmat(VglutArray1,[size(ClusterBins,1),1])];
VglutArray1.Dystrophies2Radius(:,1)=Wave1(:);


% VglutArray1
VariableNames=VglutArray2.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'VolumeUm3','ClusterVolume');
VglutArray2.Properties.VariableNames=VariableNames;

VglutArray1=fuseTable_MatchingColums_2(VglutArray1,VglutArray2,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance';'Dystrophies2Radius'},{'ClusterVolume'});

VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'Dystrophies2Radius'}),VglutArray1(:,{'ClusterVolume';'VolumeUm3'}),@nansum);
VglutArray1.Data=VglutArray1.ClusterVolume./VglutArray1.VolumeUm3*100;



TableExport=table;
BinInfo={'MouseId',0,0,0; % no binning
    'Time2Treatment',[7;14;28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; % 
    'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;


[Table]=accumArrayBinning(VglutArray1,BinInfo,'Data');
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);
Table.Specification(:,1)={['Distance: >=',num2str(DistanceThreshold)]};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;



Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'Dystrophies2Radius_Min';'Dystrophies2Radius_Max';'Dystrophies2Radius_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'ClusterDistributionDistant',[],'Delete');
Workbook.Save;
Workbook.Close;
return;

% [Table]=accumArrayBinning(VglutArray1,BinInfo,'Fraction');

Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);
vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Groups.Description{4},Table,MouseInfo,Groups.MouseIds{4},7,[-28,70],[],Path2file);
vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Groups.Description{4},Table,MouseInfo,Groups.MouseIds{4},14,[-28,70],[],Path2file);
vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Groups.Description{4},Table,MouseInfo,Groups.MouseIds{4},28,[42,70],[],Path2file);