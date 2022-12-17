function copy2excel(Data,ExcelFilename)
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(Data,Workbook,'Tabelle1',[],'Delete');
Workbook.Save;
% Workbook.Close;