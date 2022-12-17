function miceOverview()

Path2file='\\Gnp42n\marvin\Finn\aktuelle Dokumente\AnimalBreeding.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);
Current=xlsActxGet(Workbook,'Current',1);

Path2file='\\Gnp42n\marvin\Finn\aktuelle Dokumente\AnimalOverview.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);
Table=xlsActxGet(Workbook,'Overview',1);

for Line=1:size(Table,1)
   LineId=Table.MouseLine{Line};
   Wave1=find(strcmp(Current.MouseLine,LineId)&strcmp(Current.Location,Table.Location{Line}));
   Table.NumberMice(Line,1)=size(Wave1,1);
   
   Wave2=unique(Current.CageId(Wave1));
   Table.NumberCages(Line,1)=size(Wave2,1);
   
   
end

excelWriteSparse(Table(:,{'NumberMice';'NumberCages'}),Workbook,'Overview');