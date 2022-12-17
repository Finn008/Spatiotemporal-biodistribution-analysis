function exchangeFileName
global W;
ExcelFilename='ExchangeFileName';
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
keyboard;
Task=1;

Table=xlsActxGet(Workbook,1,1);

Drives=W.G.PathRaw;
for m=1:size(Drives,1)
    Wave1=listAllFiles(Drives.Path{m,1});
    if exist('AllFiles')==0
        AllFiles=Wave1;
    else
        AllFiles=[AllFiles;Wave1];
    end
end


for File=1:size(Table,1)
    Files2Change=AllFiles(strfind1(AllFiles.FilenameTotal,Table.FilenameTotal1{File,1}),:);
    Files2Change.FilenameTotal2=regexprep(Files2Change.FilenameTotal,Table.FilenameTotal1{File,1},Table.FilenameTotal2{File,1});
    for m=1:size(Files2Change,1)
        Path=['rename "',Files2Change.Path2file{m,1},'" "',Files2Change.FilenameTotal2{m,1},'"'];
        [Status,Cmdout]=dos(Path);
        if isempty(Cmdout)==0
            keyboard;
        end
    end
    W.G.Fileinfo.FilenameTotal=regexprep(W.G.Fileinfo.FilenameTotal,Table.FilenameTotal1{File,1},Table.FilenameTotal2{File,1});
    W.G.Fileinfo.Filename=regexprep(W.G.Fileinfo.Filename,Table.FilenameTotal1{File,1},Table.FilenameTotal2{File,1});
    W.G.T.F{Task,1}.Filename=regexprep(W.G.T.F{Task,1}.Filename,Table.FilenameTotal1{File,1},Table.FilenameTotal2{File,1});
    W.G.TaskList.Filename=regexprep(W.G.TaskList.Filename,Table.FilenameTotal1{File,1},Table.FilenameTotal2{File,1});
end
showPipeline('Matlab2Excel');

% xlsActxWrite(TableExport,Workbook,ExcelFilename,[],'Delete');
Workbook.Save;
Workbook.Close;