function finalEvaluation_VisualizePlaqueBurden(MouseInfo,PlaqueArray1)
global W;


XaxisType='Age'; %'TimeToTreatment'
ExcelFilename=['PlaqueBurden'];
OutputFilename=[W.G.T.TaskName{W.Task},'_',ExcelFilename,'.xlsx'];
PathExcelExport=getPathRaw(OutputFilename);

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
Table=accumarray_9(PlaqueArray1(:,{'MouseId';'Time2Treatment';'Age'}),PlaqueArray1(:,{'VolumeUm3'}),@nansum,[]);

PlaqueArray1=PlaqueArray1(PlaqueArray1.Distance<=0,:);
Wave1=accumarray_9(PlaqueArray1(:,{'MouseId';'Time2Treatment';'Age'}),PlaqueArray1(:,{'VolumeUm3'}),@nansum,[]);

Table=fuseTable_MatchingColums_2(Table,Wave1,{'MouseId';'Time2Treatment';'Age'},{'VolumeUm3'},'PlaqueVolumeUm3');
Table.PlaqueBurden=Table.PlaqueVolumeUm3./Table.VolumeUm3*100;


BinInfo={'MouseId',0,0,0;'Age',[7],[70;245],0};
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table2]=accumArrayBinning(Table,BinInfo,'PlaqueBurden',[],@mean);

Table=distributeColumnHorizontally_4(Table2,[],'MouseId','PlaqueBurden',MouseInfo.MouseId);

[TableExport]=table2cell_2(Table);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;


% TimeMinMax=[min(PlaqueArray1{:,XaxisType});max(PlaqueArray1{:,XaxisType})];

xlsActxWrite(TableExport,Workbook,'PlaqueBurden',[],'Delete');
Workbook.Save;
Workbook.Close;