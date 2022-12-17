function retrieveDataPerBin(Table,BinInfo,Column)


[Table2]=accumArrayBinning(Table,BinInfo,'RoiId');
Table2(:,'RoiId') = [];

Table2.Count=nan(size(Table2,1),4);
for Row=1:size(Table2,1)
    Wave1=Table(Table.MouseId==Table2.MouseId(Row) & Table.Time2Treatment>=Table2.Time2Treatment_Min(Row) & Table.Time2Treatment<Table2.Time2Treatment_Max(Row),:);
    Wave1=unique(Wave1.Time2Treatment);
    Table2.Count(Row,1:size(Wave1,1))=Wave1.';
end

PathExcelExport=['\\GNP90N\share\Finn\Raw data\RedistributeTime2Treatment.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
keyboard;
xlsActxWrite(Table2,Workbook,'Redistribute2',[],'Delete');
Workbook.Save;
Workbook.Close;
