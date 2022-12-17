function timeTable(Description,ExportTimeTableAsExcelTable)

global TimeTable;


Wave1=dbstack;
Wave1=struct2table(Wave1);
Wave1.Final=strcat(Wave1.name,{' '},num2strArray_3(Wave1.line));
% TimeTable.Filename(size(TimeTable,1)+1,1:size(Wave1,1)-1)=flip(Wave1.name(2:end));
TimeTable.Filename(size(TimeTable,1)+1,1:size(Wave1,1)-1)=flip(Wave1.Final(2:end));
TimeTable.Datenum(size(TimeTable,1),1)=datenum(now);
TimeTable.Date(size(TimeTable,1),1)={datestr(now,'yyyy.mm.dd HH:MM:SS')};
TimeTable.Minutes=uint16((TimeTable.Datenum-[0;TimeTable.Datenum(1:end-1)])*24*60);
% A1=test19;
% A1=whos();
% A1=evalin('base','whos');
Wave1=evalin('caller','whos');

% A1=Wave1(:).bytes;
% A1=(Wave1.bytes);
% Wave1=getfield(Wave1,{'name';'size'});
% Wave1=struct2table(Wave1,'AsArray',1);
TimeTable.Whos(size(TimeTable,1),1)={Wave1};
Wave1=cell2mat({Wave1.bytes}).';
TimeTable.GB(size(TimeTable,1),1)=sum(Wave1)/1000000000;
% Wave1=trackTaskManager;
% Wave2=Wave1.TaskManager(strfind1(Wave1.TaskManager.ImageName,'MATLAB',1),:);
% % % TimeTable.Date{size(TimeTable,1),1}=datestr(TimeTable.Datenum(end),'dd HH:MM:SS');
if exist('Description','Var')==1 && isempty(Description)==0
    TimeTable.Description(size(TimeTable,1),1)={Description};
    disp([Description,': ',datestr(now,'yyyy.mm.dd HH:MM')]);
end

if exist('ExportTimeTableAsExcelTable','Var')==1 && isempty(ExportTimeTableAsExcelTable)==0
    for m=1:100
        try
            global W;
            OutputFilename=[W.G.T.F{W.Task}(W.File,:).Filename{1},'_','TimeTable.xlsx'];
            [PathExcelExport,Report]=getPathRaw(OutputFilename);
            [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
            TimeTable.Duration=(TimeTable.Datenum-TimeTable.Datenum(1))*24*60;
            TimeTable.InterDuration=[0;TimeTable.Duration(2:end)-TimeTable.Duration(1:end-1)];
            xlsActxWrite(table2cell_2(TimeTable),Workbook,'TimeTable',[],'Delete');
            Workbook.Save;
            Workbook.Close;
            break;
        catch
            pause(2);
        end
    end
end