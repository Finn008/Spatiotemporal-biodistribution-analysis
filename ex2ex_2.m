function ex2ex_2(Data,PathName)

DefaultPath='\\fs-mu.dzne.de\ag-herms\Finn Peters\Zwischenspeicher';
if exist('PathName')~=1
    [PathName] = uigetdir(DefaultPath);
    PathName=[PathName,'\MatlabExport.xlsx'];
    
end
if strcmp(PathName,'')
%     PathName='\\mitstor8.srv.med.uni-muenchen.de\ZNP-User\fipeter\Desktop\MatlabExport.xlsx';
    PathName=[DefaultPath,'\MatlabExport.xlsx'];
end

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathName);

if iscell(Data)
    Data=cell2table(Data);
elseif isnumeric(Data)
    Data=array2table(Data);
end
% delete(PathName);
% writetable(Data,PathName,'Sheet',1);
xlsActxWrite(Data,Workbook,1,[],'Delete');
Excel.Visible = 1;