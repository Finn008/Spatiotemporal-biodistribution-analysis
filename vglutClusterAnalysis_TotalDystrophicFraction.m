function vglutClusterAnalysis_TotalDystrophicFraction(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file)

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
xlsActxWrite(TableExport,Workbook,'TotalDystrophicFraction_2',[],'Delete');

return;




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

