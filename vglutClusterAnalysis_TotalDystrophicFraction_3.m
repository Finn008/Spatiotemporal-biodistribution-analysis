function vglutClusterAnalysis_TotalDystrophicFraction_3(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file)

%% total dystrophic fraction in whole imaged volume
VglutArray2=exchangeVariableName(VglutArray2,'VolumeUm3','ClusterVolume');
TableExport=table;
BinInfo={'MouseId',0,0,0;
    'Time2Treatment',[7],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'Dystrophies2Radius',-2,0,[0,999;10,999;13,999;15,999;20,999;21,999].'; % 'Time2Treatment',-2,0,[-28;70];
    'Distance',-2,0,[-999,999;-999,10;30,999].'; % 'Time2Treatment',-2,0,[-28;70];
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(VglutArray2,BinInfo,'ClusterVolume',[],@sum);

BinInfo({'Dystrophies2Radius';'Distance'},:)=[];
[Wave1]=accumArrayBinning(VglutArray1,BinInfo,'VolumeUm3',[],@sum);
Table=fuseTable_MatchingColums_2(Table,Wave1,{'MouseId';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin'},{'VolumeUm3'});
Table.Data=Table.ClusterVolume./Table.VolumeUm3*100;

Table(:,{'ClusterVolume';'VolumeUm3'})=[];
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);
TableExport=Table;

Wave1=findIntersection_2({'Specification';'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin';'Dystrophies2Radius_Min';'Dystrophies2Radius_Max';'Dystrophies2Radius_Bin';'RoiId';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
keyboard;
xlsActxWrite(TableExport,Workbook,'TotalDystrophicFraction4',[],'Delete');
Workbook.Save;
Workbook.Close;






