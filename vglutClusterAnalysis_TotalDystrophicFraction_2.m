function vglutClusterAnalysis_TotalDystrophicFraction_2(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file)

%% total dystrophic fraction in whole imaged volume
VglutArray2=exchangeVariableName(VglutArray2,'VolumeUm3','ClusterVolume');
% VariableNames=VglutArray2.Properties.VariableNames.';
% VariableNames=strrep(VariableNames,'VolumeUm3','ClusterVolume');
% VglutArray2.Properties.VariableNames=VariableNames;

BinInfo={'MouseId',0,0,0;
    'Time2Treatment',[7;14],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;

TableExport=table;

ClusterThresholds=[10;13;20];
% Distances: all
for Cl=1:size(ClusterThresholds,1)
    VglutArray2Sel=VglutArray2(VglutArray2.Dystrophies2Radius>=ClusterThresholds(Cl),:);
    VglutArray2Sel=accumarray_8(VglutArray2Sel(:,{'MouseId';'Time2Treatment'}),VglutArray2Sel(:,{'ClusterVolume'}),@nansum);
    VglutArray1Sel=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment'}),VglutArray1(:,{'VolumeUm3'}),@nansum);
    VglutArray2Sel=fuseTable_MatchingColums_2(VglutArray2Sel,VglutArray1Sel,{'MouseId';'Time2Treatment';},{'VolumeUm3'});
    VglutArray2Sel.Data=VglutArray2Sel.ClusterVolume./VglutArray2Sel.VolumeUm3*100;
    [Table]=accumArrayBinning(VglutArray2Sel,BinInfo,'Data');
    Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);
    Table.Specification(:,1)={['Cluster: >=',num2str(ClusterThresholds(Cl)),', Dist: all']};
    TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;
end

% Distances: <=10
for Cl=1:size(ClusterThresholds,1)
    VglutArray2Sel=VglutArray2(VglutArray2.Distance<=10,:);
    VglutArray2Sel=VglutArray2Sel(VglutArray2Sel.Dystrophies2Radius>=ClusterThresholds(Cl),:);
    VglutArray2Sel=accumarray_8(VglutArray2Sel(:,{'MouseId';'Time2Treatment'}),VglutArray2Sel(:,{'ClusterVolume'}),@nansum);
    
    VglutArray1Sel=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment'}),VglutArray1(:,{'VolumeUm3'}),@nansum);
    VglutArray2Sel=fuseTable_MatchingColums_2(VglutArray2Sel,VglutArray1Sel,{'MouseId';'Time2Treatment';},{'VolumeUm3'});
    VglutArray2Sel.Data=VglutArray2Sel.ClusterVolume./VglutArray2Sel.VolumeUm3*100;
    [Table]=accumArrayBinning(VglutArray2Sel,BinInfo,'Data');
    Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);
    Table.Specification(:,1)={['Cluster: >=',num2str(ClusterThresholds(Cl)),', Dist: <=10']};
    TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;
end

Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'TotalDystrophicFraction',[],'Delete');
Workbook.Save;
Workbook.Close;
return;

%% dystrophic fraction for each plaque

VglutArray1=OrigVglutArray1;
VariableNames=VglutArray2.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'VolumeUm3','ClusterVolume');
VglutArray2.Properties.VariableNames=VariableNames;

VglutArray2(VglutArray2.Dystrophies2Radius<9 | VglutArray2.Distance>10,:)=[]; % previously 10
% VglutArray2(VglutArray2.Dystrophies2Radius<9,:)=[]; % previously 10

VglutArray2=fuseTable_MatchingColums_2(VglutArray2,VglutArray1,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'},{'VolumeUm3'});
VglutArray2.Fraction=VglutArray2.ClusterVolume./VglutArray2.VolumeUm3*100;

VglutArray2=accumarray_8(VglutArray2(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),VglutArray2(:,{'Fraction'}),@nansum);

VglutArray2(VglutArray2.Distance~=1,:)=[];
% % % VglutArray2=accumarray_8(VglutArray2(:,{'MouseId';'Time2Treatment';'RoiId';'PlId'}),VglutArray2(:,{'Fraction'}),@nanmax);
VglutArray2=fuseTable_MatchingColums_2(VglutArray2,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});



BinInfo={'MouseId',0,0,0; % no binning
    'Time2Treatment',-2,0,[-28;0;42;70]; % 'Time2Treatment',[14],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',[2],[0;999],0 %
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;

[Table]=accumArrayBinning(VglutArray2,BinInfo,'Fraction');

Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);


[TableExport]=table2cell_2(Table);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'DystrophicFractionPerPlaque',[],'Delete');




return;



VglutArray2(VglutArray2.Distance~=1,:)=[];
% % % VglutArray2=accumarray_8(VglutArray2(:,{'MouseId';'Time2Treatment';'RoiId';'PlId'}),VglutArray2(:,{'Fraction'}),@nanmax);
VglutArray2=fuseTable_MatchingColums_2(VglutArray2,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});










VglutArray1.Fraction=VglutArray1.ClusterVolume./VglutArray1.VolumeUm3*100;
VglutArray1(:,{'VolumeUm3';'ClusterVolume'})=[];









Wave1=fuseTable_MatchingColums_2(VglutArray1,VglutArray2,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance';'Dystrophies2Radius'},{'ClusterVolume'});
VglutArray1.ClusterVolume=full(Wave1.ClusterVolume);

VglutArray1(VglutArray1.Dystrophies2Radius>10,:)=[];
%     VglutArray1(VglutArray1.Distance>10,:)=[];
VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment'}),VglutArray1(:,{'ClusterVolume';'VolumeUm3'}),@nansum);
VglutArray1.Fraction=VglutArray1.ClusterVolume./VglutArray1.VolumeUm3*100;
VglutArray1(:,{'VolumeUm3';'ClusterVolume'})=[];


BinInfo={'MouseId',0,0,0; % no binning
    'Time2Treatment',[7;14;28],[-28;70],0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
BinInfo.Properties.RowNames=BinInfo.Name;

[Table]=accumArrayBinning(VglutArray1,BinInfo,'Fraction');
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);


